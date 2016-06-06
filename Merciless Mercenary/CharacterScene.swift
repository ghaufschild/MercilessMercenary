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
    var bGText = SKTexture(imageNamed: "SkillBG")
    var slotsText = SKTexture(imageNamed: "SlotsLabel")
    var meleeText = SKTexture(imageNamed: "Sword")
    var longRangedText = SKTexture(imageNamed: "Bow and Arrow")
    var magicText = SKTexture(imageNamed: "Fireball")
    var shortRangedText = SKTexture(imageNamed: "Shuriken")
    var titleText = SKTexture(imageNamed: "SkillTitleText")
    
    var titleLabel = SKSpriteNode()
    var playCharOne = SKSpriteNode()
    var playCharTwo = SKSpriteNode()
    var playCharThree = SKSpriteNode()
    var charOneSkill = SKSpriteNode()
    var charTwoSkill = SKSpriteNode()
    var charThreeSkill = SKSpriteNode()

    var characterOne = SKSpriteNode(imageNamed: "playerLeft")
    var characterTwo = SKSpriteNode(imageNamed: "playerDown")
    var characterThree = SKSpriteNode(imageNamed: "playerRight")
    
    var deleteCharOne = SKSpriteNode()
    var deleteCharTwo = SKSpriteNode()
    var deleteCharThree = SKSpriteNode()
    
    var pickMelee = SKSpriteNode()
    var pickShortRanged = SKSpriteNode()
    var pickMagic = SKSpriteNode()
    var pickLongRanged = SKSpriteNode()
    var skillBG = SKSpriteNode()
    var skillTitle = SKSpriteNode()

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

        resetScreen()
    }
    
    func prepSlot(num: Int, charPresent: Bool)
    {
        if(num == 1)    //First slot
        {
            characterOne.name = "characterOne"
            characterOne.position = CGPoint(x: size.width * 0.175, y: size.height * 0.55)
            characterOne.size = CGSize(width: size.width * 0.1, height: size.height * 0.3)
            if(charPresent)     //Yes character
            {
                playCharOne.name = "playCharOne"
                playCharOne.texture = playText
                playCharOne.position = CGPoint(x: characterOne.position.x, y: characterOne.position.y - size.height * 0.425)
                playCharOne.size = CGSize(width: size.width * 0.15, height: size.height * 0.075)
                playCharOne.zPosition = 1
                addChild(playCharOne)
                
                charOneSkill.texture = findTexture(settings.characters[0].equippedWeapon)
                charOneSkill.position = CGPoint(x: characterOne.position.x, y: characterOne.position.y - size.height * 0.275)
                charOneSkill.size = CGSize(width: size.width * 0.1, height: size.height * 0.15)
                addChild(charOneSkill)
                
                deleteCharOne.name = "deleteOne"
                deleteCharOne.texture = deleteText
                deleteCharOne.position = CGPoint(x: characterOne.position.x, y: characterOne.position.y + size.height * 0.225)
                deleteCharOne.size = CGSize(width: size.width * 0.18, height: size.height * 0.075)
                deleteCharOne.zPosition = 1
                addChild(deleteCharOne)
            }
            else                //No character
            {
                playCharOne.name = "createCharOne"
                playCharOne.texture = createText
                playCharOne.position = CGPoint(x: characterOne.position.x, y: characterOne.position.y - size.height * 0.275)
                playCharOne.size = CGSize(width: size.width * 0.18, height: size.height * 0.075)
                playCharOne.zPosition = 1
                addChild(playCharOne)
            }
            addChild(characterOne)
        }
        if(num == 2)    //Second slot
        {
            characterTwo.name = "characterTwo"
            characterTwo.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
            characterTwo.size = CGSize(width: size.width * 0.1, height: size.height * 0.3)
            if(charPresent)     //Yes character
            {
                playCharTwo.name = "playCharTwo"
                playCharTwo.texture = playText
                playCharTwo.position = CGPoint(x: characterTwo.position.x, y: characterTwo.position.y - size.height * 0.425)
                playCharTwo.size = CGSize(width: size.width * 0.15, height: size.height * 0.075)
                playCharTwo.zPosition = 1
                addChild(playCharTwo)
                
                charTwoSkill.texture = findTexture(settings.characters[1].equippedWeapon)
                charTwoSkill.position = CGPoint(x: characterTwo.position.x, y: characterTwo.position.y - size.height * 0.275)
                charTwoSkill.size = CGSize(width: size.width * 0.1, height: size.height * 0.15)
                addChild(charTwoSkill)
                
                deleteCharTwo.name = "deleteTwo"
                deleteCharTwo.position = CGPoint(x: characterTwo.position.x, y: characterTwo.position.y + size.height * 0.225)
                deleteCharTwo.size = CGSize(width: size.width * 0.18, height: size.height * 0.075)
                deleteCharTwo.texture = deleteText
                deleteCharTwo.zPosition = 1
                addChild(deleteCharTwo)
            }
            else                //No character
            {
                playCharTwo.name = "createCharTwo"
                playCharTwo.texture = createText
                playCharTwo.position = CGPoint(x: characterTwo.position.x, y: characterTwo.position.y - size.height * 0.275)
                playCharTwo.size = CGSize(width: size.width * 0.18, height: size.height * 0.075)
                playCharTwo.zPosition = 1
                addChild(playCharTwo)
            }
            addChild(characterTwo)
        }
        if(num == 3)    //Third slot
        {
            characterThree.name = "characterThree"
            characterThree.position = CGPoint(x: size.width * 0.825, y: size.height * 0.55)
            characterThree.size = CGSize(width: size.width * 0.1, height: size.height * 0.3)
            if(charPresent)     //Yes character
            {
                playCharThree.name = "playCharThree"
                playCharThree.position = CGPoint(x: characterThree.position.x, y: characterThree.position.y - size.height * 0.425)
                playCharThree.size = CGSize(width: size.width * 0.15, height: size.height * 0.075)
                playCharThree.texture = playText
                playCharThree.zPosition = 1
                addChild(playCharThree)
                
                charThreeSkill.texture = findTexture(settings.characters[2].equippedWeapon)
                charThreeSkill.position = CGPoint(x: characterThree.position.x, y: characterThree.position.y - size.height * 0.275)
                charThreeSkill.size = CGSize(width: size.width * 0.1, height: size.height * 0.15)
                addChild(charThreeSkill)
                
                deleteCharThree.name = "deleteThree"
                deleteCharThree.position = CGPoint(x: characterThree.position.x, y: characterThree.position.y + size.height * 0.225)
                deleteCharThree.size = CGSize(width: size.width * 0.18, height: size.height * 0.075)
                deleteCharThree.texture = deleteText
                deleteCharThree.zPosition = 1
                addChild(deleteCharThree)
            }
            else                //No character
            {
                playCharThree.name = "createCharThree"
                playCharThree.position = CGPoint(x: characterThree.position.x, y: characterThree.position.y - size.height * 0.275)
                playCharThree.size = CGSize(width: size.width * 0.18, height: size.height * 0.075)
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
        if touchedNode.name == "createCharOne"
        {
            pickCharacterType(0)
        }
        if touchedNode.name == "createCharTwo"
        {
            pickCharacterType(1)
        }
        if touchedNode.name == "createCharThree"
        {
            pickCharacterType(2)
        }
        if touchedNode.name == "pickMelee"
        {
            pickedMelee()
        }
        if touchedNode.name == "pickShortRanged"
        {
            pickedShortRanged()
        }
        if touchedNode.name == "pickMagic"
        {
            pickedMagic()
        }
        if touchedNode.name == "pickLongRanged"
        {
            pickedLongRange()
        }
    }
    
    func save()
    {
        settings.save()
        scene?.removeFromParent()
    }
    
    func findTexture(skill: String) -> SKTexture?
    {
        if skill == "Melee"
        {
            return meleeText
        }
        else if skill == "Long Range"
        {
            return longRangedText
        }
        else if skill == "Magic"
        {
            return magicText
        }
        else if skill == "Short Range"
        {
            return shortRangedText
        }
        else
        {
            return nil
        }
    }
    
    func pickCharacterType(num: Int)
    {
        settings.selectedPlayer = num
        skillBG.texture = bGText
        skillBG.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        skillBG.size = CGSize(width: size.width * 0.9, height: size.height * 0.9)
        skillBG.zPosition = 2
        addChild(skillBG)
        skillTitle.texture = titleText
        skillTitle.position = CGPoint(x: size.width * 0.5, y: size.height * 0.825)
        skillTitle.size = CGSize(width: size.width * 0.5, height: size.height * 0.1)
        skillTitle.zPosition = 3
        addChild(skillTitle)
        skillTitle.texture = titleText
        pickMelee.name = "pickMelee"
        pickMelee.texture = meleeText
        pickMelee.position = CGPoint(x: size.width * 0.35, y: size.height * 0.6)
        pickMelee.size = CGSize(width: size.width * 0.2, height: size.height * 0.2)
        pickMelee.zPosition = 3
        addChild(pickMelee)
        pickShortRanged.name = "pickShortRanged"
        pickShortRanged.texture = shortRangedText
        pickShortRanged.position = CGPoint(x: size.width * 0.65, y: size.height * 0.6)
        pickShortRanged.size = CGSize(width: size.width * 0.2, height: size.height * 0.2)
        pickShortRanged.zPosition = 3
        addChild(pickShortRanged)
        pickMagic.name = "pickMagic"
        pickMagic.texture = magicText
        pickMagic.position = CGPoint(x: size.width * 0.35, y: size.height * 0.3)
        pickMagic.size = CGSize(width: size.width * 0.2, height: size.height * 0.2)
        pickMagic.zPosition = 3
        addChild(pickMagic)
        pickLongRanged.name = "pickLongRanged"
        pickLongRanged.texture = longRangedText
        pickLongRanged.position = CGPoint(x: size.width * 0.65, y: size.height * 0.3)
        pickLongRanged.size = CGSize(width: size.width * 0.2, height: size.height * 0.2)
        pickLongRanged.zPosition = 3
        addChild(pickLongRanged)
    }
    
    func pickedMelee()
    {
        settings.addCharacter(1)
        openGame()
    }
    func pickedShortRanged()
    {
        settings.addCharacter(4)
        openGame()
    }
    func pickedMagic()
    {
        settings.addCharacter(3)
        openGame()
    }
    func pickedLongRange()
    {
        settings.addCharacter(2)
        openGame()
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
        settings.characters.removeFirst()
        resetScreen()
    }
    
    func deleteP2()
    {
        settings.characters.removeAtIndex(1)
        resetScreen()
    }
    
    func deleteP3()
    {
        settings.characters.removeAtIndex(2)
        resetScreen()
    }
    
    func resetScreen()
    {
        playCharOne.removeFromParent()
        charOneSkill.removeFromParent()
        deleteCharOne.removeFromParent()
        characterOne.removeFromParent()
        playCharTwo.removeFromParent()
        charTwoSkill.removeFromParent()
        deleteCharTwo.removeFromParent()
        characterTwo.removeFromParent()
        playCharThree.removeFromParent()
        charThreeSkill.removeFromParent()
        deleteCharThree.removeFromParent()
        characterThree.removeFromParent()
        let numChar: Int = settings.howManyCharacters()
        if numChar == 0
        {
            prepSlot(1, charPresent: false)
            prepSlot(2, charPresent: false)
            prepSlot(3, charPresent: false)
        }
        else if numChar == 1
        {
            prepSlot(1, charPresent: true)
            prepSlot(2, charPresent: false)
            prepSlot(3, charPresent: false)
        }
        else if numChar == 2
        {
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
    
    func openGame()
    {
        if settings.selectedPlayer >= settings.howManyCharacters()
        {
            settings.selectedPlayer = settings.howManyCharacters() - 1
        }
        save()
        print("here", settings.howManyCharacters(), settings.selectedPlayer)
        let scene = GameScene(size: view!.bounds.size)
        scene.scaleMode = .ResizeFill
        view!.presentScene(scene)
    }
}
