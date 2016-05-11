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
    static let Chest     : UInt32 = 0b100     // 4
    static let Door      : UInt32 = 0b101     // 5
    static let EnemyProjectile : UInt32 = 0b110 // 6
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /////////     MAP THINGS      //////////
    var map: Map!
    var settings: Settings!
    var character: Character!
    
    var canDoStuff: Bool = true
    var canAttack: Bool = true
    var canTakeDamage: Bool = true
    var roomCleared: Bool = true
    var hasKey = false
    
    var attackTimer = NSTimer()
    var moveTimer = NSTimer()
    var transTimer = NSTimer()
    var buffTimers: [NSTimer] = []
    var immortalTimer = NSTimer()
    var tempSpeed = 0
    var tempBlock = 0
    var tempDamage = 0
    var speedCounter = 0
    var blockCounter = 0
    var damageCounter = 0
    
    var moveLoc: CGPoint!
    var tempMove: CGPoint!
    var attackLoc: CGPoint!
    var tempAttack: CGPoint!
    var moveTo: CGPoint!
    
    var menu: UIView!
    var moveView: UIView!
    var moveJoystickOuter: UIImageView!
    var attackView: UIView!
    var attackJoystickOuter: UIImageView!
    var mapView: UIView!
    var potionsView: UIView!
    var skillsView: UIView!
    var chooseAttackView: UIView!
    var chestNotification: UIView!
    var transitionView: UIView!
    var speedPot: UIImageView!
    var speedPotBG: UIView!
    var blockPot: UIImageView!
    var blockPotBG: UIView!
    var damagePot: UIImageView!
    var damagePotBG: UIView!
    var rewardNotifications: [UIView] = []
    var toggleSoundButton = UIButton()
    var toggleMusicButton = UIButton()
    
    var moveHold: UILongPressGestureRecognizer!
    var attackHold: UILongPressGestureRecognizer!
    var changeRewards: UITapGestureRecognizer!
    
    let player = SKSpriteNode(imageNamed: "player")
    
    var menuButton = SKSpriteNode()
    
    var heartBar: UIView!
    
    var doors = [SKSpriteNode]()
    var enemyObjects = [Enemy]()
    var healthBars = [SKSpriteNode]()       //Shows health on enemy
    var attackEnemyTimer = NSTimer()        //Controls how enemies attack
    var moveEnemyTimer = NSTimer()          //Controls how enemies move
    var availableEnemyLocs = [CGPoint]()    //Locations that an enemy can spawn in
    var extraNodes = [SKSpriteNode]()       //Clear every time you enter a new room
    var extraViews = [UIView]()       //Clear every time you enter a new room
    var doorLocked: SKTexture!
    var doorUnlocked: SKTexture!
    
    let backgroundMusic = SKAudioNode(fileNamed: "eerie theme.mp3")
    
    var invincibleCounter = 0       //After taking damage
    
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
        
        character = settings.characters[settings.selectedPlayer]
        map = character.map
        
        self.view?.multipleTouchEnabled = true
        
        backgroundMusic.autoplayLooped = true
        backgroundMusic.name = "backgroundMusic"
        addChild(backgroundMusic)
        
        doorLocked = SKTexture(image: UIImage(named: "doorLocked")!)
        doorUnlocked = SKTexture(image: UIImage(named: "doorUnlocked")!)
        
        let backgroundImage = SKSpriteNode(imageNamed: "Ground")
        backgroundImage.size = self.scene!.size
        backgroundImage.zPosition = -10
        backgroundImage.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
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
        menu.layer.borderColor = UIColor.grayColor().CGColor
        menu.layer.borderWidth = menu.frame.width * 0.01
        menu.layer.backgroundColor = UIColor.brownColor().CGColor
        
        moveHold = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.moveOnTouch))
        moveHold.minimumPressDuration = 0.0
        attackHold = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.attackOnTouch))
        attackHold.minimumPressDuration = 0.0
        
        let buttonWid = size.width * 0.15
        
        moveView = UIView(frame: CGRect(x: 0, y: 0, width: size.width * 0.4, height: size.height))
        moveView.addGestureRecognizer(moveHold)
        moveJoystickOuter = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWid, height: buttonWid))
        moveJoystickOuter.image = UIImage(named: "joystick")
        moveJoystickOuter.alpha = 0.4
        
        
        attackView = UIView(frame: CGRect(x: size.width * 0.6, y: 0, width: size.width * 0.4, height: size.height))
        attackView.addGestureRecognizer(attackHold)
        attackJoystickOuter = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWid, height: buttonWid))
        attackJoystickOuter.image = UIImage(named: "joystick")
        attackJoystickOuter.alpha = 0.4
        
        heartBar = UIView(frame: CGRect(x: size.width * 0.74, y: size.width * 0.01, width: size.width * 0.25, height: size.width * 0.15))
        setHearts()
        view.addSubview(heartBar)
        
        let memeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        memeLabel.backgroundColor = UIColor.clearColor()
        moveView.addSubview(memeLabel)
        
        let closeMenuButton = UIButton(frame: CGRect(x: menu.frame.width - menu.frame.height * 0.2, y: menu.frame.height * 0.05, width: menu.frame.height * 0.15, height: menu.frame.height * 0.15))
        closeMenuButton.addTarget(self, action: #selector(GameScene.closeMenu), forControlEvents: .TouchUpInside)
        closeMenuButton.backgroundColor = UIColor.redColor()
        closeMenuButton.setTitle("X", forState: .Normal)
        closeMenuButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        closeMenuButton.layer.borderWidth = closeMenuButton.frame.width * 0.1
        menu.addSubview(closeMenuButton)
        
        let exitButton = UIButton(frame: CGRect(x: menu.frame.width * 0.7, y: menu.frame.height * 0.85, width: menu.frame.width * 0.2, height: menu.frame.height * 0.1))
        exitButton.backgroundColor = UIColor.redColor()
        exitButton.setTitle("QUIT", forState: .Normal)
        exitButton.titleLabel?.textColor = UIColor.blackColor()
        exitButton.addTarget(self, action: #selector(GameScene.exitGame), forControlEvents: .TouchUpInside)
        menu.addSubview(exitButton)
        
        let menuTitle = UILabel(frame: CGRect(x: menu.frame.width * 0.4, y: menu.frame.height * 0.05, width: menu.frame.width * 0.2, height: menu.frame.height * 0.075))
        menuTitle.text = "MENU"
        menuTitle.textAlignment = .Center
        menuTitle.adjustsFontSizeToFitWidth = true
        menu.addSubview(menuTitle)
        
        let mapButton = UIButton(frame: CGRect(x: menu.frame.width * 0.15, y: menu.frame.height * 0.2, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        mapButton.setTitle("MAP", forState: .Normal)
        mapButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        mapButton.layer.backgroundColor = UIColor(red: 0.6, green: 0.45, blue: 0.25, alpha: 1).CGColor
        mapButton.layer.borderWidth = mapButton.frame.height * 0.1
        mapButton.addTarget(self, action: #selector(GameScene.openMap), forControlEvents: .TouchUpInside)
        menu.addSubview(mapButton)
        
        let inventoryButton = UIButton(frame: CGRect(x: menu.frame.width * 0.55, y: menu.frame.height * 0.2, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        inventoryButton.setTitle("INVENTORY", forState: .Normal)
        inventoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        inventoryButton.layer.backgroundColor = UIColor(red: 0.6, green: 0.45, blue: 0.25, alpha: 1).CGColor
        inventoryButton.layer.borderWidth = mapButton.frame.height * 0.1
        inventoryButton.addTarget(self, action: #selector(GameScene.openInventory), forControlEvents: .TouchUpInside)
        menu.addSubview(inventoryButton)
        
        let skillsButton = UIButton(frame: CGRect(x: menu.frame.width * 0.15, y: menu.frame.height * 0.4, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        skillsButton.setTitle("SKILLS", forState: .Normal)
        skillsButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        skillsButton.layer.backgroundColor = UIColor(red: 0.6, green: 0.45, blue: 0.25, alpha: 1).CGColor
        skillsButton.layer.borderWidth = mapButton.frame.height * 0.1
        skillsButton.addTarget(self, action: #selector(GameScene.openSkills), forControlEvents: .TouchUpInside)
        menu.addSubview(skillsButton)
        
        let chooseAttackButton = UIButton(frame: CGRect(x: menu.frame.width * 0.55, y: menu.frame.height * 0.4, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        chooseAttackButton.setTitle("ATTACK TYPE", forState: .Normal)
        chooseAttackButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        chooseAttackButton.layer.backgroundColor = UIColor(red: 0.6, green: 0.45, blue: 0.25, alpha: 1).CGColor
        chooseAttackButton.layer.borderWidth = mapButton.frame.height * 0.1
        chooseAttackButton.addTarget(self, action: #selector(GameScene.openChooseAttack), forControlEvents: .TouchUpInside)
        menu.addSubview(chooseAttackButton)
        
        toggleMusicButton = UIButton(frame: CGRect(x: menu.frame.width * 0.6, y: menu.frame.height * 0.55, width: menu.frame.height * 0.1, height: menu.frame.height * 0.1))
        toggleMusicButton.layer.cornerRadius = toggleMusicButton.frame.width * 0.5
        toggleMusicButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        toggleMusicButton.layer.backgroundColor = UIColor.greenColor().CGColor
        toggleMusicButton.layer.borderWidth = toggleMusicButton.frame.width * 0.1
        toggleMusicButton.addTarget(self, action: #selector(GameScene.toggleMusic), forControlEvents: .TouchUpInside)
        menu.addSubview(toggleMusicButton)
        
        let toggleMusicLabel = UILabel(frame: CGRect(x: menu.frame.width * 0.25, y: menu.frame.height * 0.55, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        toggleMusicLabel.text = "Toggle Music:"
        menu.addSubview(toggleMusicLabel)
        
        toggleSoundButton = UIButton(frame: CGRect(x: menu.frame.width * 0.6, y: menu.frame.height * 0.7, width: menu.frame.height * 0.1, height: menu.frame.height * 0.1))
        toggleSoundButton.layer.cornerRadius = toggleMusicButton.frame.width * 0.5
        toggleSoundButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        toggleSoundButton.layer.backgroundColor = UIColor.greenColor().CGColor
        toggleSoundButton.layer.borderWidth = toggleSoundButton.frame.width * 0.1
        toggleSoundButton.addTarget(self, action: #selector(GameScene.toggleSound), forControlEvents: .TouchUpInside)
        menu.addSubview(toggleSoundButton)
        
        let toggleSoundLabel = UILabel(frame: CGRect(x: menu.frame.width * 0.25, y: menu.frame.height * 0.7, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        toggleSoundLabel.text = "Toggle Sound:"
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
        unlockDoors()
        
        // 4
        addChild(player)
        
        changeRewards = UITapGestureRecognizer(target: self, action: #selector(GameScene.continueRewards))
        
        chestNotification = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
        chestNotification.backgroundColor = UIColor.brownColor()
        chestNotification.addGestureRecognizer(changeRewards)
        
        let congratsLabel = UILabel(frame: CGRect(x: chestNotification.frame.width * 0.2, y: chestNotification.frame.height * 0.075, width: chestNotification.frame.width * 0.6, height: chestNotification.frame.height * 0.1))
        congratsLabel.text = "CONGRATULATIONS"
        congratsLabel.adjustsFontSizeToFitWidth = true
        congratsLabel.textAlignment = .Center
        chestNotification.addSubview(congratsLabel)
        
        speedPotBG = UIView(frame: CGRect(x: size.width * 0.02, y: size.height * 0.02, width: size.width * 0.07, height: size.width * 0.07))
        speedPotBG.layer.backgroundColor = UIColor.brownColor().CGColor
        speedPotBG.layer.borderColor = UIColor.grayColor().CGColor
        speedPotBG.layer.borderWidth = speedPotBG.frame.width * 0.05
        speedPot = UIImageView(frame: CGRect(x: size.width * 0.03, y: size.height * 0.02 + size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
        speedPot.image = UIImage(named: "SpeedPot")
        blockPotBG = UIView(frame: CGRect(x: size.width * 0.09, y: size.height * 0.02, width: size.width * 0.07, height: size.width * 0.07))
        blockPotBG.layer.backgroundColor = UIColor.brownColor().CGColor
        blockPotBG.layer.borderColor = UIColor.grayColor().CGColor
        blockPotBG.layer.borderWidth = blockPotBG.frame.width * 0.05
        blockPot = UIImageView(frame: CGRect(x: size.width * 0.1, y: size.height * 0.02 + size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
        blockPot.image = UIImage(named: "BlockPot")
        damagePotBG = UIView(frame: CGRect(x: size.width * 0.16, y: size.height * 0.02, width: size.width * 0.07, height: size.width * 0.07))
        damagePotBG.layer.backgroundColor = UIColor.brownColor().CGColor
        damagePotBG.layer.borderColor = UIColor.grayColor().CGColor
        damagePotBG.layer.borderWidth = damagePotBG.frame.width * 0.05
        damagePot = UIImageView(frame: CGRect(x: size.width * 0.17, y: size.height * 0.02 + size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
        damagePot.image = UIImage(named: "DamagePot")
        
        checkForKey()
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
    }
    
    //////////////////////////      JOYSTICK FUNCTIONS      //////////////////////////////
    
    //Attack Function
    func attack()
    {
        if(canAttack && canDoStuff)
        {
            var projectile: SKSpriteNode!
            var distance: CGFloat = 0
            if(character.equippedWeapon == "Melee")
            {
                projectile = SKSpriteNode(imageNamed: "Sword2")
                projectile.size = CGSize(width: player.size.width * 0.4, height: player.size.height * 0.8)
                distance = 50
            }
            if(character.equippedWeapon == "Short Range")
            {
                projectile = SKSpriteNode(imageNamed: "Shuriken")
                projectile.size = CGSize(width: player.size.width * 0.3, height: player.size.height * 0.3)
                distance = 100
            }
            if(character.equippedWeapon == "Magic")
            {
                projectile = SKSpriteNode(imageNamed: "Fireball")
                projectile.size = CGSize(width: player.size.width * 0.4, height: player.size.height * 0.4)
                distance = 200
            }
            if(character.equippedWeapon == "Long Range")
            {
                projectile = SKSpriteNode(imageNamed: "Long Range")
                projectile.size = CGSize(width: player.size.width * 0.2, height: player.size.height * 0.5)
                distance = 400
            }
            
            projectile.position = player.position
            projectile.physicsBody = SKPhysicsBody(rectangleOfSize: projectile.size)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            var offset =  tempAttack - attackLoc
            offset.x *= -1
            addChild(projectile)
            
            let direction = offset.normalized()
            let shootAmount = direction * distance
            let realDest = shootAmount + projectile.position
            
            projectile.zRotation = atan2(direction.x * -1, direction.y)
            
            let actionMove = SKAction.moveTo(realDest, duration: (1/400) * Double(distance))
            let actionMoveDone = SKAction.removeFromParent()
            if(offset.x != 0 && offset.y != 0)
            {
                projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
                canAttack = false
                _ = NSTimer.scheduledTimerWithTimeInterval(0.16, target: self, selector: #selector(GameScene.letAttack), userInfo: nil, repeats: false)
                if(settings.soundOn)
                {
                    runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
                }
            }
            else
            {
                projectile.runAction(actionMoveDone)
            }
            
        }
    }
    
    func setEnemyLocs(place: CGPoint)
    {
        if(place.y > size.height * 0.4)  //Above
        {
            if place.x > size.width * 0.7  //Right
            {
                availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.5))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.8))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.4, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.4, y: size.height * 0.8))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.5, y: size.height * 0.5))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.6, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.6, y: size.height * 0.8))
            }
            else if place.x < size.width * 0.3   //Left
            {
                availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.5))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.8))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.6, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.6, y: size.height * 0.8))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.5, y: size.height * 0.5))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.4, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.4, y: size.height * 0.8))
            }
            else    //Above
            {
                availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.4, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.6, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.2))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.5))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.8))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.8))
                availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.5))
            }
        }
        else    //Below
        {
            availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.8))
            availableEnemyLocs.append(CGPoint(x: size.width * 0.4, y: size.height * 0.8))
            availableEnemyLocs.append(CGPoint(x: size.width * 0.6, y: size.height * 0.8))
            availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.8))
            availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.5))
            availableEnemyLocs.append(CGPoint(x: size.width * 0.2, y: size.height * 0.2))
            availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.2))
            availableEnemyLocs.append(CGPoint(x: size.width * 0.8, y: size.height * 0.5))
        }
    }
    
    func letAttack()
    {
        canAttack = true
    }
    
    func mortal()
    {
        invincibleCounter += 1
        if(invincibleCounter < 6)
        {
            player.alpha = CGFloat(12 - (invincibleCounter * 2))/10
        }
        else
        {
            player.alpha = CGFloat((invincibleCounter - 5) * 2)/10
        }
        if(invincibleCounter == 10)
        {
            canTakeDamage = true
            invincibleCounter = 0
            immortalTimer.invalidate()
        }
    }
    
    //Move Function
    func move()
    {
        if canDoStuff
        {
            let newPoint = tempMove - moveLoc
            let xOffset = newPoint.x
            let yOffset = newPoint.y
            let absX = abs(xOffset)
            let absY = abs(yOffset)
            var realDest = newPoint
            
            let moveDist: CGFloat = 7 + CGFloat(character.moveSpeed)/5 + CGFloat(tempSpeed)
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
            else
            {
                realDest = player.position
            }
            
            if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && roomCleared // In the middle
            {
                if realDest.y < size.height * 0.5
                {
                    if map.getDown() != nil
                    {
                        realDest.y = max(0,realDest.y)
                    }
                    else
                    {
                        realDest.y = max(size.height * 0.1, realDest.y)
                    }
                }
                else
                {
                    if map.getUp() != nil
                    {
                        realDest.y = min(size.width, realDest.y)
                    }
                    else
                    {
                        realDest.y = min(size.height * 0.9, realDest.y)
                    }
                }
            }
            else
            {
                realDest.y = max(size.height * 0.1, realDest.y)
                realDest.y = min(size.height * 0.9, realDest.y)
            }
            
            if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && roomCleared // In the middle
            {
                if realDest.x < size.width * 0.5
                {
                    if map.getLeft() != nil
                    {
                        realDest.x = max(0, realDest.x)
                    }
                    else
                    {
                        realDest.x = max(size.width * 0.1, realDest.x)
                    }
                }
                else
                {
                    if map.getRight() != nil
                    {
                        realDest.x = min(size.width, realDest.x)
                    }
                    else
                    {
                        realDest.x = min(size.width * 0.9, realDest.x)
                    }
                }
            }
            else
            {
                realDest.x = max(size.width * 0.1, realDest.x)
                realDest.x = min(size.width * 0.9, realDest.x)
            }
            
            var door = false
            if realDest.y <= 0 // Bottom
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getDown() != nil && roomCleared // In the middle
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.9 - player.frame.height * 0.5)
                    map.update(map.getDown()!)
                    door = true
                    transitionClose()
                }
            }
            else if realDest.y >= size.height // Top
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getUp() != nil && roomCleared // In the middle
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.1 + player.frame.height * 0.5)
                    map.update(map.getUp()!)
                    door = true
                    transitionClose()
                }
            }
            else if realDest.x <= 0 // Left
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getLeft() != nil && roomCleared // In the middle
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.9 - player.frame.width * 0.5, y: size.height * 0.5)
                    map.update(map.getLeft()!)
                    door = true
                    transitionClose()
                }
            }
            else if realDest.x >= size.width // Right
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getRight() != nil && roomCleared // In the middle
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.1 + player.frame.width * 0.5, y: size.height * 0.5)
                    map.update(map.getRight()!)
                    door = true
                    transitionClose()
                }
            }
            if !door{
                let actionMove = SKAction.moveTo(realDest, duration: 0.1)
                player.runAction(actionMove)
            }
        }
    }
    
    func checkForKey()
    {
        if map.visited.contains(map.getKey())
        {
            let keyView = UIImageView(frame: CGRect(x: size.width * 0.65, y: size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
            keyView.image = UIImage(named: "key")
            view?.addSubview(keyView)
            hasKey = true
        }
        hasKey = false
    }
    
    func unlockDoors()      //Chance image of doors
    {
        checkForKey()
        for num in 0..<doors.count
        {
            doors[num].texture = doorUnlocked
        }
    }
    
    /////////////////////////////////       TOUCH FUNCTIONS        /////////////////////////////////
    
    func moveOnTouch()
    {
        if(!moveTimer.valid)
        {
            tempMove = moveHold.locationInView(moveView)
            moveLoc = moveHold.locationInView(moveView)
            
            moveJoystickOuter.center = moveLoc
            moveView.addSubview(moveJoystickOuter)
            
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
            moveJoystickOuter.removeFromSuperview()
        }
    }
    
    func attackOnTouch()
    {
        if(!attackTimer.valid)
        {
            tempAttack = attackHold.locationInView(attackView)
            attackLoc = attackHold.locationInView(attackView)
            
            attackJoystickOuter.center = attackLoc
            attackView.addSubview(attackJoystickOuter)
            
            attackTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(GameScene.attack), userInfo: nil, repeats: true)
            attack()
        }
        else if(attackHold.state == UIGestureRecognizerState.Changed)
        {
            attackLoc = attackHold.locationInView(attackView)
        }
        else
        {
            attackJoystickOuter.removeFromSuperview()
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
    
    func transitionClose()      //Teleporting error with self.paused and error with moving out of bounds when no door present
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
        loadScreen()
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
            availableEnemyLocs.removeAll()
            setEnemyLocs(player.position)
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
    
    func loadScreen()
    {
        if(character.map.getCurr().chest != nil)
        {
            let chest = SKSpriteNode(imageNamed: character.map.getCurr().chest!)
            chest.position = CGPoint(x: size.width * 0.1, y: size.height * 0.9)
            chest.size = CGSize(width: size.width * 0.05, height: size.height * 0.05)
            chest.physicsBody = SKPhysicsBody(rectangleOfSize: chest.size)
            chest.physicsBody?.dynamic = true
            chest.physicsBody?.categoryBitMask = PhysicsCategory.Chest
            chest.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            chest.physicsBody?.collisionBitMask = PhysicsCategory.None
            chest.physicsBody?.usesPreciseCollisionDetection = false
            chest.name = character.map.getCurr().chest
            addChild(chest)
        }
        
        if(map.visited.contains(map.getCurr()))
        {
            roomCleared = true
        }
        else
        {
            addMonster(1)
            addMonster(1)
            addMonster(2)
            addMonster(2)
            roomCleared = false
        }
    }
    
    /////////////////////////////////       MONSTER COLLISIONS      //////////////////////////
    
    func addMonster(num : Int)      //Num is type of enemy, 1 is ranged, 2 is melee(run into you), 3 is boss
    {
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        let index = Int(arc4random_uniform(UInt32(availableEnemyLocs.count)))
        
        monster.position = availableEnemyLocs[index]
        availableEnemyLocs.removeAtIndex(index)
        
        addChild(monster)
        
        if !attackEnemyTimer.valid
        {
            attackEnemyTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(GameScene.attackPerson), userInfo: nil, repeats: true)
        }
        if !moveEnemyTimer.valid
        {
            moveEnemyTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameScene.moveEnemyAround), userInfo: nil, repeats: true)
        }
        var enemy: Enemy!
        if(num == 1)
        {
            enemy = Enemy(h: 5, dam: 1, move: 10, num: 1, enemy: monster)
        }
        else if(num == 2)
        {
            enemy = Enemy(h: 10, dam: 1, move: 15, num: 2, enemy: monster)
        }
        else
        {
            enemy = Enemy(h: 25, dam: 3, move: 5, num: 3, enemy: monster)
        }
        
        enemyObjects.append(enemy)
        
        let totalHealthView = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: monster.size.width, height: monster.size.height * 0.1))
        totalHealthView.position = CGPoint(x: monster.frame.midX, y: monster.frame.maxY + totalHealthView.frame.height/2 + 10)
        addChild(totalHealthView)
        let currHealthView = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: monster.size.width, height: monster.size.height * 0.1))
        currHealthView.position = CGPoint(x: monster.frame.midX, y: monster.frame.maxY + totalHealthView.frame.height/2 + 10)
        addChild(currHealthView)
        
        healthBars.append(totalHealthView)
        healthBars.append(currHealthView)
    }
    
    func moveEnemyAround()
    {
        if(canDoStuff)
        {
            for num in 0..<enemyObjects.count
            {
                let currLoc = enemyObjects[num].sprite.position
                
                var actualX = currLoc.x
                var actualY = currLoc.y
                let moveSpeed: CGFloat = CGFloat(enemyObjects[num].getMoveSpeed() * 2)
                
                if enemyObjects[num].type == 2
                {
                    let offset = player.position - currLoc
                    let direction = offset.normalized()
                    let moveAmount = direction * moveSpeed
                    let realDest = moveAmount + currLoc
                    actualX = realDest.x
                    actualY = realDest.y
                }
                else
                {
                    let x = arc4random_uniform(2)
                    if x == 0
                    {
                        actualX = currLoc.x + moveSpeed
                    }
                    else if x == 1
                    {
                        actualX = currLoc.x - moveSpeed
                    }
                    
                    let y = arc4random_uniform(2)
                    if y == 0
                    {
                        actualY = currLoc.y + moveSpeed
                    }
                    else if y == 1
                    {
                        actualY = currLoc.y - moveSpeed
                    }
                }
                
                actualY = min(actualY, size.height * 0.9)
                actualY = max(actualY, size.height * 0.1)
                
                actualX = min(actualX, size.width * 0.9)
                actualX = max(actualX, size.width * 0.1)
                
                let loc = CGPoint(x: actualX, y: actualY)
                
                let delta: CGVector = CGVector(dx: loc.x - currLoc.x, dy: loc.y - currLoc.y)
                let move = SKAction.moveTo(loc, duration: 1.0)
                let displacement = SKAction.moveBy(delta, duration: 1.0)
                
                healthBars[num * 2].runAction(displacement)
                healthBars[num * 2 + 1].runAction(displacement)
                enemyObjects[num].sprite.runAction(move)
            }
        }
    }
    
    func attackPerson()
    {
        if(canDoStuff)
        {
            var shots = 0
            for enemy in enemyObjects
            {
                if enemy.type != 2
                {
                    let random = arc4random_uniform(100)
                    if(random > 80)
                    {
                        if(shots < 2)
                        {
                            enemyProjectile(enemy.sprite.position, dam: enemy.getDamage())
                            shots += 1
                        }
                    }
                }
            }
        }
    }
    
    func enemyProjectile(loc: CGPoint, dam: Int)
    {
        
        let projectile =  SKSpriteNode(imageNamed: "Fireball")
        let distance: CGFloat = 400
        
        projectile.position = loc
        projectile.size = CGSize(width: player.size.width * 0.4, height: player.size.height * 0.4)
        projectile.physicsBody = SKPhysicsBody(rectangleOfSize: projectile.size)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.EnemyProjectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        projectile.name = "\(dam)"
        
        let offset = player.position - loc
        addChild(projectile)
        
        let direction = offset.normalized()
        let shootAmount = direction * distance
        let realDest = shootAmount + projectile.position
        
        projectile.zRotation = atan2(direction.x * -1, direction.y)
        
        let actionMove = SKAction.moveTo(realDest, duration: 3.5)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster(monster: SKSpriteNode, projectile: SKSpriteNode) {     //Check for damage against enemy
        projectile.removeFromParent()
        var damage = 0
        if(character.equippedWeapon == "Melee")
        {
            damage = 4 * (settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount()/10 + 1)
        }
        if(character.equippedWeapon == "Short Range")
        {
            damage = 3 * (settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount()/10 + 1)
        }
        if(character.equippedWeapon == "Magic")
        {
            damage = 2 * (settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount()/10 + 1)
            
        }
        if(character.equippedWeapon == "Long Range")
        {
            damage = (settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount()/10 + 1)
        }
        
        for num in 0..<enemyObjects.count
        {
            if enemyObjects[num].sprite == monster
            {
                if !enemyObjects[num].gotHit(damage)
                {
                    enemyObjects.removeAtIndex(num)
                    healthBars[num * 2].removeFromParent()
                    healthBars.removeAtIndex(num * 2)
                    healthBars[num * 2].removeFromParent()
                    healthBars.removeAtIndex(num * 2)
                    monster.removeFromParent()
                    if enemyObjects.count == 0
                    {
                        roomCleared = true
                        unlockDoors()
                    }
                }
                else
                {
                    flickerMonster(num)
                    healthBars[num * 2 + 1].size.width = healthBars[num * 2].size.width * (CGFloat(enemyObjects[num].currentHealth)/CGFloat(enemyObjects[num].maxHealth))
                    healthBars[num * 2 + 1].position.x = healthBars[num * 2].position.x - (healthBars[num * 2].size.width - healthBars[num * 2 + 1].size.width) / 2
                }
                break
            }
        }
    }
    
    
    func flickerMonster(num: Int)
    {
        enemyObjects[num].flicker()
    }
    
    func projectileDidCollideWithPlayer(projectile: SKSpriteNode, player: SKSpriteNode) {
        projectile.removeFromParent()
        if(character.currentHealth > 0)
        {
            if(canTakeDamage)
            {
                canTakeDamage = false
                immortalTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.mortal), userInfo: nil, repeats: true)
                character.currentHealth = character.currentHealth - Int(projectile.name!)!
            }
        }
        if character.currentHealth > 0
        {
            setHearts()
        }
        if character.currentHealth <= 0
        {
            character.currentHealth = character.maxHealth
            exitGame()
        }
    }
    
    func playerDidCollideWithMonster(monster: SKSpriteNode, player: SKSpriteNode) {
        if(character.currentHealth > 0)
        {
            if(canTakeDamage)
            {
                canTakeDamage = false
                immortalTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.mortal), userInfo: nil, repeats: true)
                character.currentHealth = character.currentHealth - 2
            }
        }
        if character.currentHealth > 0
        {
            setHearts()
        }
        if character.currentHealth <= 0
        {
            character.currentHealth = character.maxHealth
            exitGame()
        }
    }
    
    func playerDidCollideWithChest(player: SKSpriteNode, chest: SKSpriteNode)
    {
        openChest(chest.name!)
        character.map.getCurr().chest = nil
        chest.removeFromParent()
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
        // 6 is enemyProjectile
        if ((firstBody.categoryBitMask == 1) &&     //monster and projectile
            (secondBody.categoryBitMask == 2)) {
            if(secondBody.node != nil && firstBody.node != nil)
            {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, projectile: secondBody.node as! SKSpriteNode)
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
        else if(firstBody.categoryBitMask == 3 && secondBody.categoryBitMask == 6)  //player and enemyProjectile
        {
            if(secondBody.node != nil)
            {
                projectileDidCollideWithPlayer(secondBody.node as! SKSpriteNode, player: firstBody.node as! SKSpriteNode)
            }
        }
        
    }
    
    /////////////////////////////////       MENU FUNCTIONS       ///////////////////////////
    
    func openMenu()
    {
        canDoStuff = false
        for child in (self.scene?.children)!
        {
            if child.name != "backgroundMusic"
            {
                child.paused = true
            }
        }
        
        for timer in buffTimers
        {
            timer.invalidate()
        }
        view?.addSubview(menu)
    }
    
    func closeMenu()
    {
        menu.removeFromSuperview()
        canDoStuff = true
        if tempSpeed > 0
        {
            buffTimers.append(NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.reduceSpeed), userInfo: nil, repeats: true))
        }
        if tempBlock > 0
        {
            buffTimers.append(NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.reduceBlock), userInfo: nil, repeats: true))
            view?.addSubview(blockPotBG)
            view?.addSubview(blockPot)
        }
        if tempDamage > 0
        {
            buffTimers.append(NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(GameScene.reduceDamage), userInfo: nil, repeats: true))
            view?.addSubview(damagePotBG)
            view?.addSubview(damagePot)
        }
        for child in (self.scene?.children)!
        {
            child.paused = false
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
            let volumeUp = SKAction.changeVolumeTo(1, duration: 0)
            backgroundMusic.runAction(volumeUp)
        }
        else
        {
            toggleMusicButton.layer.backgroundColor = UIColor.redColor().CGColor
            let volumeDown = SKAction.changeVolumeTo(0, duration: 0)
            backgroundMusic.runAction(volumeDown)
        }
    }
    
    func openMap()
    {
        mapView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        mapView.backgroundColor = UIColor.brownColor()
        let closeMapButton = UIButton(frame: CGRect(x: mapView.frame.width - mapView.frame.height * 0.2, y: mapView.frame.height * 0.05, width: mapView.frame.height * 0.15, height: mapView.frame.height * 0.15))
        closeMapButton.addTarget(self, action: #selector(GameScene.closeMap), forControlEvents: .TouchUpInside)
        closeMapButton.backgroundColor = UIColor.redColor()
        closeMapButton.setTitle("X", forState: .Normal)
        closeMapButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        closeMapButton.layer.borderWidth = closeMapButton.frame.width * 0.1
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
        potionsView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        potionsView.backgroundColor = UIColor.brownColor()
        let closeInventoryButton = UIButton(frame: CGRect(x: potionsView.frame.width - potionsView.frame.height * 0.2, y: potionsView.frame.height * 0.05, width: potionsView.frame.height * 0.15, height: potionsView.frame.height * 0.15))
        closeInventoryButton.addTarget(self, action: #selector(GameScene.closeInventory), forControlEvents: .TouchUpInside)
        closeInventoryButton.backgroundColor = UIColor.redColor()
        closeInventoryButton.setTitle("X", forState: .Normal)
        closeInventoryButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        closeInventoryButton.layer.borderWidth = closeInventoryButton.frame.width * 0.1
        potionsView.addSubview(closeInventoryButton)
        
        //HEALTH POT INFO
        let healthPotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.125, y: potionsView.frame.height * 0.075, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        healthPotView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        healthPotView.layer.borderColor = UIColor.darkGrayColor().CGColor
        healthPotView.layer.borderWidth = healthPotView.frame.height * 0.05
        let healthPotImage = UIImageView(frame: CGRect(x: healthPotView.frame.height * 0.1, y: healthPotView.frame.height * 0.1, width: healthPotView.frame.height * 0.6, height: healthPotView.frame.height * 0.6))
        healthPotImage.image = UIImage(named: "HealthPot")
        healthPotView.addSubview(healthPotImage)
        let healthPotLabel = UILabel(frame: CGRect(x: healthPotView.frame.width * 0.05, y: healthPotView.frame.height * 0.75, width: healthPotView.frame.width * 0.95, height: healthPotView.frame.height * 0.2))
        healthPotLabel.text = "Health Potions"
        healthPotLabel.textAlignment = .Center
        healthPotView.addSubview(healthPotLabel)
        let healthPotAmount = UILabel(frame: CGRect(x: healthPotView.frame.width * 0.7, y: healthPotView.frame.height * 0.4, width: healthPotView.frame.width * 0.25, height: healthPotView.frame.height * 0.3))
        healthPotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Health Potions")!.getAmount())"
        healthPotView.addSubview(healthPotAmount)
        let healthTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useHealth))
        healthPotView.addGestureRecognizer(healthTapped)
        potionsView.addSubview(healthPotView)
        
        //SPEED POT INFO
        let speedPotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.55, y: potionsView.frame.height * 0.075, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        speedPotView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        speedPotView.layer.borderColor = UIColor.darkGrayColor().CGColor
        speedPotView.layer.borderWidth = speedPotView.frame.height * 0.05
        let speedPotImage = UIImageView(frame: CGRect(x: speedPotView.frame.height * 0.1, y: speedPotView.frame.height * 0.1, width: speedPotView.frame.height * 0.6, height: speedPotView.frame.height * 0.6))
        speedPotImage.image = UIImage(named: "SpeedPot")
        speedPotView.addSubview(speedPotImage)
        let speedPotLabel = UILabel(frame: CGRect(x: speedPotView.frame.width * 0.05, y: speedPotView.frame.height * 0.75, width: speedPotView.frame.width * 0.95, height: speedPotView.frame.height * 0.2))
        speedPotLabel.text = "Speed Potions"
        speedPotLabel.textAlignment = .Center
        speedPotView.addSubview(speedPotLabel)
        let speedPotAmount = UILabel(frame: CGRect(x: speedPotView.frame.width * 0.7, y: speedPotView.frame.height * 0.4, width: speedPotView.frame.width * 0.25, height: speedPotView.frame.height * 0.3))
        speedPotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Speed Potions")!.getAmount())"
        speedPotView.addSubview(speedPotAmount)
        let speedTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useSpeed))
        speedPotView.addGestureRecognizer(speedTapped)
        potionsView.addSubview(speedPotView)
        
        //DAMAGE POT INFO
        let damagePotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.125, y: potionsView.frame.height * 0.525, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        damagePotView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        damagePotView.layer.borderColor = UIColor.darkGrayColor().CGColor
        damagePotView.layer.borderWidth = damagePotView.frame.height * 0.05
        let damagePotImage = UIImageView(frame: CGRect(x: damagePotView.frame.height * 0.1, y: damagePotView.frame.height * 0.1, width: damagePotView.frame.height * 0.6, height: damagePotView.frame.height * 0.6))
        damagePotImage.image = UIImage(named: "DamagePot")
        damagePotView.addSubview(damagePotImage)
        let damagePotLabel = UILabel(frame: CGRect(x: damagePotView.frame.width * 0.05, y: damagePotView.frame.height * 0.75, width: damagePotView.frame.width * 0.95, height: damagePotView.frame.height * 0.2))
        damagePotLabel.text = "Damage Potions"
        damagePotLabel.textAlignment = .Center
        damagePotView.addSubview(damagePotLabel)
        let damagePotAmount = UILabel(frame: CGRect(x: damagePotView.frame.width * 0.7, y: damagePotView.frame.height * 0.4, width: damagePotView.frame.width * 0.25, height: damagePotView.frame.height * 0.3))
        damagePotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Damage Potions")!.getAmount())"
        damagePotView.addSubview(damagePotAmount)
        let damageTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useDamage))
        damagePotView.addGestureRecognizer(damageTapped)
        potionsView.addSubview(damagePotView)
        
        //BLOCK POT INFO
        let blockPotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.55, y: potionsView.frame.height * 0.525, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        blockPotView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        blockPotView.layer.borderColor = UIColor.darkGrayColor().CGColor
        blockPotView.layer.borderWidth = blockPotView.frame.height * 0.05
        let blockPotImage = UIImageView(frame: CGRect(x: blockPotView.frame.height * 0.1, y: blockPotView.frame.height * 0.1, width: blockPotView.frame.height * 0.6, height: blockPotView.frame.height * 0.6))
        blockPotImage.image = UIImage(named: "BlockPot")
        blockPotView.addSubview(blockPotImage)
        let blockPotLabel = UILabel(frame: CGRect(x: blockPotView.frame.width * 0.05, y: blockPotView.frame.height * 0.75, width: blockPotView.frame.width * 0.95, height: blockPotView.frame.height * 0.2))
        blockPotLabel.text = "Block Potions"
        blockPotLabel.textAlignment = .Center
        blockPotView.addSubview(blockPotLabel)
        let blockPotAmount = UILabel(frame: CGRect(x: blockPotView.frame.width * 0.7, y: blockPotView.frame.height * 0.4, width: blockPotView.frame.width * 0.25, height: blockPotView.frame.height * 0.3))
        blockPotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Block Potions")!.getAmount())"
        blockPotView.addSubview(blockPotAmount)
        let blockTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useBlock))
        blockPotView.addGestureRecognizer(blockTapped)
        potionsView.addSubview(blockPotView)
        
        if(tempDamage > 0)
        {
            damagePotView.layer.backgroundColor = UIColor.blueColor().CGColor
        }
        if(tempSpeed > 0)
        {
            speedPotView.layer.backgroundColor = UIColor.blueColor().CGColor
        }
        if(tempBlock > 0)
        {
            blockPotView.layer.backgroundColor = UIColor.blueColor().CGColor
        }
        
        menu.addSubview(potionsView)
    }
    
    func closeInventory()
    {
        potionsView.removeFromSuperview()
    }
    
    func openSkills()
    {
        skillsView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        skillsView.backgroundColor = UIColor.brownColor()
        let closeSkillsButton = UIButton(frame: CGRect(x: skillsView.frame.width - skillsView.frame.height * 0.2, y: skillsView.frame.height * 0.05, width: skillsView.frame.height * 0.15, height: skillsView.frame.height * 0.15))
        closeSkillsButton.addTarget(self, action: #selector(GameScene.closeSkills), forControlEvents: .TouchUpInside)
        closeSkillsButton.backgroundColor = UIColor.redColor()
        closeSkillsButton.setTitle("X", forState: .Normal)
        closeSkillsButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        closeSkillsButton.layer.borderWidth = closeSkillsButton.frame.width * 0.1
        skillsView.addSubview(closeSkillsButton)
        
        //ARMOR  INFO
        let armorView = UIView(frame: CGRect(x: skillsView.frame.width * 0.13, y: skillsView.frame.height * 0.075, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        armorView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        armorView.layer.borderColor = UIColor.darkGrayColor().CGColor
        armorView.layer.borderWidth = armorView.frame.height * 0.05
        let armorImage = UIImageView(frame: CGRect(x: armorView.frame.height * 0.1, y: armorView.frame.height * 0.1, width: armorView.frame.height * 0.6, height: armorView.frame.height * 0.6))
        armorImage.image = UIImage(named: "Armor")
        armorView.addSubview(armorImage)
        let armorLabel = UILabel(frame: CGRect(x: armorView.frame.width * 0.05, y: armorView.frame.height * 0.75, width: armorView.frame.width * 0.95, height: armorView.frame.height * 0.2))
        armorLabel.text = "Armor"
        armorLabel.textAlignment = .Center
        armorView.addSubview(armorLabel)
        let armorAmount = UILabel(frame: CGRect(x: armorView.frame.width * 0.7, y: armorView.frame.height * 0.4, width: armorView.frame.width * 0.25, height: armorView.frame.height * 0.3))
        armorAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Armor")!.getAmount())"
        armorView.addSubview(armorAmount)
        skillsView.addSubview(armorView)
        
        //agility  INFO
        let agilityView = UIView(frame: CGRect(x: skillsView.frame.width * 0.56, y: skillsView.frame.height * 0.075, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        agilityView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        agilityView.layer.borderColor = UIColor.darkGrayColor().CGColor
        agilityView.layer.borderWidth = agilityView.frame.height * 0.05
        let agilityImage = UIImageView(frame: CGRect(x: agilityView.frame.height * 0.1, y: agilityView.frame.height * 0.1, width: agilityView.frame.height * 0.6, height: agilityView.frame.height * 0.6))
        agilityImage.image = UIImage(named: "Speed")
        agilityView.addSubview(agilityImage)
        let agilityLabel = UILabel(frame: CGRect(x: agilityView.frame.width * 0.05, y: agilityView.frame.height * 0.75, width: agilityView.frame.width * 0.95, height: agilityView.frame.height * 0.2))
        agilityLabel.text = "Agility"
        agilityLabel.textAlignment = .Center
        agilityView.addSubview(agilityLabel)
        let agilityAmount = UILabel(frame: CGRect(x: agilityView.frame.width * 0.7, y: agilityView.frame.height * 0.4, width: agilityView.frame.width * 0.25, height: agilityView.frame.height * 0.3))
        agilityAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Agility")!.getAmount())"
        agilityView.addSubview(agilityAmount)
        skillsView.addSubview(agilityView)
        
        //health  INFO
        let healthView = UIView(frame: CGRect(x: skillsView.frame.width * 0.025, y: skillsView.frame.height * 0.525, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        healthView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        healthView.layer.borderColor = UIColor.darkGrayColor().CGColor
        healthView.layer.borderWidth = healthView.frame.height * 0.05
        let healthImage = UIImageView(frame: CGRect(x: healthView.frame.height * 0.1, y: healthView.frame.height * 0.1, width: healthView.frame.height * 0.6, height: healthView.frame.height * 0.6))
        healthImage.image = UIImage(named: "8BitHeart")
        healthView.addSubview(healthImage)
        let healthLabel = UILabel(frame: CGRect(x: healthView.frame.width * 0.05, y: healthView.frame.height * 0.75, width: healthView.frame.width * 0.95, height: healthView.frame.height * 0.2))
        healthLabel.text = "Health"
        healthLabel.textAlignment = .Center
        healthView.addSubview(healthLabel)
        let healthAmount = UILabel(frame: CGRect(x: healthView.frame.width * 0.7, y: healthView.frame.height * 0.4, width: healthView.frame.width * 0.25, height: healthView.frame.height * 0.3))
        healthAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Health")!.getAmount())"
        healthView.addSubview(healthAmount)
        skillsView.addSubview(healthView)
        
        //crit  INFO
        let critView = UIView(frame: CGRect(x: skillsView.frame.width * 0.35, y: skillsView.frame.height * 0.525, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        critView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        critView.layer.borderColor = UIColor.darkGrayColor().CGColor
        critView.layer.borderWidth = critView.frame.height * 0.05
        let critImage = UIImageView(frame: CGRect(x: critView.frame.height * 0.1, y: critView.frame.height * 0.1, width: critView.frame.height * 0.6, height: critView.frame.height * 0.6))
        critImage.image = UIImage(named: "Crit Chance")
        critView.addSubview(critImage)
        let critLabel = UILabel(frame: CGRect(x: critView.frame.width * 0.05, y: critView.frame.height * 0.75, width: critView.frame.width * 0.95, height: critView.frame.height * 0.2))
        critLabel.text = "Crit Chance"
        critLabel.textAlignment = .Center
        critView.addSubview(critLabel)
        let critAmount = UILabel(frame: CGRect(x: critView.frame.width * 0.7, y: critView.frame.height * 0.4, width: critView.frame.width * 0.25, height: critView.frame.height * 0.3))
        critAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Crit Chance")!.getAmount())"
        critView.addSubview(critAmount)
        skillsView.addSubview(critView)
        
        //BLOCK  INFO
        let blockView = UIView(frame: CGRect(x: skillsView.frame.width * 0.675, y: skillsView.frame.height * 0.525, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        blockView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        blockView.layer.borderColor = UIColor.darkGrayColor().CGColor
        blockView.layer.borderWidth = blockView.frame.height * 0.05
        let blockImage = UIImageView(frame: CGRect(x: blockView.frame.height * 0.1, y: blockView.frame.height * 0.1, width: blockView.frame.height * 0.6, height: blockView.frame.height * 0.6))
        blockImage.image = UIImage(named: "Block")
        blockView.addSubview(blockImage)
        let blockLabel = UILabel(frame: CGRect(x: blockView.frame.width * 0.05, y: blockView.frame.height * 0.75, width: blockView.frame.width * 0.95, height: blockView.frame.height * 0.2))
        blockLabel.text = "Block Chance"
        blockLabel.textAlignment = .Center
        blockView.addSubview(blockLabel)
        let blockAmount = UILabel(frame: CGRect(x: blockView.frame.width * 0.7, y: blockView.frame.height * 0.4, width: blockView.frame.width * 0.25, height: blockView.frame.height * 0.3))
        blockAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Block Chance")!.getAmount())"
        blockView.addSubview(blockAmount)
        skillsView.addSubview(blockView)
        
        menu.addSubview(skillsView)
    }
    
    func closeSkills()
    {
        skillsView.removeFromSuperview()
    }
    
    func openChooseAttack()
    {
        chooseAttackView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        chooseAttackView.backgroundColor = UIColor.brownColor()
        let closeAttackButton = UIButton(frame: CGRect(x: chooseAttackView.frame.width - chooseAttackView.frame.height * 0.2, y: chooseAttackView.frame.height * 0.05, width: chooseAttackView.frame.height * 0.15, height: chooseAttackView.frame.height * 0.15))
        closeAttackButton.addTarget(self, action: #selector(GameScene.closeChooseAttack), forControlEvents: .TouchUpInside)
        closeAttackButton.backgroundColor = UIColor.redColor()
        closeAttackButton.setTitle("X", forState: .Normal)
        closeAttackButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        closeAttackButton.layer.borderWidth = closeAttackButton.frame.width * 0.1
        chooseAttackView.addSubview(closeAttackButton)
        
        //SWORD INFO
        let swordView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.125, y: chooseAttackView.frame.height * 0.075, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        swordView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        swordView.layer.borderColor = UIColor.darkGrayColor().CGColor
        swordView.layer.borderWidth = swordView.frame.height * 0.05
        let swordImage = UIImageView(frame: CGRect(x: swordView.frame.height * 0.1, y: swordView.frame.height * 0.1, width: swordView.frame.height * 0.6, height: swordView.frame.height * 0.6))
        swordImage.image = UIImage(named: "Sword")
        swordView.addSubview(swordImage)
        let swordLabel = UILabel(frame: CGRect(x: swordView.frame.width * 0.05, y: swordView.frame.height * 0.75, width: swordView.frame.width * 0.95, height: swordView.frame.height * 0.2))
        swordLabel.text = "Melee"
        swordLabel.textAlignment = .Center
        swordView.addSubview(swordLabel)
        let swordAmount = UILabel(frame: CGRect(x: swordView.frame.width * 0.7, y: swordView.frame.height * 0.4, width: swordView.frame.width * 0.25, height: swordView.frame.height * 0.3))
        swordAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount())"
        swordView.addSubview(swordAmount)
        let healthTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goMelee))
        swordView.addGestureRecognizer(healthTapped)
        chooseAttackView.addSubview(swordView)
        
        //SHORT RANGE INFO
        let shortRangeView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.55, y: chooseAttackView.frame.height * 0.075, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        shortRangeView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        shortRangeView.layer.borderColor = UIColor.darkGrayColor().CGColor
        shortRangeView.layer.borderWidth = shortRangeView.frame.height * 0.05
        let shortRangeImage = UIImageView(frame: CGRect(x: shortRangeView.frame.height * 0.1, y: shortRangeView.frame.height * 0.1, width: shortRangeView.frame.height * 0.6, height: shortRangeView.frame.height * 0.6))
        shortRangeImage.image = UIImage(named: "Shuriken")
        shortRangeView.addSubview(shortRangeImage)
        let shortRangeLabel = UILabel(frame: CGRect(x: shortRangeView.frame.width * 0.05, y: shortRangeView.frame.height * 0.75, width: shortRangeView.frame.width * 0.95, height: shortRangeView.frame.height * 0.2))
        shortRangeLabel.text = "Short Range"
        shortRangeLabel.textAlignment = .Center
        shortRangeView.addSubview(shortRangeLabel)
        let shortRangeAmount = UILabel(frame: CGRect(x: shortRangeView.frame.width * 0.7, y: shortRangeView.frame.height * 0.4, width: shortRangeView.frame.width * 0.25, height: shortRangeView.frame.height * 0.3))
        shortRangeAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount())"
        shortRangeView.addSubview(shortRangeAmount)
        let speedTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goShortRange))
        shortRangeView.addGestureRecognizer(speedTapped)
        chooseAttackView.addSubview(shortRangeView)
        
        //MAGIC INFO
        let magicView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.125, y: chooseAttackView.frame.height * 0.525, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        magicView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        magicView.layer.borderColor = UIColor.darkGrayColor().CGColor
        magicView.layer.borderWidth = magicView.frame.height * 0.05
        let magicImage = UIImageView(frame: CGRect(x: magicView.frame.height * 0.1, y: magicView.frame.height * 0.1, width: magicView.frame.height * 0.6, height: magicView.frame.height * 0.6))
        magicImage.image = UIImage(named: "Fireball")
        magicView.addSubview(magicImage)
        let magicLabel = UILabel(frame: CGRect(x: magicView.frame.width * 0.05, y: magicView.frame.height * 0.75, width: magicView.frame.width * 0.95, height: magicView.frame.height * 0.2))
        magicLabel.text = "Magic"
        magicLabel.textAlignment = .Center
        magicView.addSubview(magicLabel)
        let magicAmount = UILabel(frame: CGRect(x: magicView.frame.width * 0.7, y: magicView.frame.height * 0.4, width: magicView.frame.width * 0.25, height: magicView.frame.height * 0.3))
        magicAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount())"
        magicView.addSubview(magicAmount)
        let damageTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goMagic))
        magicView.addGestureRecognizer(damageTapped)
        chooseAttackView.addSubview(magicView)
        
        //LONG RANGE INFO
        let longRangeView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.55, y: chooseAttackView.frame.height * 0.525, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        longRangeView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        longRangeView.layer.borderColor = UIColor.darkGrayColor().CGColor
        longRangeView.layer.borderWidth = longRangeView.frame.height * 0.05
        let longRangeImage = UIImageView(frame: CGRect(x: longRangeView.frame.height * 0.1, y: longRangeView.frame.height * 0.1, width: longRangeView.frame.height * 0.6, height: longRangeView.frame.height * 0.6))
        longRangeImage.image = UIImage(named: "Bow and Arrow")
        longRangeView.addSubview(longRangeImage)
        let longRangeLabel = UILabel(frame: CGRect(x: longRangeView.frame.width * 0.05, y: longRangeView.frame.height * 0.75, width: longRangeView.frame.width * 0.95, height: longRangeView.frame.height * 0.2))
        longRangeLabel.text = "Long Range"
        longRangeLabel.textAlignment = .Center
        longRangeView.addSubview(longRangeLabel)
        let longRangeAmount = UILabel(frame: CGRect(x: longRangeView.frame.width * 0.7, y: longRangeView.frame.height * 0.4, width: longRangeView.frame.width * 0.25, height: longRangeView.frame.height * 0.3))
        longRangeAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount())"
        longRangeView.addSubview(longRangeAmount)
        let blockTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goLongRange))
        longRangeView.addGestureRecognizer(blockTapped)
        chooseAttackView.addSubview(longRangeView)
        
        if(character.equippedWeapon == "Melee")
        {
            swordView.layer.backgroundColor = UIColor.blueColor().CGColor
        }
        if(character.equippedWeapon == "Short Range")
        {
            shortRangeView.layer.backgroundColor = UIColor.blueColor().CGColor
        }
        if(character.equippedWeapon == "Magic")
        {
            magicView.layer.backgroundColor = UIColor.blueColor().CGColor
        }
        if(character.equippedWeapon == "Long Range")
        {
            longRangeView.layer.backgroundColor = UIColor.blueColor().CGColor
        }
        
        menu.addSubview(chooseAttackView)
    }
    
    func closeChooseAttack()
    {
        chooseAttackView.removeFromSuperview()
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
    
    /////////////////////////////////       POTIONS         /////////////////////////////////
    
    func useHealth()
    {
        if(character.currentHealth < character.maxHealth + (character.inventory.get("Health")!.getAmount()/5))
        {
            if(character.inventory.remove("Health Potions"))
            {
                character.currentHealth = min(character.currentHealth + 2, character.maxHealth + (character.inventory.get("Health")!.getAmount()/5))
                potionsView.removeFromSuperview()
                openInventory()
                setHearts()
            }
        }
    }
    
    func useSpeed()
    {
        if(character.inventory.remove("Speed Potions"))
        {
            if(tempSpeed == 0)
            {
                speedCounter = 0
                tempSpeed += 5
                potionsView.removeFromSuperview()
                openInventory()
                speedPot.alpha = 1.0
                speedPotBG.alpha = 1.0
                view?.insertSubview(speedPot, belowSubview: menu)
                view?.insertSubview(speedPotBG, belowSubview: speedPot)
            }
            else
            {
                character.inventory.add("Speed Potions")
            }
        }
    }
    
    func reduceSpeed()      //Call image that oscillates alphas from .2 to .9
    {
        speedCounter += 1
        if(speedCounter >= 100)
        {
            speedPot.alpha = findPotAlpha(speedCounter - 100)
            speedPotBG.alpha = findPotAlpha(speedCounter - 100)
        }
        if(speedCounter >= 150)
        {
            tempSpeed = 0
            speedPotBG.removeFromSuperview()
            speedPot.removeFromSuperview()
        }
    }
    
    func useBlock()
    {
        if(character.inventory.remove("Block Potions"))
        {
            if(tempBlock == 0)
            {
                blockCounter = 0
                tempBlock += 3
                potionsView.removeFromSuperview()
                openInventory()
                blockPot.alpha = 1.0
                blockPotBG.alpha = 1.0
                view?.insertSubview(blockPot, belowSubview: menu)
                view?.insertSubview(blockPotBG, belowSubview: blockPot)
            }
            else
            {
                character.inventory.add("Block Potions")
            }
        }
    }
    
    func reduceBlock()
    {
        blockCounter += 1
        if(blockCounter >= 100)
        {
            blockPot.alpha = findPotAlpha(blockCounter - 100)
            blockPotBG.alpha = findPotAlpha(blockCounter - 100)
        }
        if(blockCounter >= 150)
        {
            tempBlock = 0
            blockPotBG.removeFromSuperview()
            blockPot.removeFromSuperview()
        }
    }
    
    func useDamage()
    {
        if(character.inventory.remove("Damage Potions"))
        {
            if(tempDamage == 0)
            {
                damageCounter = 0
                tempDamage += 3
                potionsView.removeFromSuperview()
                openInventory()
                damagePot.alpha = 1.0
                damagePotBG.alpha = 1.0
                view?.insertSubview(damagePot, belowSubview: menu)
                view?.insertSubview(damagePotBG, belowSubview: damagePot)
            }
            else
            {
                character.inventory.add("Damage Potions")
            }
        }
    }
    
    func reduceDamage()
    {
        if(damageCounter >= 100)
        {
            damagePotBG.alpha = findPotAlpha(damageCounter - 100)
            damagePot.alpha = findPotAlpha(damageCounter - 100)
        }
        damageCounter += 1
        if damageCounter >= 150
        {
            tempDamage = 0
            damagePotBG.removeFromSuperview()
            damagePot.removeFromSuperview()
            
        }
    }
    
    func findPotAlpha(count: Int) -> CGFloat
    {
        let alpha: CGFloat = (CGFloat(count)/10)%2
        if alpha <= 1
        {
            return 1 - alpha
        }
        else
        {
            return alpha - 1
        }
    }
    
    ///////////////////////////////      ATTACK TYPE FUNCTIONS       ///////////////////////////
    
    func goMelee()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount() > 0
        {
            character.equippedWeapon = "Melee"
            chooseAttackView.removeFromSuperview()
            openChooseAttack()
        }
    }
    
    func goShortRange()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount() > 0
        {
            character.equippedWeapon = "Short Range"
            chooseAttackView.removeFromSuperview()
            openChooseAttack()
        }
    }
    
    func goMagic()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount() > 0
        {
            character.equippedWeapon = "Magic"
            chooseAttackView.removeFromSuperview()
            openChooseAttack()
        }
    }
    
    func goLongRange()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount() > 0
        {
            character.equippedWeapon = "Long Range"
            chooseAttackView.removeFromSuperview()
            openChooseAttack()
        }
    }
    
    /////////////////////////////////       CHEST FUNCTIONS        ///////////////////////////
    
    //Things in chests: Health Potions, Speed Potions, Damage Potions, etc.                                         1
    //                  Sword Upgrade, Bow Upgrade, Fire Ball Upgrade, Shuriken Upgrade, Crit Chance Upgrade        2
    //                  Armor Upgrade, Speed Upgrade, Health Upgrade, Block Chance Upgrade                          3
    
    func openChest(name: String)
    {
        self.paused = true
        openNotify(name)
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
            times = 4
        }
        else if(chestRarity == "rare")
        {
            times = 10
        }
        else if(chestRarity == "legendary")
        {
            times = 24
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
                settings.characters[settings.selectedPlayer].inventory.add(findName(num))
            case 2:
                let num = randomAttack()
                itemNum.append(num)
                pictures.append(findPhoto(num))
                settings.characters[settings.selectedPlayer].inventory.add(findName(num))
            default:
                let num = randomDefense()
                itemNum.append(num)
                pictures.append(findPhoto(num))
                settings.characters[settings.selectedPlayer].inventory.add(findName(num))
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
                    j -= 1
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
            let amount = UILabel(frame: CGRect(x: chestNotification.frame.width * 0.8, y: chestNotification.frame.height * 0.69, width: chestNotification.frame.width * 0.1, height: chestNotification.frame.height * 0.1))
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
                let closeChestButton = UIButton(frame: CGRect(x: chestNotification.frame.width - chestNotification.frame.height * 0.2, y: chestNotification.frame.height * 0.05, width: chestNotification.frame.height * 0.15, height: chestNotification.frame.height * 0.15))
                closeChestButton.setTitle("X", forState: .Normal)
                closeChestButton.titleLabel?.textColor = UIColor.blackColor()
                closeChestButton.layer.backgroundColor = UIColor.redColor().CGColor
                closeChestButton.layer.borderWidth = closeChestButton.frame.height * 0.1
                closeChestButton.layer.borderColor = UIColor.darkGrayColor().CGColor
                closeChestButton.addTarget(self, action: #selector(GameScene.closeChest), forControlEvents: .TouchUpInside)
                chestNotification.addSubview(closeChestButton)
            }
        }
    }
    
    func findName(type: Int) -> String  //Helper method for inventory
    {
        switch type
        {
        case 1:
            return "Health Potions"
        case 2:
            return "Speed Potions"
        case 3:
            return "Damage Potions"
        case 4:
            return "Block Potions"
        case 5:
            return "Melee"
        case 6:
            return "Long Range"
        case 7:
            return "Magic"
        case 8:
            return "Short Range"
        case 9:
            return "Crit Chance"
        case 10:
            return "Armor"
        case 11:
            return "Agility"
        case 12:
            return "Health"
        default:
            return "Block"
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
            return UIImage(named: "8BitHeart")!
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
    
    func setHearts()        //Add in max health over 10 ability
    {
        for heart in heartBar.subviews
        {
            heart.removeFromSuperview()
        }
        var health = character.currentHealth
        var xMulti: CGFloat = 0
        var yMulti: CGFloat = 0
        while(health - 2 >= 0)
        {
            var heartPicture: UIImageView
            heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*xMulti, y: heartBar.frame.height * (1/3) * yMulti, width: heartBar.frame.width * 0.2, height: heartBar.frame.height * (1/3)))
            heartPicture.image = UIImage(named: "8BitHeart")
            heartBar.addSubview(heartPicture)
            health = health - 2
            xMulti += 1
            if(xMulti % 5 == 0)
            {
                xMulti = 0
                yMulti += 1
            }
        }
        
        let half = health == 1
        if half
        {
            var heartPicture: UIImageView
            heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*xMulti, y: heartBar.frame.height * (1/3) * yMulti, width: heartBar.frame.width * 0.2, height: heartBar.frame.height * (1/3)))
            heartPicture.image = UIImage(named: "8BitHeartHalf")
            heartBar.addSubview(heartPicture)
        }
    }
    
    func setDoor(place: String)
    {
        let door = SKSpriteNode(texture: doorLocked)
        door.zPosition = -1
        doors.append(door)
        switch place {
        case "up":
            door.size = CGSize(width: view!.bounds.width*0.1, height: view!.bounds.height*0.1)
            door.position = CGPoint(x: view!.bounds.width * 0.5, y: view!.bounds.height-view!.bounds.height*0.05)
            door.zRotation = CGFloat(M_PI)
        case "right":
            door.size = CGSize(width: view!.bounds.height*0.1, height: view!.bounds.width*0.1)
            door.position = CGPoint(x: view!.bounds.width - view!.bounds.height*0.05, y: view!.bounds.height*0.5)
            door.zRotation = CGFloat(M_PI_2)
        case "down":
            door.size = CGSize(width: view!.bounds.width*0.1, height: view!.bounds.height*0.1)
            door.position = CGPoint(x: view!.bounds.width * 0.5, y: view!.bounds.height*0.05)
        case "left":
            door.size = CGSize(width: view!.bounds.height*0.1, height: view!.bounds.width*0.1)
            door.position = CGPoint(x: view!.bounds.height * 0.05, y: view!.bounds.height*0.5)
            door.zRotation = 3 * CGFloat(M_PI_2)
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