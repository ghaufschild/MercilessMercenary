//
//  GameScene.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild, and Ryan Ziolkowski on 4/1/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//
//  Coordinates (0,0) are in bottom left

import Foundation
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
    static let Wall      : UInt32 = 0b111     // 7
    static let Heart     : UInt32 = 0b1000    // 8
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
    
    var attackTimer = Timer()
    var moveTimer = Timer()
    var transTimer = Timer()
    var buffTimers: [Timer] = []
    var immortalTimer = Timer()
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
    
    var congrats: UIView!
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
    var keyView: UIImageView!
    var rewardNotifications: [UIView] = []
    var toggleSoundButton = UIButton()
    var toggleMusicButton = UIButton()
    var fastTravelRoom = UIView()
    
    var moveHold: UILongPressGestureRecognizer!
    var attackHold: UILongPressGestureRecognizer!
    var changeRewards: UITapGestureRecognizer!
    
    let player = SKSpriteNode(imageNamed: "playerDown")
    let playerLeft = SKTexture(imageNamed: "playerLeft")
    let playerUp = SKTexture(imageNamed: "playerUp")
    let playerRight = SKTexture(imageNamed: "playerRight")
    let playerDown = SKTexture(imageNamed: "playerDown")
    
    
    var menuButton = SKSpriteNode(imageNamed: "MenuButton")
    
    var heartBar: UIView!
    
    var doors = [SKSpriteNode]()
    var enemyObjects = [Enemy]()
    var healthBars = [SKSpriteNode]()       //Shows health on enemy
    var attackEnemyTimer = Timer()        //Controls how enemies attack
    var moveEnemyTimer = Timer()          //Controls how enemies move
    var availableEnemyLocs = [CGPoint]()    //Locations that an enemy can spawn in
    var extraNodes = [SKSpriteNode]()       //Clear every time you enter a new room
    var extraViews = [UIView]()       //Clear every time you enter a new room
    var doorLocked: SKTexture!
    var doorUnlocked: SKTexture!
    var doorBoss: SKTexture!
    
    let backgroundMusic = SKAudioNode(fileNamed: "eerie theme.mp3")
    
    var invincibleCounter = 0       //After taking damage
    
    //View Did Load
    override func didMove(to view: SKView) {
        
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
        
        self.view?.isMultipleTouchEnabled = true
        
        backgroundMusic.autoplayLooped = true
        backgroundMusic.name = "backgroundMusic"
        addChild(backgroundMusic)
        
        doorLocked = SKTexture(image: UIImage(named: "doorLocked")!)
        doorUnlocked = SKTexture(image: UIImage(named: "doorUnlocked")!)
        doorBoss = SKTexture(image: UIImage(named: "doorBoss")!)
        
        let backgroundImage = SKSpriteNode(imageNamed: "Ground")
        backgroundImage.size = self.scene!.size
        backgroundImage.zPosition = -10
        backgroundImage.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        addChild(backgroundImage)
        
        menuButton.name = "menu"
        menuButton.position = CGPoint(x: size.width * 0.2, y: size.height * 0.95)
        menuButton.size = CGSize(width: size.width * 0.2, height: size.height * 0.1)
        menuButton.isUserInteractionEnabled = false
        menuButton.alpha = 0.8
        addChild(menuButton)
        
        let playerText = SKTexture(cgImage: (UIImage(named: "playerDown")?.cgImage)!)
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        player.size = CGSize(width: size.height*CGFloat(0.06), height: size.height*CGFloat(0.12 ))
        player.physicsBody = SKPhysicsBody(texture: playerText, size: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        menu = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
        menu.layer.borderColor = UIColor.gray.cgColor
        menu.layer.borderWidth = menu.frame.width * 0.01
        menu.layer.backgroundColor = UIColor.brown.cgColor
        
        moveHold = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.moveOnTouch))
        moveHold.minimumPressDuration = 0.0
        attackHold = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.attackOnTouch))
        attackHold.minimumPressDuration = 0.0
        
        let buttonWid = size.width * 0.15
        
        moveView = UIView(frame: CGRect(x: 0, y: size.height * 0.075, width: size.width * 0.5, height: size.height * 0.925))
        moveView.addGestureRecognizer(moveHold)
        moveJoystickOuter = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWid, height: buttonWid))
        moveJoystickOuter.image = UIImage(named: "joystick")
        moveJoystickOuter.alpha = 0.4
        
        attackView = UIView(frame: CGRect(x: size.width * 0.5, y: 0, width: size.width * 0.5, height: size.height))
        attackView.addGestureRecognizer(attackHold)
        attackJoystickOuter = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonWid, height: buttonWid))
        attackJoystickOuter.image = UIImage(named: "joystick")
        attackJoystickOuter.alpha = 0.4
        
        heartBar = UIView(frame: CGRect(x: size.width * 0.74, y: size.height * 0.01, width: size.width * 0.25, height: size.width * 0.15))
        setHearts()
        view.addSubview(heartBar)
        
        let memeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        memeLabel.backgroundColor = UIColor.clear
        moveView.addSubview(memeLabel)
        
        let closeMenuButton = UIButton(frame: CGRect(x: menu.frame.width - menu.frame.height * 0.2, y: menu.frame.height * 0.05, width: menu.frame.height * 0.15, height: menu.frame.height * 0.15))
        closeMenuButton.addTarget(self, action: #selector(GameScene.closeMenu), for: .touchUpInside)
        closeMenuButton.backgroundColor = UIColor.red
        closeMenuButton.setTitle("X", for: UIControl.State())
        closeMenuButton.layer.borderColor = UIColor.darkGray.cgColor
        closeMenuButton.layer.borderWidth = closeMenuButton.frame.width * 0.05
        menu.addSubview(closeMenuButton)
        
        let exitButton = UIButton(frame: CGRect(x: menu.frame.width * 0.7, y: menu.frame.height * 0.85, width: menu.frame.width * 0.2, height: menu.frame.height * 0.1))
        exitButton.backgroundColor = UIColor.red
        exitButton.setTitle("QUIT", for: UIControl.State())
        exitButton.titleLabel?.textColor = UIColor.black
        exitButton.addTarget(self, action: #selector(GameScene.exitGame), for: .touchUpInside)
        menu.addSubview(exitButton)
        
        let menuTitle = UIImageView(frame: CGRect(x: menu.frame.width * 0.4, y: menu.frame.height * 0.05, width: menu.frame.width * 0.2, height: menu.frame.height * 0.1))
        menuTitle.image = UIImage(named: "MenuButton")
        menu.addSubview(menuTitle)
        
        let mapButton = UIButton(frame: CGRect(x: menu.frame.width * 0.15, y: menu.frame.height * 0.2, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        mapButton.setBackgroundImage(UIImage(named: "Map"), for: UIControl.State())
        mapButton.addTarget(self, action: #selector(GameScene.openMap), for: .touchUpInside)
        menu.addSubview(mapButton)
        
        let inventoryButton = UIButton(frame: CGRect(x: menu.frame.width * 0.55, y: menu.frame.height * 0.2, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        inventoryButton.setBackgroundImage(UIImage(named: "Inventory"), for: UIControl.State())
        inventoryButton.addTarget(self, action: #selector(GameScene.openInventory), for: .touchUpInside)
        menu.addSubview(inventoryButton)
        
        let skillsButton = UIButton(frame: CGRect(x: menu.frame.width * 0.15, y: menu.frame.height * 0.4, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        skillsButton.setBackgroundImage(UIImage(named: "Skills"), for: UIControl.State())
        skillsButton.addTarget(self, action: #selector(GameScene.openSkills), for: .touchUpInside)
        menu.addSubview(skillsButton)
        
        let chooseAttackButton = UIButton(frame: CGRect(x: menu.frame.width * 0.55, y: menu.frame.height * 0.4, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        chooseAttackButton.setBackgroundImage(UIImage(named:"AttackType"), for: UIControl.State())
        chooseAttackButton.addTarget(self, action: #selector(GameScene.openChooseAttack), for: .touchUpInside)
        menu.addSubview(chooseAttackButton)
        
        toggleMusicButton = UIButton(frame: CGRect(x: menu.frame.width * 0.6, y: menu.frame.height * 0.55, width: menu.frame.height * 0.1, height: menu.frame.height * 0.1))
        toggleMusicButton.layer.cornerRadius = toggleMusicButton.frame.width * 0.5
        toggleMusicButton.layer.borderColor = UIColor.lightGray.cgColor
        toggleMusicButton.layer.backgroundColor = UIColor.green.cgColor
        toggleMusicButton.layer.borderWidth = toggleMusicButton.frame.width * 0.1
        toggleMusicButton.addTarget(self, action: #selector(GameScene.toggleMusic), for: .touchUpInside)
        menu.addSubview(toggleMusicButton)
        
        let toggleMusicLabel = UILabel(frame: CGRect(x: menu.frame.width * 0.25, y: menu.frame.height * 0.55, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        toggleMusicLabel.text = "Toggle Music:"
        menu.addSubview(toggleMusicLabel)
        
        toggleSoundButton = UIButton(frame: CGRect(x: menu.frame.width * 0.6, y: menu.frame.height * 0.7, width: menu.frame.height * 0.1, height: menu.frame.height * 0.1))
        toggleSoundButton.layer.cornerRadius = toggleMusicButton.frame.width * 0.5
        toggleSoundButton.layer.borderColor = UIColor.lightGray.cgColor
        toggleSoundButton.layer.backgroundColor = UIColor.green.cgColor
        toggleSoundButton.layer.borderWidth = toggleSoundButton.frame.width * 0.1
        toggleSoundButton.addTarget(self, action: #selector(GameScene.toggleSound), for: .touchUpInside)
        menu.addSubview(toggleSoundButton)
        
        let toggleSoundLabel = UILabel(frame: CGRect(x: menu.frame.width * 0.25, y: menu.frame.height * 0.7, width: menu.frame.width * 0.3, height: menu.frame.height * 0.1))
        toggleSoundLabel.text = "Toggle Sound:"
        menu.addSubview(toggleSoundLabel)
        
        view.addSubview(attackView)
        view.addSubview(moveView)
        
        if map.getUp() != nil {
            setDoor("up")
        }
        if map.getRight() != nil {
            setDoor("right")
        }
        if map.getDown() != nil {
            setDoor("down")
        }
        if map.getLeft() != nil {
            setDoor("left")
        }
        unlockDoors()
        
        // 4
        addChild(player)
        
        changeRewards = UITapGestureRecognizer(target: self, action: #selector(GameScene.continueRewards))
        
        chestNotification = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
        chestNotification.backgroundColor = UIColor.brown
        chestNotification.addGestureRecognizer(changeRewards)
        
        let congratsLabel = UILabel(frame: CGRect(x: chestNotification.frame.width * 0.2, y: chestNotification.frame.height * 0.075, width: chestNotification.frame.width * 0.6, height: chestNotification.frame.height * 0.1))
        congratsLabel.text = "CONGRATULATIONS"
        congratsLabel.adjustsFontSizeToFitWidth = true
        congratsLabel.textAlignment = .center
        chestNotification.addSubview(congratsLabel)
        
        speedPotBG = UIView(frame: CGRect(x: size.width * 0.02, y: size.height * 0.11, width: size.width * 0.07, height: size.width * 0.07))
        speedPotBG.layer.backgroundColor = UIColor.brown.cgColor
        speedPotBG.layer.borderColor = UIColor.gray.cgColor
        speedPotBG.layer.borderWidth = speedPotBG.frame.width * 0.05
        speedPot = UIImageView(frame: CGRect(x: size.width * 0.03, y: size.height * 0.11 + size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
        speedPot.image = UIImage(named: "SpeedPot")
        blockPotBG = UIView(frame: CGRect(x: size.width * 0.09, y: size.height * 0.11, width: size.width * 0.07, height: size.width * 0.07))
        blockPotBG.layer.backgroundColor = UIColor.brown.cgColor
        blockPotBG.layer.borderColor = UIColor.gray.cgColor
        blockPotBG.layer.borderWidth = blockPotBG.frame.width * 0.05
        blockPot = UIImageView(frame: CGRect(x: size.width * 0.1, y: size.height * 0.11 + size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
        blockPot.image = UIImage(named: "BlockPot")
        damagePotBG = UIView(frame: CGRect(x: size.width * 0.16, y: size.height * 0.11, width: size.width * 0.07, height: size.width * 0.07))
        damagePotBG.layer.backgroundColor = UIColor.brown.cgColor
        damagePotBG.layer.borderColor = UIColor.gray.cgColor
        damagePotBG.layer.borderWidth = damagePotBG.frame.width * 0.05
        damagePot = UIImageView(frame: CGRect(x: size.width * 0.17, y: size.height * 0.11 + size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
        damagePot.image = UIImage(named: "DamagePot")
        
        checkForKey()
        
        let wallText = SKTexture(cgImage: (UIImage(named: "Wall")?.cgImage)!)
        let wall1 = SKSpriteNode(texture: wallText)
        wall1.size = CGSize(width: size.width, height: size.height * 0.1)
        wall1.position = CGPoint(x: size.width * 0.5, y: size.height * 0.05)
        wall1.zPosition = -2
        wall1.physicsBody = SKPhysicsBody(texture: wallText, size: wall1.size)
        wall1.physicsBody?.isDynamic = true
        wall1.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        wall1.physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        wall1.physicsBody?.collisionBitMask = PhysicsCategory.None
        wall1.physicsBody?.usesPreciseCollisionDetection = false
        
        let wall2 = SKSpriteNode(texture: wallText)
        wall2.size = CGSize(width: size.width, height: size.height * 0.1)
        wall2.position = CGPoint(x: size.width * 0.5, y: size.height * 0.95)
        wall2.zPosition = -2
        wall2.physicsBody = SKPhysicsBody(texture: wallText, size: wall2.size)
        wall2.physicsBody?.isDynamic = true
        wall2.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        wall2.physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        wall2.physicsBody?.collisionBitMask = PhysicsCategory.None
        wall2.physicsBody?.usesPreciseCollisionDetection = false
        
        let wall3 = SKSpriteNode(texture: wallText)
        wall3.size = CGSize(width: size.width, height: size.height * 0.1)
        wall3.position = CGPoint(x: size.height * 0.05, y: size.height * 0.5)
        wall3.zPosition = -2
        wall3.zRotation = CGFloat(Double.pi/2)
        wall3.physicsBody = SKPhysicsBody(texture: wallText, size: wall3.size)
        wall3.physicsBody?.isDynamic = true
        wall3.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        wall3.physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        wall3.physicsBody?.collisionBitMask = PhysicsCategory.None
        wall3.physicsBody?.usesPreciseCollisionDetection = false
        
        let wall4 = SKSpriteNode(texture: wallText)
        wall4.size = CGSize(width: size.width, height: size.height * 0.1)
        wall4.position = CGPoint(x: size.width - size.height * 0.05, y: size.height * 0.5)
        wall4.zPosition = -2
        wall4.zRotation = CGFloat(Double.pi/2)
        wall4.physicsBody = SKPhysicsBody(texture: wallText, size: wall4.size)
        wall4.physicsBody?.isDynamic = true
        wall4.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        wall4.physicsBody?.contactTestBitMask = PhysicsCategory.EnemyProjectile
        wall4.physicsBody?.collisionBitMask = PhysicsCategory.None
        wall4.physicsBody?.usesPreciseCollisionDetection = false
        
        addChild(wall1)
        addChild(wall2)
        addChild(wall3)
        addChild(wall4)
        
        roomCleared = true
        
        loadScreen()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    //////////////////////////      JOYSTICK FUNCTIONS      //////////////////////////////
    
    //Attack Function
    @objc func attack()
    {
        if(canAttack && canDoStuff)
        {
            var projectile: SKSpriteNode!
            var distance: CGFloat = 0
            var soundName = ""
            if(character.equippedWeapon == "Melee")
            {
                projectile = SKSpriteNode(imageNamed: "Sword2")
                projectile.size = CGSize(width: player.size.width * 0.4, height: player.size.height * 0.8)
                distance = size.width * 0.1
                soundName = "swordNoise2.0.m4a"
            }
            if(character.equippedWeapon == "Short Range")
            {
                projectile = SKSpriteNode(imageNamed: "movingShuriken")
                projectile.size = CGSize(width: player.size.width * 0.3, height: player.size.height * 0.3)
                distance = size.width * 0.2
                soundName = "shurikenNoise2.0.m4a"
            }
            if(character.equippedWeapon == "Magic")
            {
                projectile = SKSpriteNode(imageNamed: "Fireball")
                projectile.size = CGSize(width: player.size.width * 0.4, height: player.size.height * 0.4)
                distance = size.width * 0.4
                soundName = "magicNoise2.0.m4a"
            }
            if(character.equippedWeapon == "Long Range")
            {
                projectile = SKSpriteNode(imageNamed: "Long Range")
                projectile.size = CGSize(width: player.size.width * 0.2, height: player.size.height * 0.5)
                distance = size.width * 0.8
                soundName = "bowNoise2.0.m4a"
            }
            
            projectile.position = player.position
            projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
            projectile.physicsBody?.isDynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Wall
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            var offset =  tempAttack - attackLoc
            offset.x *= -1
            addChild(projectile)
            
            extraNodes.append(projectile)
            
            let direction = offset.normalized()
            let shootAmount = direction * distance
            let realDest = shootAmount + projectile.position
            
            projectile.zRotation = atan2(direction.x * -1, direction.y)
            
            let xOffset = offset.x
            let yOffset = offset.y
            let absX = abs(xOffset)
            let absY = abs(yOffset)
            
            if xOffset > 0 && absX >= absY // Right
            {
                player.texture = playerRight
            }
            else if yOffset > 0 && absX <= absY // Up
            {
                player.texture = playerUp
            }
            else if xOffset < 0 && absX >= absY // Left
            {
                player.texture = playerLeft
            }
            else if yOffset < 0 && absX <= absY // Down
            {
                player.texture = playerDown
            }
            else
            {
                player.texture = playerDown
            }
            
            let actionMove = SKAction.move(to: realDest, duration: (1/400) * Double(distance))
            let actionMoveDone = SKAction.removeFromParent()
            if(offset.x != 0 && offset.y != 0)
            {
                projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
                canAttack = false
                _ = Timer.scheduledTimer(timeInterval: 0.16, target: self, selector: #selector(GameScene.letAttack), userInfo: nil, repeats: false)
                if(settings.soundOn)
                {
                    run(SKAction.playSoundFileNamed(soundName, waitForCompletion: false))
                }
            }
            else
            {
                projectile.run(actionMoveDone)
            }
            
        }
    }
    
    func setEnemyLocs(_ place: CGPoint)
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
    
    @objc func letAttack()
    {
        canAttack = true
    }
    
    @objc func mortal()
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
    @objc func move()
    {
        if canDoStuff
        {
            let newPoint = tempMove - moveLoc
            let xOffset = newPoint.x
            let yOffset = newPoint.y
            let absX = abs(xOffset)
            let absY = abs(yOffset)
            var realDest = newPoint
            
            let moveDist: CGFloat = size.width * 0.01 + (CGFloat(character.moveSpeed)/5 + CGFloat(tempSpeed)) * size.width * 0.002
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
                    if map.getDown() != nil && checkForBoss(map.getDown()!)
                    {
                        realDest.y = max(0,realDest.y)
                    }
                    else
                    {
                        realDest.y = max(size.height * 0.1 + player.size.height * 0.5, realDest.y)
                    }
                }
                else
                {
                    if map.getUp() != nil && checkForBoss(map.getUp()!)
                    {
                        realDest.y = min(size.width, realDest.y)
                    }
                    else
                    {
                        realDest.y = min(size.height * 0.9 - player.size.height * 0.5, realDest.y)
                    }
                }
            }
            else
            {
                realDest.y = max(size.height * 0.1 + player.size.height * 0.5, realDest.y)
                realDest.y = min(size.height * 0.9 - player.size.height * 0.5, realDest.y)
            }
            
            if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && roomCleared // In the middle
            {
                if realDest.x < size.width * 0.5
                {
                    if map.getLeft() != nil && checkForBoss(map.getLeft()!)
                    {
                        realDest.x = max(0, realDest.x)
                    }
                    else
                    {
                        realDest.x = max(size.height * 0.1 + player.size.width/2, realDest.x)
                    }
                }
                else
                {
                    if map.getRight() != nil && checkForBoss(map.getRight()!)
                    {
                        realDest.x = min(size.width, realDest.x)
                    }
                    else
                    {
                        realDest.x = min(size.width - size.height * 0.1 - player.size.width/2, realDest.x)
                    }
                }
            }
            else
            {
                realDest.x = max(size.height * 0.1 + player.size.width/2, realDest.x)
                realDest.x = min(size.width - size.height * 0.1 - player.size.width/2, realDest.x)
            }
            
            var door = false
            if realDest.y <= size.height * 0.05// Bottom
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getDown() != nil && roomCleared && checkForBoss(map.getDown()!)
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.9 - player.frame.height * 0.5)
                    map.update(map.getDown()!)
                    door = true
                    transitionClose()
                }
            }
            else if realDest.y >= size.height * 0.95 // Top
            {
                if realDest.x >= size.width * 0.45 && realDest.x <= size.width * 0.55 && map.getUp() != nil && roomCleared && checkForBoss(map.getUp()!)
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.1 + player.frame.height * 0.5)
                    map.update(map.getUp()!)
                    door = true
                    transitionClose()
                }
            }
            else if realDest.x <= size.width * 0.05 // Left
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getLeft() != nil && roomCleared && checkForBoss(map.getLeft()!)
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.9 - player.frame.width * 0.5, y: size.height * 0.5)
                    map.update(map.getLeft()!)
                    door = true
                    transitionClose()
                }
            }
            else if realDest.x >= size.width * 0.95 // Right
            {
                if realDest.y >= size.height * 0.45 && realDest.y <= size.height * 0.55 && map.getRight() != nil && roomCleared && checkForBoss(map.getRight()!)
                {
                    checkForKey()
                    moveTo = CGPoint(x: size.width * 0.1 + player.frame.width * 0.5, y: size.height * 0.5)
                    map.update(map.getRight()!)
                    door = true
                    transitionClose()
                }
            }
            if !door{
                let actionMove = SKAction.move(to: realDest, duration: 0.1)
                player.run(actionMove)
            }
        }
    }
    
    func checkForBoss(_ coor: Coordinate) -> Bool
    {
        if coor.equals(map.getBoss())
        {
            return hasKey
        }
        return true
    }
    
    func checkForKey() {
        if map.visited.contains(map.getKey()) {
            keyView = UIImageView(frame: CGRect(x: size.width * 0.65, y: size.width * 0.01, width: size.width * 0.05, height: size.width * 0.05))
            keyView.image = UIImage(named: "key")
            view?.addSubview(keyView)
            hasKey = true
        } else {
            hasKey = false
        }
    }
    
    func unlockDoors()      //Chance image of doors
    {
        checkForKey()
        for door in doors {
            if(door.texture == doorLocked) {
                door.texture = doorUnlocked
            } else if(door.texture == doorBoss) {
                if hasKey {
                    door.texture = doorUnlocked
                }
            }
        }
    }
    
    /////////////////////////////////       TOUCH FUNCTIONS        /////////////////////////////////
    
    @objc func moveOnTouch() {
        if(!moveTimer.isValid) {
            tempMove = moveHold.location(in: moveView)
            moveLoc = moveHold.location(in: moveView)
            
            moveJoystickOuter.center = moveLoc
            moveView.addSubview(moveJoystickOuter)
            
            moveTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(move as () -> Void), userInfo: nil, repeats: true)
            move()
        }
        else if(moveHold.state == UIGestureRecognizer.State.changed) {
            moveLoc = moveHold.location(in: moveView)
        } else {
            moveTimer.invalidate()
            moveJoystickOuter.removeFromSuperview()
        }
    }
    
    @objc func attackOnTouch() {
        if(!attackTimer.isValid) {
            tempAttack = attackHold.location(in: attackView)
            attackLoc = attackHold.location(in: attackView)
            
            attackJoystickOuter.center = attackLoc
            attackView.addSubview(attackJoystickOuter)
            
            attackTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(GameScene.attack), userInfo: nil, repeats: true)
            attack()
        } else if(attackHold.state == UIGestureRecognizer.State.changed) {
            attackLoc = attackHold.location(in: attackView)
        } else {
            attackJoystickOuter.removeFromSuperview()
            attackTimer.invalidate()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let positionInScene = touches.first?.location(in: self)
        let touchedNode = self.atPoint(positionInScene!)
        
        if(touchedNode.name == "menu") {
            if(!self.isPaused) {
                openMenu()
            }
        }
    }
    
    /////////////////////////        TRANSITION FUNCTIONS          //////////////////////////////
    
    func transitionClose() {
        save()
        canDoStuff = false
        transitionView = UIView(frame: CGRect(x: 0, y: 0, width: size.width*2.5, height: size.width*2.5))
        transitionView.layer.cornerRadius = transitionView.frame.width * 0.5
        transitionView.layer.backgroundColor = UIColor.clear.cgColor
        transitionView.layer.borderColor = UIColor.black.cgColor
        transitionView.layer.borderWidth = 10
        transitionView.clipsToBounds = true
        transitionView.center = player.position
        fixY()
        self.view?.addSubview(transitionView)
        transTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(GameScene.incWidth), userInfo: nil, repeats: true)
    }
    
    func transitionOpen()
    {
        removeChildren(in: doors)
        doors.removeAll()
        if map.getUp() != nil {
            setDoor("up")
        }
        if map.getRight() != nil {
            setDoor("right")
        }
        if map.getDown() != nil {
            setDoor("down")
        }
        if map.getLeft() != nil {
            setDoor("left")
        }
        loadScreen()
        transTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(GameScene.decWidth), userInfo: nil, repeats: true)
    }
    
    @objc func incWidth()
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
    
    @objc func decWidth()
    {
        transitionView.layer.borderWidth -= transitionView.frame.width * 0.01
        if(transitionView.layer.borderWidth <= 0)
        {
            transTimer.invalidate()
            transitionView.removeFromSuperview()
            if(!view!.subviews.contains(menu))
            {
                player.isPaused = false
                canDoStuff = true
            }
        }
    }
    
    func fixY()
    {
        transitionView.center.y = view!.frame.maxY - transitionView.center.y
    }
    
    func loadScreen()
    {
        for node in extraNodes
        {
            node.removeFromParent()
        }
        
        if(character.map.getCurr().chest != nil)
        {
            let chest = SKSpriteNode(imageNamed: "\(character.map.getCurr().chest!)")
            chest.position = CGPoint(x: size.width * 0.2, y: size.height * 0.8)
            chest.size = CGSize(width: size.width * 0.05, height: size.height * 0.05)
            chest.physicsBody = SKPhysicsBody(rectangleOf: chest.size)
            chest.physicsBody?.isDynamic = true
            chest.physicsBody?.categoryBitMask = PhysicsCategory.Chest
            chest.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            chest.physicsBody?.collisionBitMask = PhysicsCategory.None
            chest.physicsBody?.usesPreciseCollisionDetection = false
            chest.name = "\(character.map.getCurr().chest!)"
            addChild(chest)
            extraNodes.append(chest)
        }
        
        if(map.cleared.contains(map.getCurr()) || map.spawnPoint.equals(map.getCurr()))
        {
            roomCleared = true
            unlockDoors()
        }
        else if(map.getCurr() != map.bossPoint)
        {
            addMonster(1)
            addMonster(1)
            addMonster(2)
            addMonster(2)
            roomCleared = false
        }
        else
        {
            addMonster(3)
            addMonster(2)
            addMonster(2)
            addMonster(2)
            roomCleared = false
        }
    }
    
    /////////////////////////////////       MONSTER COLLISIONS      //////////////////////////
    
    func addMonster(_ num : Int)      //Num is type of enemy, 1 is ranged, 2 is melee(run into you), 3 is boss
    {
        // Create sprite
        let monster: SKSpriteNode!
        var enemy: Enemy!
        if(num == 1)
        {
            monster = SKSpriteNode(imageNamed: "EnemyRanged")
            monster.size = CGSize(width: player.size.width * 1.5, height: player.size.height)
            enemy = Enemy(h: 5, dam: 1, move: 10, num: 1, enemy: monster)
        }
        else if(num == 2)
        {
            monster = SKSpriteNode(imageNamed: "EnemyMelee")
            monster.size = CGSize(width: player.size.height, height: player.size.width * 1.5)
            enemy = Enemy(h: 10, dam: 1, move: 20, num: 2, enemy: monster)
        }
        else
        {
            monster = SKSpriteNode(imageNamed: "EnemyBoss")
            monster.size = CGSize(width: player.size.width * 2, height: player.size.height * 2)
            enemy = Enemy(h: 25, dam: 3, move: 5, num: 3, enemy: monster)
        }
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        let index = Int(arc4random_uniform(UInt32(availableEnemyLocs.count)))
        
        if availableEnemyLocs.count > 0
        {
            monster.position = availableEnemyLocs[index]
            availableEnemyLocs.remove(at: index)
            
            addChild(monster)
            enemyObjects.append(enemy)
        }
        
        if !attackEnemyTimer.isValid
        {
            attackEnemyTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameScene.attackPerson), userInfo: nil, repeats: true)
        }
        if !moveEnemyTimer.isValid
        {
            moveEnemyTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameScene.moveEnemyAround), userInfo: nil, repeats: true)
        }
        
        let totalHealthView = SKSpriteNode(color: UIColor.red, size: CGSize(width: monster.size.width, height: monster.size.height * 0.1))
        totalHealthView.position = CGPoint(x: monster.frame.midX, y: monster.frame.maxY + totalHealthView.frame.height/2 + 10)
        addChild(totalHealthView)
        let currHealthView = SKSpriteNode(color: UIColor.green, size: CGSize(width: monster.size.width, height: monster.size.height * 0.1))
        currHealthView.position = CGPoint(x: monster.frame.midX, y: monster.frame.maxY + totalHealthView.frame.height/2 + 10)
        addChild(currHealthView)
        
        healthBars.append(totalHealthView)
        healthBars.append(currHealthView)
    }
    
    @objc func moveEnemyAround()
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
                let move = SKAction.move(to: loc, duration: 1.0)
                let displacement = SKAction.move(by: delta, duration: 1.0)
                
                healthBars[num * 2].run(displacement)
                healthBars[num * 2 + 1].run(displacement)
                enemyObjects[num].sprite.run(move)
            }
        }
    }
    
    @objc func attackPerson()
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
    
    func enemyProjectile(_ loc: CGPoint, dam: Int)
    {
        let projectile: SKSpriteNode!
        if(dam == 1)
        {
            projectile = SKSpriteNode(imageNamed: "Needle")
        }
        else
        {
            projectile = SKSpriteNode(imageNamed: "BossShot")
        }
        
        let distance: CGFloat = size.width * 0.8
        
        projectile.position = loc
        projectile.size = CGSize(width: player.size.width * 0.4, height: player.size.height * 0.4)
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.EnemyProjectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        projectile.name = "\(dam)"
        
        let offset = player.position - loc
        addChild(projectile)
        
        extraNodes.append(projectile)
        
        let direction = offset.normalized()
        let shootAmount = direction * distance
        let realDest = shootAmount + projectile.position
        
        projectile.zRotation = atan2(direction.x * -1, direction.y)
        
        let actionMove = SKAction.move(to: realDest, duration: 3.5)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func playerDies()
    {
        map.currLoc = map.respawnPoint
    }
    
    func projectileDidCollideWithMonster(_ monster: SKSpriteNode, projectile: SKSpriteNode) {     //Check for damage against enemy
        projectile.removeFromParent()
        var damage = tempDamage
        if(character.equippedWeapon == "Melee")
        {
            damage += 4 * (settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount()/5 + 1)
        }
        if(character.equippedWeapon == "Short Range")
        {
            damage += 3 * (settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount()/5 + 1)
        }
        if(character.equippedWeapon == "Magic")
        {
            damage += 2 * (settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount()/5 + 1)
            
        }
        if(character.equippedWeapon == "Long Range")
        {
            damage += (settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount()/5 + 1)
        }
        
        for num in 0..<enemyObjects.count
        {
            if enemyObjects[num].sprite == monster
            {
                if !enemyObjects[num].gotHit(damage)
                {
                    enemyObjects.remove(at: num)
                    healthBars[num * 2].removeFromParent()
                    healthBars.remove(at: num * 2)
                    healthBars[num * 2].removeFromParent()
                    healthBars.remove(at: num * 2)
                    monster.removeFromParent()
                    dropHeart(monster.position)
                    if enemyObjects.count == 0
                    {
                        roomCleared = true
                        unlockDoors()
                        map.cleared(map.getCurr())
                        checkWin()
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
    
    func dropHeart(_ place: CGPoint)
    {
        if(Int(arc4random_uniform(100)) < 20)
        {
            let heartText = SKTexture(imageNamed: "8BitHeartHalfFull")
            let heart = SKSpriteNode(texture: heartText)
            heart.position = place
            heart.size = CGSize(width: player.size.width * 0.5 , height: player.size.height * 0.5)
            heart.zPosition = -1
            heart.physicsBody = SKPhysicsBody(texture: heartText, size: heart.size)
            heart.physicsBody?.isDynamic = true
            heart.physicsBody?.categoryBitMask = PhysicsCategory.Heart
            heart.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            heart.physicsBody?.collisionBitMask = PhysicsCategory.None
            heart.physicsBody?.usesPreciseCollisionDetection = false
            addChild(heart)
            extraNodes.append(heart)
        }
    }
    
    func flickerMonster(_ num: Int)
    {
        enemyObjects[num].flicker()
    }
    
    func PlayerDidCollideWithHeart(_ player: SKSpriteNode, heart: SKSpriteNode) {
        if(character.currentHealth < character.maxHealth + (character.inventory.get("Health")!.getAmount()/5))
        {
            character.currentHealth = min(character.currentHealth + 1, character.maxHealth + (character.inventory.get("Health")!.getAmount()/5))
            setHearts()
        }
        heart.removeFromParent()
    }
    
    func projectileDidCollideWithPlayer(_ projectile: SKSpriteNode, player: SKSpriteNode) {
        projectile.removeFromParent()
        if(character.currentHealth > 0)
        {
            if(Int(arc4random_uniform(25)) > character.inventory.get("Block Chance")!.getAmount()/5 + tempBlock)
            {
                if(canTakeDamage)
                {
                    canTakeDamage = false
                    immortalTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.mortal), userInfo: nil, repeats: true)
                    character.currentHealth = character.currentHealth - Int(projectile.name!)!
                }
            }
            else
            {
                if(settings.soundOn)
                {
                    run(SKAction.playSoundFileNamed("blockNoise2.0.m4a", waitForCompletion: false))
                }
            }
        }
        if character.currentHealth > 0
        {
            setHearts()
        }
        if character.currentHealth <= 0
        {
            character.currentHealth = character.maxHealth
            map.currLoc = map.respawnPoint
            exitGame()
        }
    }
    
    func playerDidCollideWithMonster(_ monster: SKSpriteNode, player: SKSpriteNode) {
        if(character.currentHealth > 0) {
            if(canTakeDamage) {
                canTakeDamage = false
                immortalTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.mortal), userInfo: nil, repeats: true)
                if(Int(arc4random_uniform(25)) > character.inventory.get("Armor")!.getAmount()/5)
                {
                    character.currentHealth = character.currentHealth - 2
                }
                else
                {
                    if(settings.soundOn)
                    {
                        run(SKAction.playSoundFileNamed("armorNoise2.0.m4a", waitForCompletion: false))
                    }
                }
                
            }
            
        }
        if character.currentHealth > 0
        {
            setHearts()
        }
        if character.currentHealth <= 0
        {
            character.currentHealth = character.maxHealth
            map.currLoc = map.respawnPoint
            exitGame()
        }
    }
    
    func playerDidCollideWithChest(_ player: SKSpriteNode, chest: SKSpriteNode)
    {
        openChest(chest.name!)
        character.map.getCurr().chest = nil
        chest.removeFromParent()
    }
    
    func projectileDidCollideWithWall(_ projectile: SKSpriteNode, wall: SKSpriteNode)
    {
        projectile.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact)
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
        // 7 is wall
        // 8 is heart
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
        else if(firstBody.categoryBitMask == 2 && secondBody.categoryBitMask == 7)  //projectile and wall
        {
            if(firstBody.node != nil)
            {
                projectileDidCollideWithWall(firstBody.node as! SKSpriteNode, wall: secondBody.node as! SKSpriteNode)
            }
        }
        else if(firstBody.categoryBitMask == 6 && secondBody.categoryBitMask == 7)  //enemyProjectile and wall
        {
            if(firstBody.node != nil)
            {
                projectileDidCollideWithWall(firstBody.node as! SKSpriteNode, wall: secondBody.node as! SKSpriteNode)
            }
        }
        else if(firstBody.categoryBitMask == 3 && secondBody.categoryBitMask == 8)  //player and heart
        {
            if(secondBody.node != nil)
            {
                PlayerDidCollideWithHeart(firstBody.node as! SKSpriteNode, heart: secondBody.node as! SKSpriteNode)
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
                child.isPaused = true
            }
        }
        
        for timer in buffTimers
        {
            timer.invalidate()
        }
        view?.addSubview(menu)
    }
    
    @objc func closeMenu()
    {
        menu.removeFromSuperview()
        canDoStuff = true
        if tempSpeed > 0
        {
            buffTimers.append(Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.reduceSpeed), userInfo: nil, repeats: true))
        }
        if tempBlock > 0
        {
            buffTimers.append(Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.reduceBlock), userInfo: nil, repeats: true))
            view?.addSubview(blockPotBG)
            view?.addSubview(blockPot)
        }
        if tempDamage > 0
        {
            buffTimers.append(Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.reduceDamage), userInfo: nil, repeats: true))
            view?.addSubview(damagePotBG)
            view?.addSubview(damagePot)
        }
        for child in (self.scene?.children)!
        {
            child.isPaused = false
        }
    }
    
    @objc func toggleSound()
    {
        settings.soundOn = !settings.soundOn
        if(settings.soundOn)
        {
            toggleSoundButton.layer.backgroundColor = UIColor.green.cgColor
        }
        else
        {
            toggleSoundButton.layer.backgroundColor = UIColor.red.cgColor
        }
    }
    
    @objc func toggleMusic()
    {
        settings.musicOn = !settings.musicOn
        if(settings.musicOn)
        {
            toggleMusicButton.layer.backgroundColor = UIColor.green.cgColor
            let volumeUp = SKAction.changeVolume(to: 1, duration: 0)
            backgroundMusic.run(volumeUp)
        }
        else
        {
            toggleMusicButton.layer.backgroundColor = UIColor.red.cgColor
            let volumeDown = SKAction.changeVolume(to: 0, duration: 0)
            backgroundMusic.run(volumeDown)
        }
    }
    
    @objc func openMap()
    {
        mapView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        mapView.backgroundColor = UIColor.brown
        let closeMapButton = UIButton(frame: CGRect(x: mapView.frame.width - mapView.frame.height * 0.2, y: mapView.frame.height * 0.05, width: mapView.frame.height * 0.15, height: mapView.frame.height * 0.15))
        closeMapButton.addTarget(self, action: #selector(GameScene.closeMap), for: .touchUpInside)
        closeMapButton.backgroundColor = UIColor.red
        closeMapButton.setTitle("X", for: UIControl.State())
        closeMapButton.layer.borderColor = UIColor.darkGray.cgColor
        closeMapButton.layer.borderWidth = closeMapButton.frame.width * 0.1
        mapView.addSubview(closeMapButton)
        
        let maxW = CGFloat(map.getWidth()) + 2
        let maxW2 = maxW + 1
        let max2 = maxW * 2
        
        menu.addSubview(mapView)
        for spot in map.known
        {
            var x = CGFloat(spot.getCoor().0)
            x *= mapView.frame.width
            x *= 1/maxW
            x += mapView.frame.width * 1/max2
            var y = CGFloat(spot.getCoor().1)
            y *= mapView.frame.height
            y *= 1/maxW
            y += mapView.frame.width * 1/max2
            let width = mapView.frame.width * 1/maxW2
            let height = mapView.frame.height * 1/maxW2
            let place = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            place.layer.backgroundColor = UIColor.black.cgColor
            place.layer.cornerRadius = place.frame.width * 0.2
            if(spot.equals(map.getBoss())) {
                place.layer.backgroundColor = UIColor.red.cgColor
            }
            mapView.addSubview(place)
        }
        for spot in map.visited
        {
            var x = CGFloat(spot.getCoor().0)
            x *= mapView.frame.width
            x *= 1/maxW
            x += mapView.frame.width * 1/max2
            var y = CGFloat(spot.getCoor().1)
            y *= mapView.frame.height
            y *= 1/maxW
            y += mapView.frame.width * 1/max2
            let width = mapView.frame.width * 1/maxW2
            let height = mapView.frame.height * 1/maxW2
            let place = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
            place.layer.backgroundColor = UIColor.lightGray.cgColor
            if(spot.equals(map.getBoss())) {
                let symbol = UIView(frame: CGRect(x: place.frame.width * 0.4, y: place.frame.height * 0.3, width: place.frame.width * 0.2, height: place.frame.height * 0.4))
                symbol.backgroundColor = UIColor.red
                place.addSubview(symbol)            }
            if(spot.equals(map.getCurr()))
            {
                place.layer.backgroundColor = UIColor.white.cgColor
            }
            if(spot.equals(map.getSpawn()))
            {
                let symbol = UIView(frame: CGRect(x: place.frame.width * 0.4, y: place.frame.height * 0.3, width: place.frame.width * 0.2, height: place.frame.height * 0.4))
                symbol.backgroundColor = UIColor.yellow
                place.addSubview(symbol)
            }
            if(spot.equals(map.getKey()))
            {
                let symbol = UIView(frame: CGRect(x: place.frame.width * 0.4, y: place.frame.height * 0.3, width: place.frame.width * 0.2, height: place.frame.height * 0.4))
                symbol.backgroundColor = UIColor.green
                place.addSubview(symbol)
            }
            place.layer.cornerRadius = place.frame.width * 0.2
            if map.cleared.contains(spot)
            {
                let fastTravel = UITapGestureRecognizer(target: self, action: #selector(GameScene.fastTravel))
                place.addGestureRecognizer(fastTravel)
                place.tag = spot.x * 10 + spot.y
            }
            mapView.addSubview(place)
        }
    }
    
    @objc func closeMap()
    {
        mapView.removeFromSuperview()
    }
    
    @objc func openInventory()
    {
        potionsView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        potionsView.backgroundColor = UIColor.brown
        let closeInventoryButton = UIButton(frame: CGRect(x: potionsView.frame.width - potionsView.frame.height * 0.2, y: potionsView.frame.height * 0.05, width: potionsView.frame.height * 0.15, height: potionsView.frame.height * 0.15))
        closeInventoryButton.addTarget(self, action: #selector(GameScene.closeInventory), for: .touchUpInside)
        closeInventoryButton.backgroundColor = UIColor.red
        closeInventoryButton.setTitle("X", for: UIControl.State())
        closeInventoryButton.layer.borderColor = UIColor.darkGray.cgColor
        closeInventoryButton.layer.borderWidth = closeInventoryButton.frame.width * 0.1
        potionsView.addSubview(closeInventoryButton)
        
        //HEALTH POT INFO
        let healthPotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.125, y: potionsView.frame.height * 0.075, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        healthPotView.layer.backgroundColor = UIColor.lightGray.cgColor
        healthPotView.layer.borderColor = UIColor.darkGray.cgColor
        healthPotView.layer.borderWidth = healthPotView.frame.height * 0.05
        let healthPotImage = UIImageView(frame: CGRect(x: healthPotView.frame.height * 0.1, y: healthPotView.frame.height * 0.1, width: healthPotView.frame.height * 0.6, height: healthPotView.frame.height * 0.6))
        healthPotImage.image = UIImage(named: "HealthPot")
        healthPotView.addSubview(healthPotImage)
        let healthPotLabel = UILabel(frame: CGRect(x: healthPotView.frame.width * 0.05, y: healthPotView.frame.height * 0.75, width: healthPotView.frame.width * 0.95, height: healthPotView.frame.height * 0.2))
        healthPotLabel.text = "Health Potions"
        healthPotLabel.textAlignment = .center
        healthPotView.addSubview(healthPotLabel)
        let healthPotAmount = UILabel(frame: CGRect(x: healthPotView.frame.width * 0.7, y: healthPotView.frame.height * 0.6, width: healthPotView.frame.width * 0.25, height: healthPotView.frame.height * 0.15))
        healthPotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Health Potions")!.getAmount())"
        healthPotView.addSubview(healthPotAmount)
        let healthTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useHealth))
        healthPotView.addGestureRecognizer(healthTapped)
        potionsView.addSubview(healthPotView)
        
        //SPEED POT INFO
        let speedPotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.55, y: potionsView.frame.height * 0.075, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        speedPotView.layer.backgroundColor = UIColor.lightGray.cgColor
        speedPotView.layer.borderColor = UIColor.darkGray.cgColor
        speedPotView.layer.borderWidth = speedPotView.frame.height * 0.05
        let speedPotImage = UIImageView(frame: CGRect(x: speedPotView.frame.height * 0.1, y: speedPotView.frame.height * 0.1, width: speedPotView.frame.height * 0.6, height: speedPotView.frame.height * 0.6))
        speedPotImage.image = UIImage(named: "SpeedPot")
        speedPotView.addSubview(speedPotImage)
        let speedPotLabel = UILabel(frame: CGRect(x: speedPotView.frame.width * 0.05, y: speedPotView.frame.height * 0.75, width: speedPotView.frame.width * 0.95, height: speedPotView.frame.height * 0.2))
        speedPotLabel.text = "Speed Potions"
        speedPotLabel.textAlignment = .center
        speedPotView.addSubview(speedPotLabel)
        let speedPotAmount = UILabel(frame: CGRect(x: speedPotView.frame.width * 0.7, y: speedPotView.frame.height * 0.6, width: speedPotView.frame.width * 0.25, height: speedPotView.frame.height * 0.15))
        speedPotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Speed Potions")!.getAmount())"
        speedPotView.addSubview(speedPotAmount)
        let speedTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useSpeed))
        speedPotView.addGestureRecognizer(speedTapped)
        potionsView.addSubview(speedPotView)
        
        //DAMAGE POT INFO
        let damagePotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.125, y: potionsView.frame.height * 0.525, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        damagePotView.layer.backgroundColor = UIColor.lightGray.cgColor
        damagePotView.layer.borderColor = UIColor.darkGray.cgColor
        damagePotView.layer.borderWidth = damagePotView.frame.height * 0.05
        let damagePotImage = UIImageView(frame: CGRect(x: damagePotView.frame.height * 0.1, y: damagePotView.frame.height * 0.1, width: damagePotView.frame.height * 0.6, height: damagePotView.frame.height * 0.6))
        damagePotImage.image = UIImage(named: "DamagePot")
        damagePotView.addSubview(damagePotImage)
        let damagePotLabel = UILabel(frame: CGRect(x: damagePotView.frame.width * 0.05, y: damagePotView.frame.height * 0.75, width: damagePotView.frame.width * 0.95, height: damagePotView.frame.height * 0.2))
        damagePotLabel.text = "Damage Potions"
        damagePotLabel.textAlignment = .center
        damagePotView.addSubview(damagePotLabel)
        let damagePotAmount = UILabel(frame: CGRect(x: damagePotView.frame.width * 0.7, y: damagePotView.frame.height * 0.6, width: damagePotView.frame.width * 0.25, height: damagePotView.frame.height * 0.15))
        damagePotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Damage Potions")!.getAmount())"
        damagePotView.addSubview(damagePotAmount)
        let damageTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useDamage))
        damagePotView.addGestureRecognizer(damageTapped)
        potionsView.addSubview(damagePotView)
        
        //BLOCK POT INFO
        let blockPotView = UIView(frame: CGRect(x: potionsView.frame.width * 0.55, y: potionsView.frame.height * 0.525, width: potionsView.frame.width * 0.3, height: potionsView.frame.height * 0.4))
        blockPotView.layer.backgroundColor = UIColor.lightGray.cgColor
        blockPotView.layer.borderColor = UIColor.darkGray.cgColor
        blockPotView.layer.borderWidth = blockPotView.frame.height * 0.05
        let blockPotImage = UIImageView(frame: CGRect(x: blockPotView.frame.height * 0.1, y: blockPotView.frame.height * 0.1, width: blockPotView.frame.height * 0.6, height: blockPotView.frame.height * 0.6))
        blockPotImage.image = UIImage(named: "BlockPot")
        blockPotView.addSubview(blockPotImage)
        let blockPotLabel = UILabel(frame: CGRect(x: blockPotView.frame.width * 0.05, y: blockPotView.frame.height * 0.75, width: blockPotView.frame.width * 0.95, height: blockPotView.frame.height * 0.2))
        blockPotLabel.text = "Block Potions"
        blockPotLabel.textAlignment = .center
        blockPotView.addSubview(blockPotLabel)
        let blockPotAmount = UILabel(frame: CGRect(x: blockPotView.frame.width * 0.7, y: blockPotView.frame.height * 0.6, width: blockPotView.frame.width * 0.25, height: blockPotView.frame.height * 0.15))
        blockPotAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Block Potions")!.getAmount())"
        blockPotView.addSubview(blockPotAmount)
        let blockTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.useBlock))
        blockPotView.addGestureRecognizer(blockTapped)
        potionsView.addSubview(blockPotView)
        
        if(tempDamage > 0)
        {
            damagePotView.layer.backgroundColor = UIColor.blue.cgColor
        }
        if(tempSpeed > 0)
        {
            speedPotView.layer.backgroundColor = UIColor.blue.cgColor
        }
        if(tempBlock > 0)
        {
            blockPotView.layer.backgroundColor = UIColor.blue.cgColor
        }
        
        menu.addSubview(potionsView)
    }
    
    @objc func closeInventory()
    {
        potionsView.removeFromSuperview()
    }
    
    @objc func openSkills()
    {
        skillsView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        skillsView.backgroundColor = UIColor.brown
        let closeSkillsButton = UIButton(frame: CGRect(x: skillsView.frame.width - skillsView.frame.height * 0.2, y: skillsView.frame.height * 0.05, width: skillsView.frame.height * 0.15, height: skillsView.frame.height * 0.15))
        closeSkillsButton.addTarget(self, action: #selector(GameScene.closeSkills), for: .touchUpInside)
        closeSkillsButton.backgroundColor = UIColor.red
        closeSkillsButton.setTitle("X", for: UIControl.State())
        closeSkillsButton.layer.borderColor = UIColor.darkGray.cgColor
        closeSkillsButton.layer.borderWidth = closeSkillsButton.frame.width * 0.1
        skillsView.addSubview(closeSkillsButton)
        
        //ARMOR  INFO
        let armorView = UIView(frame: CGRect(x: skillsView.frame.width * 0.13, y: skillsView.frame.height * 0.075, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        armorView.layer.backgroundColor = UIColor.lightGray.cgColor
        armorView.layer.borderColor = UIColor.darkGray.cgColor
        armorView.layer.borderWidth = armorView.frame.height * 0.05
        let armorImage = UIImageView(frame: CGRect(x: armorView.frame.height * 0.1, y: armorView.frame.height * 0.1, width: armorView.frame.height * 0.6, height: armorView.frame.height * 0.6))
        armorImage.image = UIImage(named: "Armor")
        armorView.addSubview(armorImage)
        let armorLabel = UILabel(frame: CGRect(x: armorView.frame.width * 0.05, y: armorView.frame.height * 0.75, width: armorView.frame.width * 0.95, height: armorView.frame.height * 0.2))
        armorLabel.text = "Armor"
        armorLabel.textAlignment = .center
        armorView.addSubview(armorLabel)
        let armorAmount = UILabel(frame: CGRect(x: armorView.frame.width * 0.7, y: armorView.frame.height * 0.6, width: armorView.frame.width * 0.25, height: armorView.frame.height * 0.15))
        armorAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Armor")!.getAmount()/5)"
        let armAmount = (settings.characters[settings.selectedPlayer].inventory.get("Armor")!.getAmount() % 5)
        let sectionWidth = (armorView.frame.width - armorView.frame.height * 0.75)/7
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: armorView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: armorView.frame.height * 0.2, width: sectionWidth, height: armorView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < armAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            armorView.addSubview(progressBar)
        }
        armorView.addSubview(armorAmount)
        skillsView.addSubview(armorView)
        
        //agility  INFO
        let agilityView = UIView(frame: CGRect(x: skillsView.frame.width * 0.56, y: skillsView.frame.height * 0.075, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        agilityView.layer.backgroundColor = UIColor.lightGray.cgColor
        agilityView.layer.borderColor = UIColor.darkGray.cgColor
        agilityView.layer.borderWidth = agilityView.frame.height * 0.05
        let agilityImage = UIImageView(frame: CGRect(x: agilityView.frame.height * 0.1, y: agilityView.frame.height * 0.1, width: agilityView.frame.height * 0.6, height: agilityView.frame.height * 0.6))
        agilityImage.image = UIImage(named: "Speed")
        agilityView.addSubview(agilityImage)
        let agilityLabel = UILabel(frame: CGRect(x: agilityView.frame.width * 0.05, y: agilityView.frame.height * 0.75, width: agilityView.frame.width * 0.95, height: agilityView.frame.height * 0.2))
        agilityLabel.text = "Agility"
        agilityLabel.textAlignment = .center
        agilityView.addSubview(agilityLabel)
        let agilityAmount = UILabel(frame: CGRect(x: agilityView.frame.width * 0.7, y: agilityView.frame.height * 0.6, width: agilityView.frame.width * 0.25, height: agilityView.frame.height * 0.15))
        agilityAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Agility")!.getAmount()/5)"
        let agilAmount = (settings.characters[settings.selectedPlayer].inventory.get("Agility")!.getAmount() % 5)
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: agilityView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: agilityView.frame.height * 0.2, width: sectionWidth, height: agilityView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < agilAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            agilityView.addSubview(progressBar)
        }
        agilityView.addSubview(agilityAmount)
        skillsView.addSubview(agilityView)
        
        //health  INFO
        let healthView = UIView(frame: CGRect(x: skillsView.frame.width * 0.025, y: skillsView.frame.height * 0.525, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        healthView.layer.backgroundColor = UIColor.lightGray.cgColor
        healthView.layer.borderColor = UIColor.darkGray.cgColor
        healthView.layer.borderWidth = healthView.frame.height * 0.05
        let healthImage = UIImageView(frame: CGRect(x: healthView.frame.height * 0.1, y: healthView.frame.height * 0.1, width: healthView.frame.height * 0.6, height: healthView.frame.height * 0.6))
        healthImage.image = UIImage(named: "8BitHeart")
        healthView.addSubview(healthImage)
        let healthLabel = UILabel(frame: CGRect(x: healthView.frame.width * 0.05, y: healthView.frame.height * 0.75, width: healthView.frame.width * 0.95, height: healthView.frame.height * 0.2))
        healthLabel.text = "Health"
        healthLabel.textAlignment = .center
        healthView.addSubview(healthLabel)
        let healthAmount = UILabel(frame: CGRect(x: healthView.frame.width * 0.7, y: healthView.frame.height * 0.6, width: healthView.frame.width * 0.25, height: healthView.frame.height * 0.15))
        healthAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Health")!.getAmount()/5)"
        let healAmount = (settings.characters[settings.selectedPlayer].inventory.get("Health")!.getAmount() % 5)
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: healthView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: healthView.frame.height * 0.2, width: sectionWidth, height: healthView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < healAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            healthView.addSubview(progressBar)
        }
        healthView.addSubview(healthAmount)
        skillsView.addSubview(healthView)
        
        //crit  INFO
        let critView = UIView(frame: CGRect(x: skillsView.frame.width * 0.35, y: skillsView.frame.height * 0.525, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        critView.layer.backgroundColor = UIColor.lightGray.cgColor
        critView.layer.borderColor = UIColor.darkGray.cgColor
        critView.layer.borderWidth = critView.frame.height * 0.05
        let critImage = UIImageView(frame: CGRect(x: critView.frame.height * 0.1, y: critView.frame.height * 0.1, width: critView.frame.height * 0.6, height: critView.frame.height * 0.6))
        critImage.image = UIImage(named: "Crit Chance")
        critView.addSubview(critImage)
        let critLabel = UILabel(frame: CGRect(x: critView.frame.width * 0.05, y: critView.frame.height * 0.75, width: critView.frame.width * 0.95, height: critView.frame.height * 0.2))
        critLabel.text = "Crit Chance"
        critLabel.textAlignment = .center
        critView.addSubview(critLabel)
        let critAmount = UILabel(frame: CGRect(x: critView.frame.width * 0.7, y: critView.frame.height * 0.6, width: critView.frame.width * 0.25, height: critView.frame.height * 0.15))
        critAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Crit Chance")!.getAmount()/5)"
        let criAmount = (settings.characters[settings.selectedPlayer].inventory.get("Crit Chance")!.getAmount() % 5)
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: critView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: critView.frame.height * 0.2, width: sectionWidth, height: critView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < criAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            critView.addSubview(progressBar)
        }
        critView.addSubview(critAmount)
        skillsView.addSubview(critView)
        
        //BLOCK  INFO
        let blockView = UIView(frame: CGRect(x: skillsView.frame.width * 0.675, y: skillsView.frame.height * 0.525, width: skillsView.frame.width * 0.3, height: skillsView.frame.height * 0.4))
        blockView.layer.backgroundColor = UIColor.lightGray.cgColor
        blockView.layer.borderColor = UIColor.darkGray.cgColor
        blockView.layer.borderWidth = blockView.frame.height * 0.05
        let blockImage = UIImageView(frame: CGRect(x: blockView.frame.height * 0.1, y: blockView.frame.height * 0.1, width: blockView.frame.height * 0.6, height: blockView.frame.height * 0.6))
        blockImage.image = UIImage(named: "Block")
        blockView.addSubview(blockImage)
        let blockLabel = UILabel(frame: CGRect(x: blockView.frame.width * 0.05, y: blockView.frame.height * 0.75, width: blockView.frame.width * 0.95, height: blockView.frame.height * 0.2))
        blockLabel.text = "Block Chance"
        blockLabel.textAlignment = .center
        blockView.addSubview(blockLabel)
        let blockAmount = UILabel(frame: CGRect(x: blockView.frame.width * 0.7, y: blockView.frame.height * 0.6, width: blockView.frame.width * 0.25, height: blockView.frame.height * 0.15))
        blockAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Block Chance")!.getAmount()/5)"
        let bloAmount = (settings.characters[settings.selectedPlayer].inventory.get("Block Chance")!.getAmount() % 5)
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: blockView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: blockView.frame.height * 0.2, width: sectionWidth, height: blockView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < bloAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            blockView.addSubview(progressBar)
        }
        blockView.addSubview(blockAmount)
        skillsView.addSubview(blockView)
        
        menu.addSubview(skillsView)
    }
    
    @objc func closeSkills()
    {
        skillsView.removeFromSuperview()
    }
    
    @objc func openChooseAttack()
    {
        chooseAttackView = UIView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
        chooseAttackView.backgroundColor = UIColor.brown
        let closeAttackButton = UIButton(frame: CGRect(x: chooseAttackView.frame.width - chooseAttackView.frame.height * 0.2, y: chooseAttackView.frame.height * 0.05, width: chooseAttackView.frame.height * 0.15, height: chooseAttackView.frame.height * 0.15))
        closeAttackButton.addTarget(self, action: #selector(GameScene.closeChooseAttack), for: .touchUpInside)
        closeAttackButton.backgroundColor = UIColor.red
        closeAttackButton.setTitle("X", for: UIControl.State())
        closeAttackButton.layer.borderColor = UIColor.darkGray.cgColor
        closeAttackButton.layer.borderWidth = closeAttackButton.frame.width * 0.1
        chooseAttackView.addSubview(closeAttackButton)
        
        //SWORD INFO
        let swordView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.125, y: chooseAttackView.frame.height * 0.075, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        swordView.layer.backgroundColor = UIColor.lightGray.cgColor
        swordView.layer.borderColor = UIColor.darkGray.cgColor
        swordView.layer.borderWidth = swordView.frame.height * 0.05
        let swordImage = UIImageView(frame: CGRect(x: swordView.frame.height * 0.1, y: swordView.frame.height * 0.1, width: swordView.frame.height * 0.6, height: swordView.frame.height * 0.6))
        swordImage.image = UIImage(named: "Sword")
        swordView.addSubview(swordImage)
        let swordLabel = UILabel(frame: CGRect(x: swordView.frame.width * 0.05, y: swordView.frame.height * 0.75, width: swordView.frame.width * 0.95, height: swordView.frame.height * 0.2))
        swordLabel.text = "Melee"
        swordLabel.textAlignment = .center
        swordView.addSubview(swordLabel)
        let swordAmount = UILabel(frame: CGRect(x: swordView.frame.width * 0.7, y: swordView.frame.height * 0.4, width: swordView.frame.width * 0.25, height: swordView.frame.height * 0.3))
        swordAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount()/5)"
        swordView.addSubview(swordAmount)
        let swoAmount = (settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount() % 5)
        let sectionWidth = (swordView.frame.width - swordView.frame.height * 0.75)/7
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: swordView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: swordView.frame.height * 0.2, width: sectionWidth, height: swordView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < swoAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            swordView.addSubview(progressBar)
        }
        let healthTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goMelee))
        swordView.addGestureRecognizer(healthTapped)
        chooseAttackView.addSubview(swordView)
        
        //SHORT RANGE INFO
        let shortRangeView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.55, y: chooseAttackView.frame.height * 0.075, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        shortRangeView.layer.backgroundColor = UIColor.lightGray.cgColor
        shortRangeView.layer.borderColor = UIColor.darkGray.cgColor
        shortRangeView.layer.borderWidth = shortRangeView.frame.height * 0.05
        let shortRangeImage = UIImageView(frame: CGRect(x: shortRangeView.frame.height * 0.1, y: shortRangeView.frame.height * 0.1, width: shortRangeView.frame.height * 0.6, height: shortRangeView.frame.height * 0.6))
        shortRangeImage.image = UIImage(named: "Shuriken")
        shortRangeView.addSubview(shortRangeImage)
        let shortRangeLabel = UILabel(frame: CGRect(x: shortRangeView.frame.width * 0.05, y: shortRangeView.frame.height * 0.75, width: shortRangeView.frame.width * 0.95, height: shortRangeView.frame.height * 0.2))
        shortRangeLabel.text = "Short Range"
        shortRangeLabel.textAlignment = .center
        shortRangeView.addSubview(shortRangeLabel)
        let shortRangeAmount = UILabel(frame: CGRect(x: shortRangeView.frame.width * 0.7, y: shortRangeView.frame.height * 0.4, width: shortRangeView.frame.width * 0.25, height: shortRangeView.frame.height * 0.3))
        shortRangeAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount()/5)"
        shortRangeView.addSubview(shortRangeAmount)
        let sRAmount = (settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount() % 5)
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: shortRangeView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: shortRangeView.frame.height * 0.2, width: sectionWidth, height: shortRangeView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < sRAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            shortRangeView.addSubview(progressBar)
        }
        let speedTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goShortRange))
        shortRangeView.addGestureRecognizer(speedTapped)
        chooseAttackView.addSubview(shortRangeView)
        
        //MAGIC INFO
        let magicView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.125, y: chooseAttackView.frame.height * 0.525, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        magicView.layer.backgroundColor = UIColor.lightGray.cgColor
        magicView.layer.borderColor = UIColor.darkGray.cgColor
        magicView.layer.borderWidth = magicView.frame.height * 0.05
        let magicImage = UIImageView(frame: CGRect(x: magicView.frame.height * 0.1, y: magicView.frame.height * 0.1, width: magicView.frame.height * 0.6, height: magicView.frame.height * 0.6))
        magicImage.image = UIImage(named: "Fireball")
        magicView.addSubview(magicImage)
        let magicLabel = UILabel(frame: CGRect(x: magicView.frame.width * 0.05, y: magicView.frame.height * 0.75, width: magicView.frame.width * 0.95, height: magicView.frame.height * 0.2))
        magicLabel.text = "Magic"
        magicLabel.textAlignment = .center
        magicView.addSubview(magicLabel)
        let magicAmount = UILabel(frame: CGRect(x: magicView.frame.width * 0.7, y: magicView.frame.height * 0.4, width: magicView.frame.width * 0.25, height: magicView.frame.height * 0.3))
        magicAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount()/5)"
        magicView.addSubview(magicAmount)
        let magAmount = (settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount() % 5)
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: magicView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: magicView.frame.height * 0.2, width: sectionWidth, height: magicView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < magAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            magicView.addSubview(progressBar)
        }
        let damageTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goMagic))
        magicView.addGestureRecognizer(damageTapped)
        chooseAttackView.addSubview(magicView)
        
        //LONG RANGE INFO
        let longRangeView = UIView(frame: CGRect(x: chooseAttackView.frame.width * 0.55, y: chooseAttackView.frame.height * 0.525, width: chooseAttackView.frame.width * 0.3, height: chooseAttackView.frame.height * 0.4))
        longRangeView.layer.backgroundColor = UIColor.lightGray.cgColor
        longRangeView.layer.borderColor = UIColor.darkGray.cgColor
        longRangeView.layer.borderWidth = longRangeView.frame.height * 0.05
        let longRangeImage = UIImageView(frame: CGRect(x: longRangeView.frame.height * 0.1, y: longRangeView.frame.height * 0.1, width: longRangeView.frame.height * 0.6, height: longRangeView.frame.height * 0.6))
        longRangeImage.image = UIImage(named: "Bow and Arrow")
        longRangeView.addSubview(longRangeImage)
        let longRangeLabel = UILabel(frame: CGRect(x: longRangeView.frame.width * 0.05, y: longRangeView.frame.height * 0.75, width: longRangeView.frame.width * 0.95, height: longRangeView.frame.height * 0.2))
        longRangeLabel.text = "Long Range"
        longRangeLabel.textAlignment = .center
        longRangeView.addSubview(longRangeLabel)
        let longRangeAmount = UILabel(frame: CGRect(x: longRangeView.frame.width * 0.7, y: longRangeView.frame.height * 0.4, width: longRangeView.frame.width * 0.25, height: longRangeView.frame.height * 0.3))
        longRangeAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount()/5)"
        longRangeView.addSubview(longRangeAmount)
        let lRAmount = (settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount() % 5)
        for num in 0...4
        {
            let progressBar = UIView(frame: CGRect(x: longRangeView.frame.height * 0.725 + sectionWidth * (CGFloat(num) + 1), y: longRangeView.frame.height * 0.2, width: sectionWidth, height: longRangeView.frame.height * 0.15))
            progressBar.layer.borderColor = UIColor.gray.cgColor
            progressBar.layer.cornerRadius = progressBar.frame.width * 0.2
            progressBar.layer.borderWidth = progressBar.frame.width * 0.2
            if num < lRAmount
            {
                progressBar.layer.backgroundColor = UIColor.green.cgColor
            }
            longRangeView.addSubview(progressBar)
        }
        let blockTapped = UITapGestureRecognizer(target: self, action: #selector(GameScene.goLongRange))
        longRangeView.addGestureRecognizer(blockTapped)
        chooseAttackView.addSubview(longRangeView)
        
        if(character.equippedWeapon == "Melee")
        {
            swordView.layer.backgroundColor = UIColor.blue.cgColor
        }
        if(character.equippedWeapon == "Short Range")
        {
            shortRangeView.layer.backgroundColor = UIColor.blue.cgColor
        }
        if(character.equippedWeapon == "Magic")
        {
            magicView.layer.backgroundColor = UIColor.blue.cgColor
        }
        if(character.equippedWeapon == "Long Range")
        {
            longRangeView.layer.backgroundColor = UIColor.blue.cgColor
        }
        
        switch character.fighterType {
        case 1:
            swordAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount()/5 + 1)"
        case 4:
            shortRangeAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount()/5 + 1)"
        case 3:
            magicAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount()/5 + 1)"
        case 2:
            longRangeAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount()/5 + 1)"
        default:
            swordAmount.text = "\(settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount()/5 + 1)"
        }
        
        menu.addSubview(chooseAttackView)
    }
    
    @objc func closeChooseAttack()
    {
        chooseAttackView.removeFromSuperview()
    }
    
    @objc func exitGame()
    {
        if !roomCleared
        {
            map.currLoc = map.respawnPoint
        }
        for viewThing in view!.subviews
        {
            viewThing.removeFromSuperview()
        }
        save()
        let scene = CharacterScene(size: view!.bounds.size)
        scene.scaleMode = .resizeFill
        view!.presentScene(scene)
    }
    
    /////////////////////////////////       POTIONS         /////////////////////////////////
    
    @objc func useHealth()
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
    
    @objc func useSpeed()
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
            } else {
                character.inventory.add("Speed Potions")
            }
        }
    }
    
    @objc func reduceSpeed()      //Call image that oscillates alphas from .2 to .9
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
    
    @objc func useBlock()
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
    
    @objc func reduceBlock()
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
    
    @objc func useDamage()
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
    
    @objc func reduceDamage()
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
    
    func findPotAlpha(_ count: Int) -> CGFloat
    {
        let alpha: CGFloat = (CGFloat(count)/10).truncatingRemainder(dividingBy: 2)
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
    
    @objc func goMelee()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Melee")!.getAmount() / 5 > 0 || settings.characters[settings.selectedPlayer].fighterType == 1
        {
            character.equippedWeapon = "Melee"
            chooseAttackView.removeFromSuperview()
            openChooseAttack()
        }
    }
    
    @objc func goShortRange()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Short Range")!.getAmount() / 5 > 0 || settings.characters[settings.selectedPlayer].fighterType == 4
        {
            character.equippedWeapon = "Short Range"
            chooseAttackView.removeFromSuperview()
            openChooseAttack()
        }
    }
    
    @objc func goMagic()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Magic")!.getAmount() / 5 > 0 || settings.characters[settings.selectedPlayer].fighterType == 3
        {
            character.equippedWeapon = "Magic"
            chooseAttackView.removeFromSuperview()
            openChooseAttack()
        }
    }
    
    @objc func goLongRange()
    {
        if settings.characters[settings.selectedPlayer].inventory.get("Long Range")!.getAmount() / 5 > 0 || settings.characters[settings.selectedPlayer].fighterType == 2
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
    
    func openChest(_ name: String)
    {
        canDoStuff = false
        for child in (self.scene?.children)!
        {
            if child.name != "backgroundMusic"
            {
                child.isPaused = true
            }
        }
        
        for timer in buffTimers
        {
            timer.invalidate()
        }
        openNotify(name)
    }
    
    func openNotify(_ chestRarity: String)    //Array of bonuses
    {
        var times = 0
        var itemNum: [Int] = []
        var pictures: [UIImage] = []
        
        //Set up UIView - Image, congrats, close
        if chestRarity == "common" {
            times = 1
        } else if chestRarity == "uncommon" {
            times = 4
        } else if chestRarity == "rare" {
            times = 10
        } else if chestRarity == "legendary" {
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
                    itemNum.remove(at: j)
                    pictures.remove(at: j)
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
            upgrade.contentMode = .scaleAspectFit
            upgrade.image = pictures[things]
            upgrade.backgroundColor = UIColor.brown
            let arrow = UIImageView(frame: CGRect(x: chestNotification.frame.width * 0.65, y: chestNotification.frame.height * 0.6, width: chestNotification.frame.width * 0.1, height: chestNotification.frame.height * 0.2))
            arrow.image = UIImage(named: "Arrow")
            let amount = UILabel(frame: CGRect(x: chestNotification.frame.width * 0.8, y: chestNotification.frame.height * 0.69, width: chestNotification.frame.width * 0.1, height: chestNotification.frame.height * 0.1))
            amount.text = "\(timesAppear[things])"
            amount.adjustsFontSizeToFitWidth = true
            amount.backgroundColor = UIColor.brown
            reward.addSubview(upgrade)
            reward.addSubview(arrow)
            reward.addSubview(amount)
            chestNotification.addSubview(reward)
            rewardNotifications.append(reward)
        }
        view?.addSubview(chestNotification)
    }
    
    @objc func continueRewards()
    {
        if rewardNotifications.count > 0
        {
            rewardNotifications.last?.removeFromSuperview()
            rewardNotifications.removeLast()
            if rewardNotifications.count < 1
            {
                let closeChestButton = UIButton(frame: CGRect(x: chestNotification.frame.width - chestNotification.frame.height * 0.2, y: chestNotification.frame.height * 0.05, width: chestNotification.frame.height * 0.15, height: chestNotification.frame.height * 0.15))
                closeChestButton.setTitle("X", for: UIControl.State())
                closeChestButton.titleLabel?.textColor = UIColor.black
                closeChestButton.layer.backgroundColor = UIColor.red.cgColor
                closeChestButton.layer.borderWidth = closeChestButton.frame.height * 0.05
                closeChestButton.layer.borderColor = UIColor.darkGray.cgColor
                closeChestButton.addTarget(self, action: #selector(GameScene.closeChest), for: .touchUpInside)
                chestNotification.addSubview(closeChestButton)
            }
        }
    }
    
    func findName(_ type: Int) -> String  //Helper method for inventory
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
    
    func findPhoto(_ type: Int) -> UIImage {
        switch type {
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
        let chestType = Int.random(in: 0..<100)
        if(chestType < 0) {        //25% chance
            return 3    //Defense
        } else if(chestType < 100) { //25% chance
            return 2    //Attack
        } else {                    //50% chance
            return 1    //Potions
        }
    }
    
    func randomPotion() -> Int
    {
        let chestType = Int.random(in: 0..<100)
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
        let chestType = Int.random(in: 0..<100)
        if(chestType < 0)  //23% chance
        {
            return 5    //Sword Upgrade
        }
        else if(chestType < 100) //23% chance
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
        let chestType = Int.random(in: 0..<100)
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
    
    @objc func closeChest() {
        chestNotification.removeFromSuperview()
        canDoStuff = true
        if tempSpeed > 0 {
            buffTimers.append(Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.reduceSpeed), userInfo: nil, repeats: true))
            view?.addSubview(speedPotBG)
            view?.addSubview(speedPot)
        }
        if tempBlock > 0 {
            buffTimers.append(Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.reduceBlock), userInfo: nil, repeats: true))
            view?.addSubview(blockPotBG)
            view?.addSubview(blockPot)
        }
        if tempDamage > 0 {
            buffTimers.append(Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(GameScene.reduceDamage), userInfo: nil, repeats: true))
            view?.addSubview(damagePotBG)
            view?.addSubview(damagePot)
        }
        for child in (self.scene?.children)! {
            child.isPaused = false
        }
    }
    
    /////////////////////////////////       HELPER FUNCTIONS       ///////////////////////////
    
    func setHearts() {
        for heart in heartBar.subviews {
            heart.removeFromSuperview()
        }
        
        var health = character.currentHealth
        var missingHealth = character.maxHealth + character.inventory.get("Health")!.getAmount()/5 - character.currentHealth
        var xMulti: CGFloat = 0
        var yMulti: CGFloat = 0
        
        while(health! - 2 >= 0) {
            var heartPicture: UIImageView
            heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*xMulti, y: heartBar.frame.height * (1/3) * yMulti, width: heartBar.frame.width * 0.2, height: heartBar.frame.height * (1/3)))
            heartPicture.image = UIImage(named: "8BitHeart")
            heartBar.addSubview(heartPicture)
            health = health! - 2
            xMulti += 1
            if(xMulti.truncatingRemainder(dividingBy: 5) == 0) {
                xMulti = 0
                yMulti += 1
            }
        }
        
        if health == 1 {
            if missingHealth != 0 {
                var heartPicture: UIImageView
                heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*xMulti, y: heartBar.frame.height * (1/3) * yMulti, width: heartBar.frame.width * 0.2, height: heartBar.frame.height * (1/3)))
                heartPicture.image = UIImage(named: "8BitHeartHalf")
                heartBar.addSubview(heartPicture)
                missingHealth -= 1
                xMulti += 1
                if(xMulti.truncatingRemainder(dividingBy: 5) == 0) {
                    xMulti = 0
                    yMulti += 1
                }
            } else {
                var heartPicture: UIImageView
                heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*xMulti, y: heartBar.frame.height * (1/3) * yMulti, width: heartBar.frame.width * 0.1, height: heartBar.frame.height * (1/3)))
                heartPicture.image = UIImage(named: "8BitHeartHalfFull")
                heartBar.addSubview(heartPicture)
            }
        }
        
        while(missingHealth - 2 >= 0) {
            var heartPicture: UIImageView
            heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*xMulti, y: heartBar.frame.height * (1/3) * yMulti, width: heartBar.frame.width * 0.2, height: heartBar.frame.height * (1/3)))
            heartPicture.image = UIImage(named: "8BitHeartEmpty")
            heartBar.addSubview(heartPicture)
            missingHealth -= 2
            xMulti += 1
            if(xMulti.truncatingRemainder(dividingBy: 5) == 0) {
                xMulti = 0
                yMulti += 1
            }
        }
        
        if missingHealth == 1 {
            var heartPicture: UIImageView
            heartPicture = UIImageView(frame: CGRect(x: heartBar.frame.width*0.2*xMulti, y: heartBar.frame.height * (1/3) * yMulti, width: heartBar.frame.width * 0.1, height: heartBar.frame.height * (1/3)))
            heartPicture.image = UIImage(named: "8BitHeartEmptyHalf")
            heartBar.addSubview(heartPicture)
        }
    }
    
    func setDoor(_ place: String)
    {
        let door = SKSpriteNode(texture: doorLocked)
        door.zPosition = -1
        doors.append(door)
        switch place {
        case "up":
            if map.getUp()!.equals(map.bossPoint) {
                door.texture = doorBoss
            }
            door.size = CGSize(width: size.width * 0.1, height: size.height * 0.1)
            door.position = CGPoint(x: size.width * 0.5, y: size.height * 0.95)
        case "right":
            if map.getRight()!.equals(map.bossPoint) {
                door.texture = doorBoss
            }
            door.size = CGSize(width: size.width * 0.1, height: size.height * 0.1)
            door.position = CGPoint(x: size.width - size.height * 0.05, y: size.height * 0.5)
            door.zRotation = CGFloat(Double.pi/2) * 3
        case "down":
            if map.getDown()!.equals(map.bossPoint) {
                door.texture = doorBoss
            }
            door.size = CGSize(width: size.width * 0.1, height: size.height * 0.1)
            door.position = CGPoint(x: size.width * 0.5, y: size.height * 0.05)
            door.zRotation = CGFloat(Double.pi)
        case "left":
            if map.getLeft()!.equals(map.bossPoint) {
                door.texture = doorBoss
            }
            door.size = CGSize(width: size.width * 0.1, height: size.height * 0.1)
            door.position = CGPoint(x: size.height * 0.05, y: size.height * 0.5)
            door.zRotation = CGFloat(Double.pi/2)
        default:
            door.size = CGSize(width: size.width * 0.1, height: size.height * 0.1)
            door.position = CGPoint(x: size.width * 0.5, y: size.height * 0.95)
        }
        addChild(door)
    }
    
    @objc func fastTravel(_ sender: UITapGestureRecognizer) {    //Working
        if roomCleared {
            fastTravelRoom = sender.view!
            let checkTravelBG = UIView(frame: CGRect(x: mapView.frame.width * 0.15, y: mapView.frame.height * 0.15, width: mapView.frame.width * 0.7, height: mapView.frame.height * 0.7))
            checkTravelBG.backgroundColor = UIColor.brown
            checkTravelBG.layer.borderColor = UIColor.lightGray.cgColor
            checkTravelBG.layer.borderWidth = checkTravelBG.frame.height * 0.05
            mapView.addSubview(checkTravelBG)
            let checkTravelMessage = UILabel(frame: CGRect(x: checkTravelBG.frame.width * 0.1, y: checkTravelBG.frame.height * 0.1, width: checkTravelBG.frame.width * 0.8, height: checkTravelBG.frame.height * 0.3))
            checkTravelMessage.textAlignment = .center
            checkTravelMessage.numberOfLines = 0
            checkTravelMessage.text = "ARE YOU SURE YOU WISH TO FAST TRAVEL?"
            checkTravelBG.addSubview(checkTravelMessage)
            let checkTravelButton = UIButton(frame: CGRect(x: checkTravelBG.frame.width * 0.5, y: checkTravelBG.frame.height * 0.6, width: checkTravelBG.frame.width * 0.4, height: checkTravelBG.frame.height * 0.3))
            checkTravelButton.setTitle("CANCEL", for: UIControl.State())
            checkTravelButton.addTarget(self, action: #selector(GameScene.removeView(_:)), for: .touchUpInside)
            checkTravelButton.backgroundColor = UIColor.brown
            checkTravelButton.layer.borderColor = UIColor.lightGray.cgColor
            checkTravelButton.layer.borderWidth = checkTravelButton.frame.height * 0.1
            checkTravelBG.addSubview(checkTravelButton)
            let fastTravelButton = UIButton(frame: CGRect(x: checkTravelBG.frame.width * 0.1, y: checkTravelBG.frame.height * 0.6, width: checkTravelBG.frame.width * 0.3, height: checkTravelBG.frame.height * 0.3))
            fastTravelButton.setTitle("YES", for: UIControl.State())
            fastTravelButton.addTarget(self, action: #selector(GameScene.reaffirmTravel), for: .touchUpInside)
            fastTravelButton.backgroundColor = UIColor.brown
            fastTravelButton.layer.borderColor = UIColor.lightGray.cgColor
            fastTravelButton.layer.borderWidth = fastTravelButton.frame.height * 0.1
            checkTravelBG.addSubview(fastTravelButton)
        } else {
            let cantTravelBG = UIView(frame: CGRect(x: mapView.frame.width * 0.15, y: mapView.frame.height * 0.15, width: mapView.frame.width * 0.7, height: mapView.frame.height * 0.7))
            cantTravelBG.backgroundColor = UIColor.brown
            cantTravelBG.layer.borderColor = UIColor.lightGray.cgColor
            cantTravelBG.layer.borderWidth = cantTravelBG.frame.height * 0.05
            mapView.addSubview(cantTravelBG)
            let cantTravelMessage = UILabel(frame: CGRect(x: cantTravelBG.frame.width * 0.1, y: cantTravelBG.frame.height * 0.1, width: cantTravelBG.frame.width * 0.8, height: cantTravelBG.frame.height * 0.3))
            cantTravelMessage.textAlignment = .center
            cantTravelMessage.numberOfLines = 0
            cantTravelMessage.text = "I'M SORRY, BUT YOU HAVE TO CLEAR THE ROOM FIRST."
            cantTravelBG.addSubview(cantTravelMessage)
            let cantTravelButton = UIButton(frame: CGRect(x: cantTravelBG.frame.width * 0.3, y: cantTravelBG.frame.height * 0.6, width: cantTravelBG.frame.width * 0.4, height: cantTravelBG.frame.height * 0.3))
            cantTravelButton.setTitle("OKAY", for: UIControl.State())
            cantTravelButton.addTarget(self, action: #selector(GameScene.removeView(_:)), for: .touchUpInside)
            cantTravelButton.backgroundColor = UIColor.brown
            cantTravelButton.layer.borderColor = UIColor.lightGray.cgColor
            cantTravelButton.layer.borderWidth = cantTravelButton.frame.height * 0.1
            cantTravelBG.addSubview(cantTravelButton)
        }
    }
    
    @objc func removeView(_ sender: UIButton) {
        sender.superview!.removeFromSuperview()
    }
    
    @objc func reaffirmTravel() {
        let x = fastTravelRoom.tag / 10
        let y = fastTravelRoom.tag % 10
        moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        map.update(Coordinate(xCoor: x, yCoor: y))
        map.cleared(map.getCurr())
        transitionClose()
        mapView.removeFromSuperview()
        menu.removeFromSuperview()
    }
    
    func checkWin() {
        if map.cleared.contains(map.getBoss()) {
            canDoStuff = false
            for child in (self.scene?.children)! {
                if child.name != "backgroundMusic" {
                    child.isPaused = true
                }
            }
            
            for timer in buffTimers {
                timer.invalidate()
            }
            
            congrats = UIView(frame: CGRect(x: size.width * 0.05, y: size.height * 0.05, width: size.width * 0.9, height: size.height * 0.9))
            congrats.layer.borderColor = UIColor.gray.cgColor
            congrats.layer.borderWidth = congrats.frame.width * 0.01
            congrats.layer.backgroundColor = UIColor.brown.cgColor
            view?.addSubview(congrats)
            character.level = character.level + 1
            let quitButton = UIButton(frame: CGRect(x: congrats.frame.width * 0.3, y: congrats.frame.height * 0.7, width: congrats.frame.width * 0.4, height: congrats.frame.height * 0.15))
            quitButton.addTarget(self, action: #selector(GameScene.nextLevel), for: .touchUpInside)
            quitButton.setTitle("NEXT LEVEL", for: UIControl.State())
            quitButton.layer.borderColor = UIColor.gray.cgColor
            quitButton.layer.borderWidth = quitButton.frame.height * 0.05
            quitButton.layer.backgroundColor = UIColor.blue.cgColor
            congrats.addSubview(quitButton)
            let congratsLabel = UILabel(frame: CGRect(x: congrats.frame.width * 0.3, y: congrats.frame.height * 0.3, width: congrats.frame.width * 0.4, height: congrats.frame.height * 0.15))
            congratsLabel.textAlignment = .center
            congratsLabel.text = "CONGRATULATIONS"
            congrats.addSubview(congratsLabel)
        }
    }
    
    @objc func nextLevel() {
        character.map = Map(version: character.level)
        map.update(map.spawnPoint)
        congrats.removeFromSuperview()
        transitionClose()
        moveTo = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    }
    
    func endGame() {
        for viewThing in view!.subviews {
            viewThing.removeFromSuperview()
        }
        save()
        settings.characters[settings.selectedPlayer] = Character(fightType: character.fighterType)
        let scene = CharacterScene(size: view!.bounds.size)
        scene.scaleMode = .resizeFill
        view!.presentScene(scene)
    }
    
    func save() {
        settings.save()
        scene?.removeFromParent()
    }
}
