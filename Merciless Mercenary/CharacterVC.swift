//
//  CharacterVC.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/13/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class CharacterVC: UIViewController {

    var settings: Settings!
    var titleLabel: UILabel!
    var characterOne: UIView!
    var characterTwo: UIView!
    var characterThree: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel = UILabel(frame: CGRect(x: view.frame.width * 0.1, y: view.frame.height * 0.05, width: view.frame.width * 0.8, height: view.frame.height * 0.1))
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
        
    }
    
    func prepSlot(num: Int, charPresent: Bool)
    {
        if(num == 1)    //First slot
        {
            characterOne = UIView(frame: CGRect(x: view.frame.width * 0.025, y: view.frame.height * 0.15, width: view.frame.width * 0.3, height: view.frame.height * 0.8))
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view.addSubview(characterOne)
        }
        if(num == 2)    //First slot
        {
            characterTwo = UIView(frame: CGRect(x: view.frame.width * 0.35, y: view.frame.height * 0.15, width: view.frame.width * 0.3, height: view.frame.height * 0.8))
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view.addSubview(characterTwo)
        }
        if(num == 3)    //First slot
        {
            characterThree = UIView(frame: CGRect(x: view.frame.width * 0.675, y: view.frame.height * 0.15, width: view.frame.width * 0.3, height: view.frame.height * 0.8))
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view.addSubview(characterThree)
        }
    }

}
