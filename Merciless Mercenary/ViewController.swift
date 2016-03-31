//
//  ViewController.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 2/18/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width           //Dimensions of phone
    let screenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    
    var ground: UIView!         //Ground for the game, no interaction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ground = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight * 0.7))
        ground.backgroundColor = UIColor(patternImage: UIImage(named: "ground")!)
        
        
        view.addSubview(ground)
     }
}

