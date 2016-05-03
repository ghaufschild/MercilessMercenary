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
    static let Chest     : UInt32 = 0b100     // 4
    static let Door      : UInt32 = 0b101     // 5
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
    var moveView: UIView!
    var attackView: UIView!
    var mapView: UIView!
    var inventoryView: UIView!
    var chestNotification: UIView!
    var transitionView: UIView!
    var rewardNotifications: [UIView] = []
    var toggleSoundButton = UIButton()
    var toggleMusicButton = UIButton()
    
    var moveHold: UILongPressGestureRecognizer!
    var attackHold: UILongPressGestureRecognizer!
    var changeRewards: UITapGestureRecognizer!
    
    let player = SKSpriteNode(imageNamed: "player")
    let chest = SKSpriteNode(imageNamed: "ChestLegendary")
    var menuButton = SKSpriteNode()
    
    var heartBar: UIView!
    var heartsLeft = 5.0
    
    var doors = [SKSpriteNode]()
    
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
        
        self.view?.multipleTouchEnabled = true
        
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        let backgroundImage = SKSpriteNode(imageNamed: "ground")
        backgroundImage.size = self.scene!.size
        backgroundImage.zPosition = -1
        backgroundImage.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        backgroundImage.zPosition = -1
        addChild(backgroundImage)
        
        menuButton.name = "menu"
        menuButton.position = CGPoint(x: size.width * 0.5, y: size.height * 0.95)
        menuButton.size = CGSize(width: size.width * 0.2, height: size.height * 0.1)
        menuButton.userInteractionEnabled = false
        menuButton.alpha = 0.5
        menuButton.color = SKColor.blueColor()
        addChild(menuButton)
        
        
        let playerText = SKTexture(CGImage: (UIImage(named: "player")?.CGImage)!)
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        player.physicsBody = SKPhysicsBody(texture: playerText, size: playerText.size())
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        menu = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
        menu.backgroundColor = UIColor.brownColor()
        
        moveHold = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.moveOnTouch))
        moveHold.minimumPressDuration = 0.0
        attackHold = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.attackOnTouch))
        attackHold.minimumPressDuration = 0.0
        
        let buttonWid = size.width * 0.2
        
        moveView = UIView(frame: CGRect(x: 0, y: size.height - buttonWid, width: buttonWid, height: buttonWid))
        moveView.addGestureRecognizer(moveHold)
        let moveImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWid, height: buttonWid))
        moveImageView.image = UIImage(named: "joystick")
        moveView.addSubview(moveImageView)
        
        
        attackView = UIView(frame: CGRect(x: size.width - buttonWid, y: size.height - buttonWid, width: buttonWid, height: buttonWid))
        attackView.addGestureRecognizer(attackHold)
        let attackImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWid, height: buttonWid))
        attackImageView.image = UIImage(named: "joystick")
        attackView.addSubview(attackImageView)
        
        heartBar = UIView(frame: CGRect(x: size.width * 0.74, y: size.width * 0.01, width: size.width * 0.25, height: size.width * 0.1))
        setHearts()
        view.addSubview(heartBar)
        
        let testLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        testLabel.backgroundColor = UIColor.clearColor()
        moveView.addSubview(testLabel)
        
        let closeMenuButton = UIButton(frame: CGRect(x: menu.frame.width - menu.frame.height * 0.225, y: menu.frame.height * 0.075, width: menu.frame.height * 0.15, height: menu.frame.height * 0.15))
        closeMenuButton.backgroundColor = UIColor.redColor()
        closeMenuButton.setTitle("X", forState: .Normal)
        closeMenuButton.titleLabel?.textColor = UIColor.blackColor()
        closeMenuButton.layer.cornerRadius = closeMenuButton.frame.width * 0.5
        closeMenuButton.addTarget(self, action: #selector(GameScene.closeMenu), forControlEvents: .TouchUpInside)
        menu.addSubview(closeMenuButton)
        
        let exitButton = UIButton(frame: CGRect(x: menu.frame.width * 0.7, y: menu.frame.height * 0.85, width: menu.frame.width * 0.2, height: menu.frame.height * 0.1))
        exitButton.backgroundColor = UIColor.redColor()
        exitButton.setTitle("EXIT", forState: .Normal)
        exitButton.titleLabel?.textColor = UIColor.blackColor()
        exitButton.addTarget(self, action: #selector(GameScene.exitGame), forControlEvents: .TouchUpInside)
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
        
        view.addSubview(attackView)
        view.addSubview(moveView)
        
        if map.getUp() != nil
        {
            setDoor("up")
        }
        if map.getRight() != nil
        {
            setDoor("right")
        }
        if map.getDown() != nil
        {
            setDoor("down")
        }
        if map.getLeft() != nil
        {
            setDoor("left")
        }
        
        // 4
        addChild(player)
        
        chest.position = CGPoint(x: size.width * 0.1, y: size.height * 0.9)
        chest.size = CGSize(width: size.width * 0.04, height: size.height * 0.04)
        chest.physicsBody = SKPhysicsBody(rectangleOfSize: chest.size)
        chest.physicsBody?.dynamic = true
        chest.physicsBody?.categoryBitMask = PhysicsCategory.Chest
        chest.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        chest.physicsBody?.collisionBitMask = PhysicsCategory.None
        chest.physicsBody?.usesPreciseCollisionDetection = false
        chest.name = "legendary"
        addChild(chest)
        
        changeRewards = UITapGestureRecognizer(target: self, action: #selector(GameScene.continueRewards))
        
        chestNotification = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
        chestNotification.backgroundColor = UIColor.brownColor()
        chestNotification.addGestureRecognizer(changeRewards)
        
        let congratsLabel = UILabel(frame: CGRect(x: chestNotification.frame.width * 0.2, y: chestNotification.frame.height * 0.075, width: chestNotification.frame.width * 0.6, height: chestNotification.frame.height * 0.1))
        congratsLabel.text = "CONGRATULATIONS"
        congratsLabel.adjustsFontSizeToFitWidth = true
        congratsLabel.textAlignment = .Center
        chestNotification.addSubview(congratsLabel)
        
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
            if(settings.soundOn)
            {
                runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
            }
            
            runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
            
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = player.position
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            var actualCenter = attackView.center
            actualCenter.y = (size.height - actualCenter.y)
            actualCenter.x = (size.width - actualCenter.x)
            var offset =  actualCenter - attackLoc
            offset.x *= -1
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
            var actualCenter = moveView.center
            actualCenter.y = (size.height - actualCenter.y)
            let newPoint = actualCenter - moveLoc
            let xOffset = newPoint.x
            let yOffset = newPoint.y
            let absX = abs(xOffset)
            let absY = abs(yOffset)
            var realDest = newPoint
            
            let moveDist: CGFloat = 10
            let diagMove: CGFloat = moveDist/sqrt(2)
            
            if xOffset > 0 && absX >= absY // Left
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
            else if yOffset > 0 && absX <= absY // Up
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
            else if xOffset < 0 && absX >= absY // Right
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
            else if yOffset < 0 && absX <= absY // Down
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
            
            if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && (map.getDown() != nil || map.getUp() != nil) // In the middle
            {
                realDest.x = max(0,realDest.x)
                realDest.x = min(size.width, realDest.x)
            }
            else if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && (map.getLeft() != nil || map.getRight() != nil) // In the middle
            {
                realDest.y = max(0, realDest.y)
                realDest.y = min(size.height, realDest.y)
            }
            else
            {
                realDest.x = max(size.width * 0.1,realDest.x)
                realDest.x = min(size.width * 0.9, realDest.x)
                realDest.y = max(size.height * 0.1, realDest.y)
                realDest.y = min(size.height * 0.9, realDest.y)
            }
            var door = false
            if realDest.y <= 0 // Bottom
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getDown() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.9 - player.frame.height * 0.5)
                    map.update(map.getDown()!)
                    door = true
                }
            }
            else if realDest.y >= size.height // Top
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getUp() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.1 + player.frame.height * 0.5)
                    map.update(map.getUp()!)
                    door = true
                }
            }
            else if realDest.x <= 0 // Left
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getLeft() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: size.width * 0.9 - player.frame.width * 0.5, y: size.height * 0.5)
                    map.update(map.getLeft()!)
                    door = true
                }
            }
            else if realDest.x >= size.width // Right
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getRight() != nil // In the middle
                {
                    transitionClose()
                    moveTo = CGPoint(x: size.width * 0.1 + player.frame.width * 0.5, y: size.height * 0.5)
                    map.update(map.getRight()!)
                    door = true
                }
            }
            if !door{
                let actionMove = SKAction.moveTo(realDest, duration: 0.1)
                player.runAction(actionMove)
            }
        }
    }
    
    /////////////////////////////////       TOUCH FUNCTIONS        /////////////////////////////////
    
    func moveOnTouch()
    {
        if(!moveTimer.valid)
        {
            moveLoc = moveHold.locationInView(moveView)
            moveTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.move), userInfo: nil, repeats: true)
            move()
        }
        else if(moveHold.state == UIGestureRecognizerState.Changed)
        {
            moveLoc = moveHold.locationInView(moveView)
        }
        else
        {
            moveTimer.invalidate()
        }
    }
    
    func attackOnTouch()
    {
        if(!attackTimer.valid)
        {
            attackLoc = attackHold.locationInView(attackView)
            attackTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.createShuriken), userInfo: nil, repeats: true)
            createShuriken()
        }
        else if(attackHold.state == UIGestureRecognizerState.Changed)
        {
            attackLoc = attackHold.locationInView(attackView)
        }
        else
        {
            attackTimer.invalidate()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let positionInScene = touches.first?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene!)
        
        if(touchedNode.name == "menu")
        {
            if(!self.paused)
            {
                openMenu()
            }
        }
    }
    
    /////////////////////////        TRANSITION FUNCTIONS          //////////////////////////////
    
    func transitionClose()
    {
        canDoStuff = false
        transitionView = UIView(frame: CGRect(x: 0, y: 0, width: size.width*2.5, height: size.width*2.5))
        transitionView.layer.cornerRadius = transitionView.frame.width * 0.5
        transitionView.layer.backgroundColor = UIColor.clearColor().CGColor
        transitionView.layer.borderColor = UIColor.blackColor().CGColor
        transitionView.layer.borderWidth = 10
        transitionView.clipsToBounds = true
        transitionView.center = player.position
        fixY()
        self.view?.addSubview(transitionView)
        transTimer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(GameScene.incWidth), userInfo: nil, repeats: true)
    }
    
    func transitionOpen()
    {
        removeChildrenInArray(doors)
        doors.removeAll()
        if map.getUp() != nil
        {
            setDoor("up")
        }
        if map.getRight() != nil
        {
            setDoor("right")
        }
        if map.getDown() != nil
        {
            setDoor("down")
        }
        if map.getLeft() != nil
        {
            setDoor("left")
        }
        transTimer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(GameScene.decWidth), userInfo: nil, repeats: true)
    }
    
    func incWidth()
    {
        transitionView.layer.borderWidth += transitionView.frame.width * 0.01
        if(transitionView.layer.borderWidth >= transitionView.frame.width * 0.5)
        {
            transTimer.invalidate()
            player.position = moveTo
            transitionView.center = player.position
            fixY()
            transitionOpen()
        }
    }
    
    func decWidth()
    {
        transitionView.layer.borderWidth -= transitionView.frame.width * 0.01
        if(transitionView.layer.borderWidth <= 0)
        {
            transTimer.invalidate()
            canDoStuff = true
            transitionView.removeFromSuperview()
        }
    }
    
    func fixY()
    {
        transitionView.center.y = view!.frame.maxY - transitionView.center.y
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
        let actualY = random(min: size.height * 0.1 + monster.size.height/2, max: size.height * 0.9 - monster.size.height/2)
        
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
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        projectile.removeFromParent()
        monster.removeFromParent()
        if heartsLeft < 5
        {
            heartsLeft += 0.5
            setHearts()
        }
    }
    
    func playerDidCollideWithMonster(monster: SKSpriteNode, player: SKSpriteNode) {
        monster.removeFromParent()
        heartsLeft -= 0.5
        if heartsLeft >= 0
        {
            setHearts()
        }
        if heartsLeft == 0
        {
            exitGame()
        }
    }
    
    func playerDidCollideWithChest(player: SKSpriteNode, chest: SKSpriteNode)
    {
        chest.removeFromParent()
        openChest()
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 1 is monster
        // 2 is projectile
        // 3 is player
        // 4 is chest
        // 5 is door
        if ((firstBody.categoryBitMask == 1) &&     //monster and projectile
            (secondBody.categoryBitMask == 2)) {
            if(secondBody.node != nil && firstBody.node != nil)
            {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
            }
        }
        else if ((firstBody.categoryBitMask == 1) &&    //monster and player
            (secondBody.categoryBitMask == 3))
        {
            if firstBody.node != nil
            {
                playerDidCollideWithMonster(firstBody.node as! SKSpriteNode, player: secondBody.node as! SKSpriteNode)
            }
        }
        else if(firstBody.categoryBitMask == 3 && secondBody.categoryBitMask == 4)  //player and chest
        {
            if(secondBody.node != nil)
            {
                playerDidCollideWithChest(firstBody.node as! SKSpriteNode, chest: secondBody.node as! SKSpriteNode)
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
        let closeMapButton = UIButton(frame: CGRect(x: mapView.frame.width - mapView.frame.height * 0.225, y: mapView.frame.height * 0.075, width: mapView.frame.height * 0.15, height: mapView.frame.height * 0.15))
        closeMapButton.addTarget(self, action: #selector(GameScene.closeMap), forControlEvents: .TouchUpInside)
        closeMapButton.backgroundColor = UIColor.redColor()
        closeMapButton.setTitle("X", forState: .Normal)
        closeMapButton.layer.cornerRadius = closeMapButton.frame.width * 0.5
        mapView.addSubview(closeMapButton)
        
        let maxW = CGFloat(map.getWidth()) + 1
        let maxW2 = maxW + 1
        let max2 = maxW * 2
        
        print(map.getBoss())
        
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
            if(spot.equals(map.getBoss()))
            {
                let symbol = UIView(frame: CGRect(x: place.frame.width * 0.4, y: place.frame.height * 0.3, width: place.frame.width * 0.2, height: place.frame.height * 0.4))
                symbol.backgroundColor = UIColor.blackColor()
                place.addSubview(symbol)
            }
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
            if(spot.equals(map.getKey()))
            {
                let symbol = UIView(frame: CGRect(x: place.frame.width * 0.4, y: place.frame.height * 0.3, width: place.frame.width * 0.2, height: place.frame.height * 0.4))
                symbol.backgroundColor = UIColor.greenColor()
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
        inventoryView.backgroundColor = UIColor.brownColor()
        let closeInventoryButton = UIButton(frame: CGRect(x: mapView.frame.width - mapView.frame.height * 0.225, y: mapView.frame.height * 0.075, width: mapView.frame.height * 0.1, height: mapView.frame.height * 0.1))
        closeInventoryButton.addTarget(self, action: #selector(GameScene.closeInventory), forControlEvents: .TouchUpInside)
        closeInventoryButton.backgroundColor = UIColor.redColor()
        closeInventoryButton.setTitle("X", forState: .Normal)
        closeInventoryButton.layer.cornerRadius = closeInventoryButton.frame.width * 0.5
        inventoryView.addSubview(closeInventoryButton)
        menu.addSubview(inventoryView)
    }
    
    func closeInventory()
    {
        inventoryView.removeFromSuperview()
    }
    
    func exitGame()
    {
        menu.removeFromSuperview()
        attackView.removeFromSuperview()
        moveView.removeFromSuperview()
        heartBar.removeFromSuperview()
        save()
        let scene = CharacterScene(size: view!.bounds.size)
        scene.scaleMode = .ResizeFill
        view!.presentScene(scene)
    }
    
    /////////////////////////////////       CHEST FUNCTIONS        ///////////////////////////
    
    //Things in chests: Health Potions, Speed Potions, Damage Potions, etc.                                         1
    //                  Sword Upgrade, Bow Upgrade, Fire Ball Upgrade, Shuriken Upgrade, Crit Chance Upgrade        2
    //                  Armor Upgrade, Speed Upgrade, Health Upgrade, Block Chance Upgrade                          3
    
    func openChest()
    {
        self.paused = true
        openNotify(chest.name!)
    }
    
    func openNotify(chestRarity: String)    //Array of bonuses
    {
        var times = 0
        var itemNum: [Int] = []
        var pictures: [UIImage] = []
        
        //Set up UIView - Image, congrats, close
        if(chestRarity == "common")
        {
            times = 1
        }
        else if(chestRarity == "uncommon")
        {
            times = 2
        }
        else if(chestRarity == "rare")
        {
            times = 4
        }
        else if(chestRarity == "legendary")
        {
            times = 7
        }
        
        for _ in 0...times
        {
            let itemType = chestType()
            switch itemType
            {
            case 1:
                let num = randomPotion()
                itemNum.append(num)
                pictures.append(findPhoto(num))
            case 2:
                let num = randomAttack()
                itemNum.append(num)
                pictures.append(findPhoto(num))
            default:
                let num = randomDefense()
                itemNum.append(num)
                pictures.append(findPhoto(num))
            }
        }
        
        var timesAppear: [Int] = []
        var tempSizeOne: Int = itemNum.count
        var i = 0
        while(i < (tempSizeOne - 1))
        {
            timesAppear.append(1)
            var j = i + 1
            while(j < tempSizeOne)
            {
                if(itemNum[i] == itemNum[j])
                {
                    timesAppear[i] += 1
                    itemNum.removeAtIndex(j)
                    pictures.removeAtIndex(j)
                    tempSizeOne -= 1
                }
                j += 1
            }
            i += 1
        }
        
        for things in 0..<timesAppear.count
        {
            let reward = UIView(frame: CGRect(x: 0, y: chestNotification.frame.height * 0.1, width: chestNotification.frame.width, height: chestNotification.frame.height * 0.9))
            let upgrade = UIImageView(frame: CGRect(x: chestNotification.frame.width * 0.1, y: chestNotification.frame.height * 0.2, width: chestNotification.frame.width * 0.5, height: chestNotification.frame.height * 0.6))
            upgrade.contentMode = .ScaleAspectFit
            upgrade.image = pictures[things]
            upgrade.backgroundColor = UIColor.brownColor()
            let arrow = UIImageView(frame: CGRect(x: chestNotification.frame.width * 0.65, y: chestNotification.frame.height * 0.6, width: chestNotification.frame.width * 0.1, height: chestNotification.frame.height * 0.2))
            arrow.image = UIImage(named: "Arrow")
            let amount = UILabel(frame: CGRect(x: chestNotification.frame.width * 0.8, y: chestNotification.frame.height * 0.7, width: chestNotification.frame.width * 0.1, height: chestNotification.frame.height * 0.1))
            amount.text = "\(timesAppear[things])"
            amount.adjustsFontSizeToFitWidth = true
            amount.backgroundColor = UIColor.brownColor()
            reward.addSubview(upgrade)
            reward.addSubview(arrow)
            reward.addSubview(amount)
            chestNotification.addSubview(reward)
            rewardNotifications.append(reward)
        }
        view?.addSubview(chestNotification)
    }
    
    func continueRewards()
    {
        if rewardNotifications.count > 0
        {
            rewardNotifications.last?.removeFromSuperview()
            rewardNotifications.removeLast()
            if rewardNotifications.count < 1
            {
                let closeChestButton = UIButton(frame: CGRect(x: chestNotification.frame.width - chestNotification.frame.height * 0.225, y: chestNotification.frame.height * 0.075, width: chestNotification.frame.height * 0.15, height: chestNotification.frame.height * 0.15))
                closeChestButton.backgroundColor = UIColor.redColor()
                closeChestButton.setTitle("X", forState: .Normal)
                closeChestButton.titleLabel?.textColor = UIColor.blackColor()
                closeChestButton.layer.cornerRadius = closeChestButton.frame.width * 0.5
                closeChestButton.addTarget(self, action: #selector(GameScene.closeChest), forControlEvents: .TouchUpInside)
                chestNotification.addSubview(closeChestButton)
                
            }
        }
    }
    
    func findPhoto(type: Int) -> UIImage
    {
        switch type
        {
        case 1:
            return UIImage(named: "HealthPot")!
        case 2:
            return UIImage(named: "SpeedPot")!
        case 3:
            return UIImage(named: "DamagePot")!
        case 4:
            return UIImage(named: "BlockPot")!
        case 5:
            return UIImage(named: "Sword")!
        case 6:
            return UIImage(named: "Bow and Arrow")!
        case 7:
            return UIImage(named: "Fireball")!
        case 8:
            return UIImage(named: "Shuriken")!
        case 9:
            return UIImage(named: "Crit Chance")!
        case 10:
            return UIImage(named: "Armor")!
        case 11:
            return UIImage(named: "Speed")!
        case 12:
            return UIImage(named: "Health")!
        default:
            return UIImage(named: "Block")!
        }
    }
    
    func chestType() -> Int
    {
        let chestType = Int(arc4random_uniform(100))
        if(chestType < 25)  //25% chance
        {
            return 3    //Defense
        }
        else if(chestType < 50) //25% chance
        {
            return 2    //Attack
        }
        else    //50% chance
        {
            return 1    //Potions
        }
    }
    
    func randomPotion() -> Int
    {
        let chestType = Int(arc4random_uniform(100))
        if(chestType < 40)  //40% chance
        {
            return 1    //Health Potions
        }
        else if(chestType < 60) //20% chance
        {
            return 2    //Speed Potions
        }
        else if(chestType < 80) //20% chance
        {
            return 3    //Damage Potions
        }
        else    //20% chance
        {
            return 4    //Block Chance Potions
        }
    }
    
    func randomAttack() -> Int
    {
        let chestType = Int(arc4random_uniform(100))
        if(chestType < 23)  //23% chance
        {
            return 5    //Sword Upgrade
        }
        else if(chestType < 46) //23% chance
        {
            return 6    //Bow Upgrade
        }
        else if(chestType < 69) //23% chance
        {
            return 7    //Fireball Upgrade
        }
        else if(chestType < 92) //23% chance
        {
            return 8    //Shuriken Upgrade
        }
        else    //8% chance
        {
            return 9    //Crit Chance Upgrade
        }
    }
    
    func randomDefense() -> Int
    {
        let chestType = Int(arc4random_uniform(100))
        if(chestType < 40)  //40% chance
        {
            return 10    //Armor Upgrade
        }
        else if(chestType < 60) //20% chance
        {
            return 11    //Speed Upgrade
        }
        else if(chestType < 80) //20% chance
        {
            return 12    //Health Upgrade
        }
        else    //20% chance
        {
            return 13    //Block Chance Upgrade
        }
    }
    
    func closeChest()
    {
        chestNotification.removeFromSuperview()
        self.paused = false
    }
    
    /////////////////////////////////       HELPER FUNCTIONS       ///////////////////////////
    
    func setHearts()
    {
        for heart in heartBar.subviews
        {
            heart.removeFromSuperview()
        }
        let hearts = Int(heartsLeft)
        for index in 0..<hearts
        {
            let CGIndex = CGFloat(index)
            var heartPicture: UIImageView
            heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*CGIndex, y: 0, width: heartBar.frame.width * 0.2, height: heartBar.frame.height * 0.5))
            heartPicture.image = UIImage(named: "8BitHeart")
            heartBar.addSubview(heartPicture)
        }
        let half = heartsLeft - Double(hearts)
        if half == 0.5
        {
            var heartPicture: UIImageView
            heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*CGFloat(hearts), y: 0, width: heartBar.frame.width * 0.2, height: heartBar.frame.height * 0.5))
            heartPicture.image = UIImage(named: "8BitHeartHalf")
            heartBar.addSubview(heartPicture)
        }
    }
    
    func setDoor(place: String)
    {
        let door = SKSpriteNode()
        door.color = UIColor.lightGrayColor()
        doors.append(door)
        switch place {
        case "up":
            door.size = CGSize(width: view!.bounds.width*0.1, height: view!.bounds.height*0.1)
            door.position = CGPoint(x: view!.bounds.width * 0.5, y: view!.bounds.height-view!.bounds.height*0.05)
        case "right":
            door.size = CGSize(width: view!.bounds.height*0.1, height: view!.bounds.width*0.1)
            door.position = CGPoint(x: view!.bounds.width - view!.bounds.height*0.05, y: view!.bounds.height*0.5)
        case "down":
            door.size = CGSize(width: view!.bounds.width*0.1, height: view!.bounds.height*0.1)
            door.position = CGPoint(x: view!.bounds.width * 0.5, y: view!.bounds.height*0.05)
        case "left":
            door.size = CGSize(width: view!.bounds.height*0.1, height: view!.bounds.width*0.1)
            door.position = CGPoint(x: view!.bounds.height * 0.05, y: view!.bounds.height*0.5)
        default:
            door.size = CGSize(width: view!.bounds.width*0.1, height: view!.bounds.height*0.1)
            door.position = CGPoint(x: view!.bounds.width * 0.5, y: view!.bounds.height-view!.bounds.height*0.05)
        }
        addChild(door)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func save()
    {
        settings.save()
        scene?.removeFromParent()
    }
}