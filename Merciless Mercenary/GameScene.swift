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
    var settings: Settings!
    
    var canDoStuff: Bool = true     //For checking for transitions, eventually move elsewhere
    
    var attackTimer = NSTimer()
    var moveTimer = NSTimer()
    var transTimer = NSTimer()
    
    var moveLoc: CGPoint!
    var attackLoc: CGPoint!
    var moveTo: CGPoint!
    
    var menu: UIView!
    var mapView: UIView!
    var inventoryView: UIView!
    var toggleSoundButton = UIButton()
    var toggleMusicButton = UIButton()
    
    let player = SKSpriteNode(imageNamed: "player")
    var moveJoystick = SKSpriteNode(imageNamed: "joystick")
    var attackJoystick = SKSpriteNode(imageNamed: "joystick")
    var transitionView = SKSpriteNode()
    var menuButton = SKSpriteNode()
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    
    //View Did Load
    override func didMoveToView(view: SKView) {
        
        if let settings = Settings.loadSaved()
        {
            self.settings = settings
        }
        else
        {
            let settings: Settings = Settings()
            settings.save()
            self.settings = settings
        }
        
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
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
        
        menuButton.name = "menu"
        menuButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.95)
        menuButton.size = CGSize(width: size.width * 0.2, height: size.height * 0.1)
        menuButton.userInteractionEnabled = false
        menuButton.alpha = 0.5
        menuButton.color = SKColor.blueColor()
        addChild(menuButton)
        
        
        let playerText = SKTexture(CGImage: (UIImage(named: "player")?.CGImage)!)
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.physicsBody = SKPhysicsBody(texture: playerText, size: playerText.size())
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        menu = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
        menu.backgroundColor = UIColor.brownColor()
        
        let closeMenuButton = UIButton(frame: CGRect(x: menu.frame.width * 0.1, y: menu.frame.height * 0.85, width: menu.frame.width * 0.2, height: menu.frame.height * 0.1))
        closeMenuButton.backgroundColor = UIColor.redColor()
        closeMenuButton.setTitle("CLOSE", forState: .Normal)
        closeMenuButton.titleLabel?.textColor = UIColor.blackColor()
        closeMenuButton.addTarget(self, action: #selector(GameScene.closeMenu), forControlEvents: .TouchUpInside)
        menu.addSubview(closeMenuButton)
        
        let exitButton = UIButton(frame: CGRect(x: menu.frame.width * 0.2, y: menu.frame.height * 0.85, width: menu.frame.width * 0.2, height: menu.frame.height * 0.1))
        exitButton.backgroundColor = UIColor.redColor()
        exitButton.setTitle("CLOSE", forState: .Normal)
        exitButton.titleLabel?.textColor = UIColor.blackColor()
        exitButton.addTarget(self, action: #selector(GameScene.closeMenu), forControlEvents: .TouchUpInside)
        menu.addSubview(exitButton)
        
        let menuTitle = UILabel(frame: CGRect(x: menu.frame.width * 0.4, y: menu.frame.height * 0.05, width: menu.frame.width * 0.2, height: menu.frame.height * 0.075))
        menuTitle.text = "MENU"
        menuTitle.textAlignment = .Center
        menuTitle.adjustsFontSizeToFitWidth = true
        menu.addSubview(menuTitle)
        
        let mapButton = UIButton(frame: CGRect(x: menu.frame.width * 0.4, y: menu.frame.height * 0.2, width: menu.frame.width * 0.2, height: menu.frame.height * 0.1))
        mapButton.setTitle("MAP", forState: .Normal)
        mapButton.layer.cornerRadius = mapButton.frame.width * 0.1
        mapButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        mapButton.layer.backgroundColor = UIColor(red: 0.6, green: 0.45, blue: 0.25, alpha: 1).CGColor
        mapButton.layer.borderWidth = mapButton.frame.height * 0.1
        mapButton.addTarget(self, action: #selector(GameScene.openMap), forControlEvents: .TouchUpInside)
        menu.addSubview(mapButton)
        
        let inventoryButton = UIButton(frame: CGRect(x: menu.frame.width * 0.35, y: menu.frame.height * 0.4, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        inventoryButton.setTitle("INVENTORY", forState: .Normal)
        inventoryButton.layer.cornerRadius = mapButton.frame.width * 0.1
        inventoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        inventoryButton.layer.backgroundColor = UIColor(red: 0.6, green: 0.45, blue: 0.25, alpha: 1).CGColor
        inventoryButton.layer.borderWidth = mapButton.frame.height * 0.1
        inventoryButton.addTarget(self, action: #selector(GameScene.openInventory), forControlEvents: .TouchUpInside)
        menu.addSubview(inventoryButton)
        
        toggleMusicButton = UIButton(frame: CGRect(x: menu.frame.width * 0.75, y: menu.frame.height * 0.55, width: menu.frame.height * 0.1, height: menu.frame.height * 0.1))
        toggleMusicButton.layer.cornerRadius = toggleMusicButton.frame.width * 0.5
        toggleMusicButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        toggleMusicButton.layer.backgroundColor = UIColor.greenColor().CGColor
        toggleMusicButton.layer.borderWidth = toggleMusicButton.frame.width * 0.1
        toggleMusicButton.addTarget(self, action: #selector(GameScene.toggleMusic), forControlEvents: .TouchUpInside)
        menu.addSubview(toggleMusicButton)
        
        let toggleMusicLabel = UILabel(frame: CGRect(x: menu.frame.width * 0.25, y: menu.frame.height * 0.55, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        toggleMusicLabel.text = "Toggle Music"
        menu.addSubview(toggleMusicLabel)
        
        toggleSoundButton = UIButton(frame: CGRect(x: menu.frame.width * 0.75, y: menu.frame.height * 0.7, width: menu.frame.height * 0.1, height: menu.frame.height * 0.1))
        toggleSoundButton.layer.cornerRadius = toggleMusicButton.frame.width * 0.5
        toggleSoundButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        toggleSoundButton.layer.backgroundColor = UIColor.greenColor().CGColor
        toggleSoundButton.layer.borderWidth = toggleSoundButton.frame.width * 0.1
        toggleSoundButton.addTarget(self, action: #selector(GameScene.toggleSound), forControlEvents: .TouchUpInside)
        menu.addSubview(toggleSoundButton)
        
        let toggleSoundLabel = UILabel(frame: CGRect(x: menu.frame.width * 0.25, y: menu.frame.height * 0.7, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        toggleSoundLabel.text = "Toggle Sound"
        menu.addSubview(toggleSoundLabel)
        
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
            
            if(settings.soundOn)
            {
                runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
            }
            
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
        
        if(touchedNode.name == "menu")
        {
            openMenu()
        }
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
            if(firstBody.node != nil)
            {
                playerDidCollideWithMonster(firstBody.node as! SKSpriteNode, player: secondBody.node as! SKSpriteNode)
            }
        }
        
    }
    
    /////////////////////////////////       MENU FUNCTIONS       ///////////////////////////
    
    func openMenu()
    {
        self.paused = true
        view?.addSubview(menu)
    }
    
    func closeMenu()
    {
        backgroundMusic.removeFromParent()
        menu.removeFromSuperview()
        self.paused = false
        if(settings.musicOn)
        {
            addChild(backgroundMusic)
        }
    }
    
    func toggleSound()
    {
        settings.soundOn = !settings.soundOn
        if(settings.soundOn)
        {
            toggleSoundButton.layer.backgroundColor = UIColor.greenColor().CGColor
        }
        else
        {
            toggleSoundButton.layer.backgroundColor = UIColor.redColor().CGColor
        }
    }
    
    func toggleMusic()
    {
        settings.musicOn = !settings.musicOn
        if(settings.musicOn)
        {
            toggleMusicButton.layer.backgroundColor = UIColor.greenColor().CGColor
            addChild(backgroundMusic)
        }
        else
        {
            toggleMusicButton.layer.backgroundColor = UIColor.redColor().CGColor
            backgroundMusic.removeFromParent()
        }
    }
    
    func openMap()
    {
        mapView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        mapView.backgroundColor = UIColor.brownColor()
        let closeMapButton = UIButton(frame: CGRect(x: mapView.frame.width * 0.1, y: mapView.frame.height * 0.85, width: mapView.frame.width * 0.2, height: mapView.frame.height * 0.1))
        closeMapButton.addTarget(self, action: #selector(GameScene.closeMap), forControlEvents: .TouchUpInside)
        closeMapButton.backgroundColor = UIColor.redColor()
        closeMapButton.setTitle("CLOSE", forState: .Normal)
        mapView.addSubview(closeMapButton)
        
        let maxW = CGFloat(map.getWidth()) + 1
        let maxW2 = maxW + 1
        let max2 = maxW * 2
        
        menu.addSubview(mapView)
        for spot in map.known
        {
            let x = CGFloat(spot.getCoor().0) * mapView.frame.width * 1/maxW + mapView.frame.width * 1/max2
            let y = CGFloat(spot.getCoor().1) * mapView.frame.height * 1/maxW + mapView.frame.width * 1/max2
            let width = mapView.frame.width * 1/maxW2
            let height = mapView.frame.height * 1/maxW2
            let place = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            place.layer.backgroundColor = UIColor.blackColor().CGColor
            place.layer.cornerRadius = place.frame.width * 0.2
            mapView.addSubview(place)
        }
        for spot in map.visited
        {
            let x = CGFloat(spot.getCoor().0) * mapView.frame.width * 1/maxW + mapView.frame.width * 1/max2
            let y = CGFloat(spot.getCoor().1) * mapView.frame.height * 1/maxW + mapView.frame.width * 1/max2
            let width = mapView.frame.width * 1/maxW2
            let height = mapView.frame.height * 1/maxW2
            let place = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            place.layer.backgroundColor = UIColor.lightGrayColor().CGColor
            if(spot.equals(map.getCurr()))
            {
                place.layer.backgroundColor = UIColor.whiteColor().CGColor
            }
            if(spot.equals(map.getSpawn()))
            {
                let symbol = UIView(frame: CGRect(x: place.frame.width * 0.4, y: place.frame.height * 0.3, width: place.frame.width * 0.2, height: place.frame.height * 0.4))
                symbol.backgroundColor = UIColor.yellowColor()
                place.addSubview(symbol)
            }
            place.layer.cornerRadius = place.frame.width * 0.2
            mapView.addSubview(place)
        }
    }
    
    func closeMap()
    {
        mapView.removeFromSuperview()
    }
    
    func openInventory()
    {
        inventoryView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        inventoryView.backgroundColor = UIColor.redColor()
        let closeInventoryButton = UIButton(frame: CGRect(x: mapView.frame.width * 0.1, y: mapView.frame.height * 0.85, width: mapView.frame.width * 0.2, height: mapView.frame.height * 0.1))
        closeInventoryButton.addTarget(self, action: #selector(GameScene.closeInventory), forControlEvents: .TouchUpInside)
        closeInventoryButton.backgroundColor = UIColor.redColor()
        closeInventoryButton.setTitle("CLOSE", forState: .Normal)
        inventoryView.addSubview(closeInventoryButton)
        menu.addSubview(inventoryView)
    }
    
    func closeInventory()
    {
        inventoryView.removeFromSuperview()
    }
    
    func exitGame()
    {
        settings.save()
        
    }
    
    /////////////////////////////////       HELPER FUNCTIONS       ///////////////////////////
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
}