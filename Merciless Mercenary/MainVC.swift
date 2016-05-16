//
//  MainVC.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/15/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = CharacterScene(size: view.bounds.size)
        let skView: SKView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
