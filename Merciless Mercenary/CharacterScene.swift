//
//  CharacterVC.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/13/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class CharacterScene: SKScene {

    var settings: Settings!
    
    var createText = SKTexture(imageNamed: "CreateButton")
    var playText = SKTexture(imageNamed: "PlayButton")
    var deleteText = SKTexture(imageNamed: "DeleteButton")
    var slotsText = SKTexture(imageNamed: "SlotsLabel")
    
    var titleLabel = SKSpriteNode()
    var playCharOne = SKSpriteNode()
    var playCharTwo = SKSpriteNode()
    var playCharThree = SKSpriteNode()

    var characterOne = SKSpriteNode(imageNamed: "playerLeft")
    var characterTwo = SKSpriteNode(imageNamed: "playerDown")
    var characterThree = SKSpriteNode(imageNamed: "playerRight")
    
    var deleteCharOne = SKSpriteNode()
    var deleteCharTwo = SKSpriteNode()
    var deleteCharThree = SKSpriteNode()

    let backgroundMusic = SKAudioNode(fileNamed: "adventurous theme.mp3")
    
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
        
        scene!.backgroundColor = UIColor(red: 121/255, green: 60/255, blue: 0/255, alpha: 1.0)
        titleLabel.texture = slotsText
        titleLabel.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.925)
        titleLabel.size = CGSize(width: view.frame.width * 0.8, height: view.frame.height * 0.075)
        addChild(titleLabel)

        let numChar: Int = settings.howManyCharacters()
        if numChar == 0
        {
            settings.addCharacter(1)
            settings.addCharacter(2)
            settings.addCharacter(3)

            prepSlot(1, charPresent: false)
            prepSlot(2, charPresent: false)
            prepSlot(3, charPresent: false)
        }
        else if numChar == 1
        {
            settings.addCharacter(2)
            settings.addCharacter(3)
            
            prepSlot(1, charPresent: true)
            prepSlot(2, charPresent: false)
            prepSlot(3, charPresent: false)
        }
        else if numChar == 2
        {
            settings.addCharacter(3)
            
            prepSlot(1, charPresent: true)
            prepSlot(2, charPresent: true)
            prepSlot(3, charPresent: false)
        }
        else
        {
            prepSlot(1, charPresent: true)
            prepSlot(2, charPresent: true)
            prepSlot(3, charPresent: true)
        }
    }
    
    func prepSlot(num: Int, charPresent: Bool)
    {
        if(num == 1)    //First slot
        {
            characterOne.name = "characterOne"
            characterOne.position = CGPoint(x: view!.frame.width * 0.175, y: view!.frame.height * 0.45)
            characterOne.size = CGSize(width: view!.frame.width * 0.1, height: view!.frame.height * 0.3)
            if(charPresent)     //Yes character
            {
                playCharOne.name = "playCharOne"
                playCharOne.texture = playText
                playCharOne.position = CGPoint(x: characterOne.position.x, y: characterOne.position.y - size.height * 0.275)
                playCharOne.size = CGSize(width: view!.frame.width * 0.15, height: view!.frame.height * 0.075)
                playCharOne.zPosition = 1
                addChild(playCharOne)
                
                deleteCharOne.name = "deleteOne"
                deleteCharOne.texture = deleteText
                deleteCharOne.position = CGPoint(x: characterOne.position.x, y: characterOne.position.y + size.height * 0.275)
                deleteCharOne.size = CGSize(width: view!.frame.width * 0.18, height: view!.frame.height * 0.075)
                deleteCharOne.zPosition = 1
                addChild(deleteCharOne)            }
            else                //No character
            {
                playCharOne.name = "playCharOne"
                playCharOne.texture = createText
                playCharOne.position = CGPoint(x: characterOne.position.x, y: characterOne.position.y - size.height * 0.275)
                playCharOne.size = CGSize(width: view!.frame.width * 0.18, height: view!.frame.height * 0.075)
                playCharOne.zPosition = 1
                addChild(playCharOne)
            }
            addChild(characterOne)
        }
        if(num == 2)    //Second slot
        {
            characterTwo.name = "characterTwo"
            characterTwo.position = CGPoint(x: view!.frame.width * 0.5, y: view!.frame.height * 0.45)
            characterTwo.size = CGSize(width: view!.frame.width * 0.1, height: view!.frame.height * 0.3)
            if(charPresent)     //Yes character
            {
                playCharTwo.name = "playCharTwo"
                playCharTwo.texture = playText
                playCharTwo.position = CGPoint(x: characterTwo.position.x, y: characterTwo.position.y - size.height * 0.275)
                playCharTwo.size = CGSize(width: view!.frame.width * 0.15, height: view!.frame.height * 0.075)
                playCharTwo.zPosition = 1
                addChild(playCharTwo)
                
                deleteCharTwo.name = "deleteTwo"
                deleteCharTwo.position = CGPoint(x: characterTwo.position.x, y: characterTwo.position.y + size.height * 0.275)
                deleteCharTwo.size = CGSize(width: view!.frame.width * 0.18, height: view!.frame.height * 0.075)
                deleteCharTwo.texture = deleteText
                deleteCharTwo.zPosition = 1
                addChild(deleteCharTwo)
            }
            else                //No character
            {
                playCharTwo.name = "playCharTwo"
                playCharTwo.texture = createText
                playCharTwo.position = CGPoint(x: characterTwo.position.x, y: characterTwo.position.y - size.height * 0.275)
                playCharTwo.size = CGSize(width: view!.frame.width * 0.18, height: view!.frame.height * 0.075)
                playCharTwo.zPosition = 1
                addChild(playCharTwo)
            }
            addChild(characterTwo)
        }
        if(num == 3)    //Third slot
        {
            characterThree.name = "characterThree"
            characterThree.position = CGPoint(x: view!.frame.width * 0.825, y: view!.frame.height * 0.45)
            characterThree.size = CGSize(width: view!.frame.width * 0.1, height: view!.frame.height * 0.3)
            if(charPresent)     //Yes character
            {
                playCharThree.name = "playCharThree"
                playCharThree.position = CGPoint(x: characterThree.position.x, y: characterThree.position.y - size.height * 0.275)
                playCharThree.size = CGSize(width: view!.frame.width * 0.15, height: view!.frame.height * 0.075)
                playCharThree.texture = playText
                playCharThree.zPosition = 1
                addChild(playCharThree)
                
                deleteCharThree.name = "deleteThree"
                deleteCharThree.position = CGPoint(x: characterThree.position.x, y: characterThree.position.y + size.height * 0.275)
                deleteCharThree.size = CGSize(width: view!.frame.width * 0.18, height: view!.frame.height * 0.075)
                deleteCharThree.texture = deleteText
                deleteCharThree.zPosition = 1
                addChild(deleteCharThree)
            }
            else                //No character
            {
                playCharThree.name = "playCharThree"
                playCharThree.position = CGPoint(x: characterThree.position.x, y: characterThree.position.y - size.height * 0.275)
                playCharThree.size = CGSize(width: view!.frame.width * 0.18, height: view!.frame.height * 0.075)
                playCharThree.texture = createText
                playCharThree.zPosition = 1
                addChild(playCharThree)
            }
            addChild(characterThree)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let positionInScene = touches.first?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene!)
        
        if(touchedNode.name == "playCharOne")
        {
            goToGameP1()
        }
        if(touchedNode.name == "playCharTwo")
        {
            goToGameP2()
        }
        if(touchedNode.name == "playCharThree")
        {
            goToGameP3()
        }
        if(touchedNode.name == "deleteOne")
        {
            deleteP1()
        }
        if(touchedNode.name == "deleteTwo")
        {
            deleteP2()
        }
        if(touchedNode.name == "deleteThree")
        {
            deleteP3()
        }
        
    }
    
    func save()
    {
        settings.save()
        scene?.removeFromParent()
    }
    
    func goToGameP1()
    {
        settings.selectedPlayer = 0
        if settings.characters.count < 0
        {
            settings.addCharacter(0)
        }
        openGame()
    }
    
    func goToGameP2()
    {
        settings.selectedPlayer = 1
        if settings.characters.count < 1
        {
            settings.addCharacter(1)
            settings.selectedPlayer = settings.characters.count - 1
        }
        openGame()
    }
    
    func goToGameP3()
    {
        settings.selectedPlayer = 2
        if settings.characters.count < 2
        {
            settings.addCharacter(2)
            settings.selectedPlayer = settings.characters.count - 1
        }
        openGame()
    }
    
    func deleteP1()
    {
        playCharOne.removeFromParent()
        deleteCharOne.removeFromParent()
        characterOne.removeFromParent()
        prepSlot(1, charPresent: false)
        settings.characters[0] = Character(fightType: 1)
    }
    
    func deleteP2()
    {
        playCharTwo.removeFromParent()
        deleteCharTwo.removeFromParent()
        characterTwo.removeFromParent()
        prepSlot(2, charPresent: false)
        settings.characters[1] = Character(fightType: 2)
    }
    
    func deleteP3()
    {
        playCharThree.removeFromParent()
        deleteCharThree.removeFromParent()
        characterThree.removeFromParent()
        prepSlot(3, charPresent: false)
        settings.characters[2] = Character(fightType: 3)
    }
    
    func openGame()
    {
        save()
        let scene = GameScene(size: view!.bounds.size)
        scene.scaleMode = .ResizeFill
        view!.presentScene(scene)
    }
}
