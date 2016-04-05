//
//  ViewController.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 2/18/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//


//Pan gesture to move, but have buttons as a visual
//

import UIKit
import SceneKit
import SpriteKit

class ViewController: UIViewController {

    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width           //Dimensions of phone
    let screenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    
//    var ground: UIView!         //Ground for the game, no interaction
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        ground = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight * 0.7))
//        ground.backgroundColor = UIColor(patternImage: UIImage(named: "ground")!)
//        
//        
//        view.addSubview(ground)
//     }
        override func viewDidLoad() {
            super.viewDidLoad()
            let scene = GameScene(size: view.bounds.size)
            let skView = view as! SKView
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

