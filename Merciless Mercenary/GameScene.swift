//
//  GameScene.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild, and Ryan Ziolkowski on 4/1/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

//  Coordinates (0,0) are in bottom left
//  SKVIEW changes (0, 0) is in top left

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
    
    /////////     MAP THINGS      //////////
    var map = Map(version: 1)       //Still needs more work, aka graphics
    
    // 1
    let player = SKSpriteNode(imageNamed: "player")
    var canDoStuff: Bool = true     //For checking for transitions, eventually move elsewhere
    
    var attackTimer = NSTimer()
    var moveTimer = NSTimer()
    var transTimer = NSTimer()
    
    var moveLoc: CGPoint!
    var attackLoc: CGPoint!
    var moveTo: CGPoint!
    
    var moveJoystick = SKSpriteNode(imageNamed: "joystick")
    var attackJoystick = SKSpriteNode(imageNamed: "joystick")
    var transitionView = SKSpriteNode()
    
    var healthBar = SKSpriteNode()
    var armorBar = SKSpriteNode()
    
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
        
        moveJoystick.name = "moveJoystick"
        moveJoystick.position = CGPoint(x: size.width * 0.13, y: size.width * 0.13)
        moveJoystick.size = CGSize(width: size.width * 0.26, height: size.width * 0.26)
        moveJoystick.userInteractionEnabled = false
        moveJoystick.alpha = 0.25
        addChild(moveJoystick)
        
        attackJoystick.name = "attackJoystick"
        attackJoystick.position = CGPoint(x: size.width * 0.87, y: size.width * 0.13)
        attackJoystick.size = CGSize(width: size.width * 0.26, height: size.width * 0.26)
        attackJoystick.userInteractionEnabled = false
        attackJoystick.alpha = 0.25
        addChild(attackJoystick)
        
        addChild(backgroundMusic)
        // 2
        backgroundColor = SKColor.blackColor()
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
        if(canDoStuff)
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
    }
    
    //Move Function
    func move()
    {
        if canDoStuff
        {
            //print(map.getCurr())
            var newPoint = moveJoystick.position - moveLoc!
            newPoint.y *= -1
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
            
            realDest.x = max(0,realDest.x)              // This keeps the player inside the screen bounds
            realDest.x = min(size.width, realDest.x)
            realDest.y = max(0, realDest.y)
            realDest.y = min(size.height, realDest.y)
            
            //METHODS ARE BEING CALLED TWICE
            //If you go slow it works as intended, only when moving quickly is it a problem
            
            var door = false
            if realDest.y <= 0 // Bottom
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getDown() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: size.width * 0.5, y: size.height)
                    map.update(map.getDown()!)
                    door = true
                }
            }
            else if realDest.y >= size.height // Top
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getUp() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: size.width * 0.5, y: 0)
                    map.update(map.getUp()!)
                    door = true
                }
            }
            else if realDest.x <= 0 // Left
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getLeft() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: size.width, y: size.height * 0.5)
                    print("changed location")
                    map.update(map.getLeft()!)
                    door = true
                }
            }
            else if realDest.x >= size.width // Right
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getRight() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: 0, y: size.height * 0.5)
                    map.update(map.getRight()!)
                    door = true
                }
            }
            print(door)
            if !door{
                let actionMove = SKAction.moveTo(realDest, duration: 0.1)
                player.runAction(actionMove)
                realDest.y = realDest.y + player.size.height/2
            }
        }
    }
    
    /////////////////////////////////       TOUCH FUNCTIONS        /////////////////////////////////
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let positionInScene = touches.first?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene!)
        
        if(!attackTimer.valid)
        {
            if (touchedNode.name == "attackJoystick")
            {
                attackLoc = positionInScene
                createShuriken()
                attackTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.createShuriken), userInfo: nil, repeats: true)
            }
        }
        if(!moveTimer.valid)
        {
            if (touchedNode.name == "moveJoystick")
            {
                moveLoc = positionInScene
                moveTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.move), userInfo: nil, repeats: true)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var stopMove = true
        var stopAttack = true
        print("moved")
        for touch in (event?.allTouches())!
        {
            let touchedNode = self.nodeAtPoint(touch.locationInNode(self))
            if(touchedNode.name == "moveJoystick")
            {
                moveLoc = touch.locationInNode(self)
                stopMove = false
            }
            if(touchedNode.name == "attackJoystick")
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
        let positionInScene = touches.first?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene!)
        
        if(touchedNode.name == "moveJoystick")
        {
            moveTimer.invalidate()
        }
        if(touchedNode.name == "attackJoystick")
        {
            attackTimer.invalidate()
        }
    }
    
    /////////////////////////        LOCATION FUNCTIONS          //////////////////////////////
    
    //    func isInMove(loc: CGPoint) -> Bool
    //    {
    //        let wid = moveJoystick.frame.width
    //        let realFrame = CGRect(x: 0, y: 0, width: wid, height: wid)
    //        if(loc.x < realFrame.maxX && loc.x > realFrame.minX && loc.y < realFrame.maxY && loc.y > realFrame.minY)
    //        {
    //            return true
    //        }
    //        return false
    //    }
    //
    //    func isInAttack(loc: CGPoint) -> Bool
    //    {
    //        let wid = attackJoystick.frame.width
    //        let realFrame = CGRect(x: wid * 4, y: 0, width: wid, height: wid)
    //        if(loc.x < realFrame.maxX && loc.x > realFrame.minX && loc.y < realFrame.maxY && loc.y > realFrame.minY)
    //        {
    //            return true
    //        }
    //        return false
    //    }
    
    func transitionClose()  //Work in Progress... player x and y values need to be adjusted
    {
        canDoStuff = false
        transitionView = SKSpriteNode(color: UIColor.blackColor(), size: size)
        transitionView.setScale(2)
        transitionView.zPosition = 10
        transitionView.centerRect = self.view!.bounds
        transitionView.position = self.position
        transitionView.alpha = 0
        addChild(transitionView)
        transTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.incWidth), userInfo: nil, repeats: true)
    }
    
    func transitionOpen()
    {
        transTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.decWidth), userInfo: nil, repeats: true)
    }
    
    func incWidth()
    {
        if(transitionView.alpha >= 1)
        {
            player.position = moveTo
            transTimer.invalidate()
            transitionOpen()
        }
        transitionView.alpha += 0.1
    }
    
    func decWidth()
    {
        if(transitionView.alpha <= 0)
        {
            transTimer.invalidate()
            canDoStuff = true
            transitionView.removeFromParent()
        }
        transitionView.alpha -= 0.1
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
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func playerDidCollideWithMonster(monster:SKSpriteNode, player:SKSpriteNode) {
        monster.removeFromParent()
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
            if(secondBody.node != nil && firstBody.node != nil)
            {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
            }
        }
        else if ((firstBody.categoryBitMask == 1) &&
            (secondBody.categoryBitMask == 3))
        {
            if firstBody.node != nil
            {
                playerDidCollideWithMonster(firstBody.node as! SKSpriteNode, player: secondBody.node as! SKSpriteNode)
            }
        }
    }
    
    /////////////////////////////////       MENU FUNCTIONS       ///////////////////////////
    
    func openMenu()
    {
        let menu = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
        menu.backgroundColor = UIColor.brownColor()
        view?.addSubview(menu)
    }
    
    /////////////////////////////////       HELPER FUNCTIONS       ///////////////////////////
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
}
