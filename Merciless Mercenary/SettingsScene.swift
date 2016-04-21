//
//  SettingsVC.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/13/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class SettingsScene: SKScene {

    var settings: Settings!
    
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
        
    }
    
    func save()
    {
        settings.save()
        scene?.removeFromParent()
    }
    
}
