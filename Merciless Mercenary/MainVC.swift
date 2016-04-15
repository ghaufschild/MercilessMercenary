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
        
        let scene = StartScene(size: view.bounds.size)
        let skView: SKView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
