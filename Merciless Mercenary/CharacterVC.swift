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
    var playCharOne: UIButton!
    var characterOne: UIView!
    var characterTwo: UIView!
    var characterThree: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        playCharOne.addTarget(self, action: #selector(CharacterVC.goToGameP1), forControlEvents: UIControlEvents.TouchUpInside)
        playCharOne.setTitle("PLAY", forState: .Normal)
        playCharOne.backgroundColor = UIColor.blueColor()
        characterOne.addSubview(playCharOne)
        
    }
    
    func prepSlot(num: Int, charPresent: Bool)
    {
        if(num == 1)    //First slot
        {
            characterOne = UIView(frame: CGRect(x: view.frame.width * 0.025, y: view.frame.height * 0.15, width: view.frame.width * 0.3, height: view.frame.height * 0.8))
            characterOne.layer.borderWidth = view.frame.width * 0.025
            characterOne.layer.borderColor = UIColor.blackColor().CGColor
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view.addSubview(characterOne)
        }
        if(num == 2)    //Second slot
        {
            characterTwo = UIView(frame: CGRect(x: view.frame.width * 0.35, y: view.frame.height * 0.15, width: view.frame.width * 0.3, height: view.frame.height * 0.8))
            characterTwo.layer.borderWidth = view.frame.width * 0.025
            characterTwo.layer.borderColor = UIColor.blackColor().CGColor
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view.addSubview(characterTwo)
        }
        if(num == 3)    //Third slot
        {
            characterThree = UIView(frame: CGRect(x: view.frame.width * 0.675, y: view.frame.height * 0.15, width: view.frame.width * 0.3, height: view.frame.height * 0.8))
            characterThree.layer.borderWidth = view.frame.width * 0.025
            characterThree.layer.borderColor = UIColor.blackColor().CGColor
            if(charPresent)     //Yes character
            {
                
            }
            else                //No character
            {
                
            }
            view.addSubview(characterThree)
        }
    }
    
    func goToGameP1()
    {
        settings.selectedPlayer = 1
        performSegueWithIdentifier("toGame", sender: self)
    }
    
    func goToGameP2()
    {
        settings.selectedPlayer = 2
        performSegueWithIdentifier("toGame", sender: self)
    }
    
    func goToGameP3()
    {
        settings.selectedPlayer = 3
        performSegueWithIdentifier("toGame", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        settings.save()
    }

}
