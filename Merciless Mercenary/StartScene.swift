//
//  StartVC.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/13/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class StartScene: SKScene {

    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width           //Dimensions of phone
    let screenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    
    var settings: Settings!
    var playBut: UIButton!
    var playButton =  SKSpriteNode()
    var settingsButton = SKSpriteNode()
    var settingsBut: UIButton!
    
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
        
        playButton.name = "goToCharacter"
        playButton.size = CGSize(width: view.frame.width * 0.2, height: view.frame.height * 0.2)
        playButton.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.8)
        playButton.color = SKColor.blackColor()
        addChild(playButton)
        
        settingsButton.name = "goToSettings"
        settingsButton.size = CGSize(width: view.frame.width * 0.2, height: view.frame.height * 0.2)
        settingsButton.position = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.5)
        settingsButton.color = SKColor.redColor()
        addChild(settingsButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let positionInScene = touches.first?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene!)
        
        if(touchedNode.name == "goToCharacter")
        {
            goToChar()
        }
        if(touchedNode.name == "goToSettings")
        {
            goToSet()
        }
    }
    
    func save()
    {
        settings.save()
        scene?.removeFromParent()
    }
    
    func goToChar()
    {
        save()
        let scene = CharacterScene(size: view!.bounds.size)
        scene.scaleMode = .ResizeFill
        view!.presentScene(scene)
    }
    
    func goToSet()
    {
        save()
        let scene = SettingsScene(size: view!.bounds.size)
        scene.scaleMode = .ResizeFill
        self.view!.presentScene(scene)
    }
}
