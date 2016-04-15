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
    var titleLabel: UILabel!
    var playCharOne: UIButton!
    var characterOne: UIView!
    var characterTwo: UIView!
    var characterThree: UIView!
    
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
        
        titleLabel = UILabel(frame: CGRect(x: view.frame.width * 0.1, y: view.frame.height * 0.05, width: view.frame.width * 0.8, height: view.frame.height * 0.1))
        titleLabel.textAlignment = .Center
        titleLabel.font.fontWithSize(30)
        titleLabel.text = "CHARACTER SLOTS"
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)

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
        
        playCharOne = UIButton(frame: CGRect(x: characterOne.frame.width * 0.2, y: characterOne.frame.height * 0.8, width: characterOne.frame.width * 0.6, height: characterOne.frame.height * 0.1))
        playCharOne.addTarget(self, action: #selector(CharacterScene.goToGameP1), forControlEvents: UIControlEvents.TouchUpInside)
        playCharOne.setTitle("PLAY", forState: .Normal)
        playCharOne.backgroundColor = UIColor.blueColor()
        characterOne.addSubview(playCharOne)
        
    }
    
    func prepSlot(num: Int, charPresent: Bool)
    {
        if(num == 1)    //First slot
        {
            characterOne = UIView(frame: CGRect(x: view!.frame.width * 0.025, y: view!.frame.height * 0.15, width: view!.frame.width * 0.3, height: view!.frame.height * 0.8))
            characterOne.layer.borderWidth = view!.frame.width * 0.025
            characterOne.layer.borderColor = UIColor.blackColor().CGColor
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view!.addSubview(characterOne)
        }
        if(num == 2)    //Second slot
        {
            characterTwo = UIView(frame: CGRect(x: view!.frame.width * 0.35, y: view!.frame.height * 0.15, width: view!.frame.width * 0.3, height: view!.frame.height * 0.8))
            characterTwo.layer.borderWidth = view!.frame.width * 0.025
            characterTwo.layer.borderColor = UIColor.blackColor().CGColor
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view!.addSubview(characterTwo)
        }
        if(num == 3)    //Third slot
        {
            characterThree = UIView(frame: CGRect(x: view!.frame.width * 0.675, y: view!.frame.height * 0.15, width: view!.frame.width * 0.3, height: view!.frame.height * 0.8))
            characterThree.layer.borderWidth = view!.frame.width * 0.025
            characterThree.layer.borderColor = UIColor.blackColor().CGColor
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view!.addSubview(characterThree)
        }
    }
    
    func save()
    {
        settings.save()
        scene?.removeFromParent()
    }
    
    func goToGameP1()
    {
        settings.selectedPlayer = 1
        openGame()
    }
    
    func goToGameP2()
    {
        settings.selectedPlayer = 2
        openGame()
    }
    
    func goToGameP3()
    {
        settings.selectedPlayer = 3
        openGame()
    }
    
    func openGame()
    {
        save()
        let scene = GameScene(size: view!.bounds.size)
        scene.scaleMode = .ResizeFill
        view!.presentScene(scene)
    }
}
