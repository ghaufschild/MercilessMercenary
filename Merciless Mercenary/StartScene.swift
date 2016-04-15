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
        
        playBut = UIButton(frame: CGRectMake(screenWidth * 0.4, screenHeight * 0.1, screenWidth * 0.2, screenHeight * 0.2))
        playBut.setTitle("PLAY", forState: UIControlState.Normal)
        playBut.addTarget(self, action: #selector(StartScene.goToChar), forControlEvents: UIControlEvents.TouchUpInside)
        playBut.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        playBut.layer.cornerRadius = 0.1 * playBut.frame.width
        playBut.layer.borderWidth = playBut.frame.width * 0.03
        playBut.layer.borderColor = UIColor.blackColor().CGColor
        view.addSubview(playBut)
        
        settingsBut = UIButton(frame: CGRectMake(screenWidth * 0.4, screenHeight * 0.4, screenWidth * 0.2, screenHeight * 0.2))
        settingsBut.setTitle("SETTINGS", forState: UIControlState.Normal)
        settingsBut.addTarget(self, action: #selector(StartScene.goToSet), forControlEvents: UIControlEvents.TouchUpInside)
        settingsBut.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        settingsBut.layer.cornerRadius = 0.1 * playBut.frame.width
        settingsBut.layer.borderWidth = playBut.frame.width * 0.03
        settingsBut.layer.borderColor = UIColor.blackColor().CGColor
        view.addSubview(settingsBut)
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
