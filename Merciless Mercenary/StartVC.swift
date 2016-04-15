//
//  StartVC.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/13/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class StartVC: UIViewController {

    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width           //Dimensions of phone
    let screenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    
    var settings: Settings!
    var playBut: UIButton!
    var settingsBut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        playBut = UIButton(frame: CGRectMake(screenWidth * 0.4, screenHeight * 0.1, screenWidth * 0.2, screenHeight * 0.1))
        playBut.setTitle("PLAY", forState: UIControlState.Normal)
        playBut.addTarget(self, action: #selector(StartVC.goToChar), forControlEvents: UIControlEvents.TouchUpInside)
        playBut.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        playBut.layer.cornerRadius = 0.1 * playBut.frame.width
        playBut.layer.borderWidth = playBut.frame.width * 0.03
        playBut.layer.borderColor = UIColor.blackColor().CGColor
        view.addSubview(playBut)
        
        settingsBut = UIButton(frame: CGRectMake(screenWidth * 0.4, screenHeight * 0.3, screenWidth * 0.2, screenHeight * 0.1))
        settingsBut.setTitle("SETTINGS", forState: UIControlState.Normal)
        settingsBut.addTarget(self, action: #selector(StartVC.goToSet), forControlEvents: UIControlEvents.TouchUpInside)
        settingsBut.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        settingsBut.layer.cornerRadius = 0.1 * playBut.frame.width
        settingsBut.layer.borderWidth = playBut.frame.width * 0.03
        settingsBut.layer.borderColor = UIColor.blackColor().CGColor
        view.addSubview(settingsBut)
    }
    
    func goToChar()
    {
        performSegueWithIdentifier("goToChar", sender: self)
    }
    
    func goToSet()
    {
        performSegueWithIdentifier("goToSet", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToChar"
        {
            let dvc = segue.destinationViewController as! CharacterVC
            dvc.settings = self.settings
        }
        else
        {
            
        }
    }
}
