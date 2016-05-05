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
    
    var titleLabel = SKSpriteNode()
    var playCharOne = SKSpriteNode()
    var playCharTwo = SKSpriteNode()
    var playCharThree = SKSpriteNode()

    var characterOne = SKSpriteNode()
    var characterTwo = SKSpriteNode()
    var characterThree = SKSpriteNode()
    
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
        
        titleLabel.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.9)
        titleLabel.size = CGSize(width: view.frame.width * 0.8, height: view.frame.height * 0.075)
        titleLabel.color = SKColor.cyanColor()
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
            characterOne.size = CGSize(width: view!.frame.width * 0.3, height: view!.frame.height * 0.8)
            characterOne.color = SKColor.blackColor()
            if(charPresent)     //Yes character
            {
                playCharOne.name = "playCharOne"
                playCharOne.position = CGPoint(x: characterOne.frame.width * 0.5 + characterOne.frame.minX, y: characterOne.frame.height * 0.15)
                playCharOne.size = CGSize(width: characterOne.frame.width * 0.6, height: characterOne.frame.height * 0.1)
                playCharOne.color = SKColor.blueColor()
                playCharOne.zPosition = 1
                addChild(playCharOne)
                
                deleteCharOne.name = "deleteOne"
                deleteCharOne.position = CGPoint(x: characterOne.frame.width * 0.5 + characterOne.frame.minX, y: characterOne.frame.height * 0.85)
                deleteCharOne.size = CGSize(width: characterOne.frame.width * 0.6, height: characterOne.frame.height * 0.1)
                deleteCharOne.color = SKColor.redColor()
                deleteCharOne.zPosition = 1
                addChild(deleteCharOne)            }
            else                //No character
            {
                playCharOne.name = "playCharOne"
                playCharOne.position = CGPoint(x: characterOne.frame.width * 0.5 + characterOne.frame.minX, y: characterOne.frame.height * 0.15)
                playCharOne.size = CGSize(width: characterOne.frame.width * 0.6, height: characterOne.frame.height * 0.1)
                playCharOne.color = SKColor.redColor()
                playCharOne.zPosition = 1
                addChild(playCharOne)
            }
            addChild(characterOne)
        }
        if(num == 2)    //Second slot
        {
            characterTwo.name = "characterTwo"
            characterTwo.position = CGPoint(x: view!.frame.width * 0.5, y: view!.frame.height * 0.45)
            characterTwo.size = CGSize(width: view!.frame.width * 0.3, height: view!.frame.height * 0.8)
            characterTwo.color = SKColor.blackColor()
            if(charPresent)     //Yes character
            {
                playCharTwo.name = "playCharTwo"
                playCharTwo.position = CGPoint(x: characterTwo.frame.width * 0.5 + characterTwo.frame.minX, y: characterTwo.frame.height * 0.15)
                playCharTwo.size = CGSize(width: characterTwo.frame.width * 0.6, height: characterTwo.frame.height * 0.1)
                playCharTwo.color = SKColor.blueColor()
                playCharTwo.zPosition = 1
                addChild(playCharTwo)
                
                deleteCharTwo.name = "deleteTwo"
                deleteCharTwo.position = CGPoint(x: characterTwo.frame.width * 0.5 + characterTwo.frame.minX, y: characterTwo.frame.height * 0.85)
                deleteCharTwo.size = CGSize(width: characterTwo.frame.width * 0.6, height: characterTwo.frame.height * 0.1)
                deleteCharTwo.color = SKColor.redColor()
                deleteCharTwo.zPosition = 1
                addChild(deleteCharTwo)
            }
            else                //No character
            {
                playCharTwo.name = "playCharTwo"
                playCharTwo.position = CGPoint(x: characterTwo.frame.width * 0.5 + characterTwo.frame.minX, y: characterTwo.frame.height * 0.15)
                playCharTwo.size = CGSize(width: characterTwo.frame.width * 0.6, height: characterTwo.frame.height * 0.1)
                playCharTwo.color = SKColor.redColor()
                playCharTwo.zPosition = 1
                addChild(playCharTwo)
            }
            addChild(characterTwo)
        }
        if(num == 3)    //Third slot
        {
            characterThree.name = "characterThree"
            characterThree.position = CGPoint(x: view!.frame.width * 0.825, y: view!.frame.height * 0.45)
            characterThree.size = CGSize(width: view!.frame.width * 0.3, height: view!.frame.height * 0.8)
            characterThree.color = SKColor.blackColor()
            if(charPresent)     //Yes character
            {
                playCharThree.name = "playCharThree"
                playCharThree.position = CGPoint(x: characterThree.frame.width * 0.5 + characterThree.frame.minX, y: characterThree.frame.height * 0.15)
                playCharThree.size = CGSize(width: characterThree.frame.width * 0.6, height: characterThree.frame.height * 0.1)
                playCharThree.color = SKColor.blueColor()
                playCharThree.zPosition = 1
                addChild(playCharThree)
                
                deleteCharThree.name = "deleteThree"
                deleteCharThree.position = CGPoint(x: characterThree.frame.width * 0.5 + characterThree.frame.minX, y: characterThree.frame.height * 0.85)
                deleteCharThree.size = CGSize(width: characterThree.frame.width * 0.6, height: characterThree.frame.height * 0.1)
                deleteCharThree.color = SKColor.redColor()
                deleteCharThree.zPosition = 1
                addChild(deleteCharThree)
            }
            else                //No character
            {
                playCharThree.name = "playCharThree"
                playCharThree.position = CGPoint(x: characterThree.frame.width * 0.5 + characterThree.frame.minX, y: characterThree.frame.height * 0.15)
                playCharThree.size = CGSize(width: characterThree.frame.width * 0.6, height: characterThree.frame.height * 0.1)
                playCharThree.color = SKColor.redColor()
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
        openGame()
    }
    
    func goToGameP2()
    {
        settings.selectedPlayer = 1
        openGame()
    }
    
    func goToGameP3()
    {
        settings.selectedPlayer = 2
        openGame()
    }
    
    func deleteP1()
    {
        settings.characters[0] = Character(fightType: 1)
    }
    
    func deleteP2()
    {
        settings.characters[1] = Character(fightType: 2)
    }
    
    func deleteP3()
    {
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
