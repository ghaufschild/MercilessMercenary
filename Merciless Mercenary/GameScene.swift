//
//  GameScene.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild, and Ryan Ziolkowski on 4/1/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

//  Coordinates (0,0) are in bottom left

import SpriteKit


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Player    : UInt32 = 0b11      // 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 1
    let player = SKSpriteNode(imageNamed: "player")
    var attackTimer = NSTimer()
    var moveTimer = NSTimer()
    
    var moveLoc: CGPoint!
    var attackLoc: CGPoint!
    
    var moveJoystick = SKView()
    var attackJoystick = SKView()
    
    //View Did Load
    override func didMoveToView(view: SKView) {
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        
        let backgroundImage = SKSpriteNode(imageNamed: "ground")
        backgroundImage.size = self.scene!.size
        backgroundImage.zPosition = -1
        backgroundImage.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        backgroundImage.zPosition = -1
        addChild(backgroundImage)
        
        moveJoystick = SKView(frame: CGRect(x: 0, y: size.height - size.width * 0.2, width: size.width * 0.2, height: size.width * 0.2))
        moveJoystick.backgroundColor = UIColor.lightGrayColor()
        moveJoystick.alpha = 0.25
        self.view?.addSubview(moveJoystick)
        
        attackJoystick = SKView(frame: CGRect(x: size.width * 0.8, y: size.height - size.width * 0.2, width: size.width * 0.2, height: size.width * 0.2))
        attackJoystick.backgroundColor = UIColor.lightGrayColor()
        attackJoystick.alpha = 0.25
        self.view?.addSubview(attackJoystick)
        
        //addChild(backgroundMusic)
        // 2
        backgroundColor = SKColor.whiteColor()
        // 3
        
        let playerText = SKTexture(CGImage: (UIImage(named: "player")?.CGImage)!)
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.physicsBody = SKPhysicsBody(texture: playerText, size: playerText.size())
        //player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        // 4
        addChild(player)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
    }
    
    
    //////////////////////////      JOYSTICK FUNCTIONS      //////////////////////////////
    
    //Attack Function
    func createShuriken()
    {
        let touchLocation = attackLoc
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let centerPoint = CGPoint(x: attackJoystick.frame.minX + attackJoystick.frame.width/2, y: attackJoystick.frame.width/2)
        let offset = touchLocation - centerPoint
        addChild(projectile)
        
        let direction = offset.normalized()
        let shootAmount = direction * 1000
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    //Move Function
    func move()
    {
        var currentPoint = moveLoc
        currentPoint!.y = self.view!.frame.maxY - currentPoint!.y
        let newPoint = moveJoystick.center - currentPoint!
        let xOffset = newPoint.x
        let yOffset = newPoint.y
        let absX = abs(xOffset)
        let absY = abs(yOffset)
        var realDest = newPoint
        
        let moveDist: CGFloat = 10
        let diagMove: CGFloat = moveDist/sqrt(2)
        
        if xOffset > 0 && absX > absY // Left
        {
            if(xOffset < 2 * yOffset)
            {
                realDest = CGPoint(x: player.position.x - diagMove, y: player.position.y + diagMove)
            }
            else if(xOffset < -2 * yOffset)
            {
                realDest = CGPoint(x: player.position.x - diagMove, y: player.position.y - diagMove)
            }
            else
            {
                realDest = CGPoint(x: player.position.x - moveDist, y: player.position.y)
            }
        }
        else if yOffset > 0 && absX < absY // Up
        {
            if(2 * xOffset > yOffset)
            {
                realDest = CGPoint(x: player.position.x - diagMove, y: player.position.y + diagMove)
            }
            else if(-2 * xOffset > yOffset)
            {
                realDest = CGPoint(x: player.position.x + diagMove, y: player.position.y + diagMove)
            }
            else
            {
                realDest = CGPoint(x: player.position.x, y: player.position.y + moveDist)
            }
        }
        else if xOffset < 0 && absX > absY // Right
        {
            if(xOffset > 2 * yOffset)
            {
                realDest = CGPoint(x: player.position.x + diagMove, y: player.position.y - diagMove)
            }
            else if(xOffset > -2 * yOffset)
            {
                realDest = CGPoint(x: player.position.x + diagMove, y: player.position.y + diagMove)
            }
            else
            {
                realDest = CGPoint(x: player.position.x + moveDist, y: player.position.y)
            }
        }
        else if yOffset < 0 && absX < absY // Down
        {
            if(2 * xOffset < yOffset)
            {
                realDest = CGPoint(x: player.position.x + diagMove, y: player.position.y - diagMove)
            }
            else if(-2 * xOffset < yOffset)
            {
                realDest = CGPoint(x: player.position.x - diagMove, y: player.position.y - diagMove)
            }
            else
            {
                realDest = CGPoint(x: player.position.x, y: player.position.y - moveDist)
            }
        }
        if self.frame.contains(realDest)
        {
            let actionMove = SKAction.moveTo(realDest, duration: 0.1)
            player.runAction(actionMove)
        }
        else{
            if realDest.y <= 0 // Bottom
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55
                {
                    player.position = CGPoint(x: size.width * 0.5, y: size.height)
                }
            }
        }
    }
    
    /////////////////////////////////       TOUCH FUNCTIONS        ////////////////////////////////
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let firstTouch = touches.first?.locationInNode(self)
        if(!attackTimer.valid)
        {
            if isInAttack(firstTouch!)
            {
                attackLoc = firstTouch
                createShuriken()
                attackTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.createShuriken), userInfo: nil, repeats: true)
            }
        }
        if(!moveTimer.valid)
        {
            if isInMove(firstTouch!)
            {
                moveLoc = firstTouch
                moveTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.move), userInfo: nil, repeats: true)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var stopMove = true
        var stopAttack = true
        
        for touch in (event?.allTouches())!
        {
            if(isInMove(touch.locationInNode(self)))
            {
                moveLoc = touch.locationInNode(self)
                stopMove = false
            }
            if(isInAttack(touch.locationInNode(self)))
            {
                attackLoc = touch.locationInNode(self)
                stopAttack = false
            }
        }
        if(stopMove)
        {
            moveTimer.invalidate()
        }
        else if(!moveTimer.valid)
        {
            moveTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.move), userInfo: nil, repeats: true)
        }
        if(stopAttack)
        {
            attackTimer.invalidate()
        }
        else if(!attackTimer.valid)
        {
            createShuriken()
            attackTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.createShuriken), userInfo: nil, repeats: true)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(isInMove((touches.first?.locationInNode(self))!))
        {
            moveTimer.invalidate()
        }
        if(isInAttack((touches.first?.locationInNode(self))!))
        {
            attackTimer.invalidate()
        }
    }
    
    /////////////////////////        LOCATION FUNCTIONS          //////////////////////////////
    
    func isInMove(loc: CGPoint) -> Bool
    {
        let wid = moveJoystick.frame.width
        let realFrame = CGRect(x: 0, y: 0, width: wid, height: wid)
        if(loc.x < realFrame.maxX && loc.x > realFrame.minX && loc.y < realFrame.maxY && loc.y > realFrame.minY)
        {
            return true
        }
        return false
    }
    
    func isInAttack(loc: CGPoint) -> Bool
    {
        let wid = attackJoystick.frame.width
        let realFrame = CGRect(x: wid * 4, y: 0, width: wid, height: wid)
        if(loc.x < realFrame.maxX && loc.x > realFrame.minX && loc.y < realFrame.maxY && loc.y > realFrame.minY)
        {
            return true
        }
        return false
    }
    
    /////////////////////////////////       MONSTER COLLISIONS      //////////////////////////
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    func projectileDidCollideWithMonster(monster: SKSpriteNode, projectile: SKSpriteNode) {
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func playerDidCollideWithMonster(monster: SKSpriteNode, player: SKSpriteNode) {
        player.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask == 1) &&
            (secondBody.categoryBitMask == 2)) {
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, projectile: secondBody.node as! SKSpriteNode)
        }
        else if((firstBody.categoryBitMask == 1) &&
            (secondBody.categoryBitMask == 3))
        {
            playerDidCollideWithMonster(firstBody.node as! SKSpriteNode, player: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == 1) &&
        (secondBody.categoryBitMask == 3))
        {
            print("lmao")
            playerDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    /////////////////////////////////       HELPER FUNCTIONS       ///////////////////////////
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
}