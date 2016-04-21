//
//  Settings.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/7/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class Settings: NSObject, NSCoding {

    var difficulty = 1
    var soundOn = true
    var musicOn = true
    var characters: [Character] = []
    var selectedPlayer: Int = 1
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.difficulty = aDecoder.decodeIntegerForKey("difficulty")
        self.selectedPlayer = aDecoder.decodeIntegerForKey("selectedPlayer")
        self.soundOn = aDecoder.decodeBoolForKey("sound")
        self.musicOn = aDecoder.decodeBoolForKey("music")
        self.characters = aDecoder.decodeObjectForKey("characters") as! Array<Character>
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeInteger(self.difficulty, forKey: "difficulty")
        coder.encodeInteger(self.selectedPlayer, forKey: "selectedPlayer")
        coder.encodeBool(self.soundOn, forKey: "sound")
        coder.encodeBool(self.musicOn, forKey: "music")
        coder.encodeObject(self.characters, forKey: "characters")
    }
    
    func howManyCharacters() -> Int
    {
        return characters.count
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "settings")
    }
    
    class func loadSaved() -> Settings? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("settings") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Settings
        }
        return nil
    }
    
    func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("settings")
    }
    
}
