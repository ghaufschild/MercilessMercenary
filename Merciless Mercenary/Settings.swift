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
    
    override init() {
        super.init()
        print("ran this shit")
        save()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.difficulty = aDecoder.decodeInteger(forKey: "difficulty")
        self.selectedPlayer = aDecoder.decodeInteger(forKey: "selectedPlayer")
        self.soundOn = aDecoder.decodeBool(forKey: "sound")
        self.musicOn = aDecoder.decodeBool(forKey: "music")
        self.characters = aDecoder.decodeObject(forKey: "characters") as! [Character]
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.difficulty, forKey: "difficulty")
        coder.encode(self.selectedPlayer, forKey: "selectedPlayer")
        coder.encode(self.soundOn, forKey: "sound")
        coder.encode(self.musicOn, forKey: "music")
        coder.encode(self.characters, forKey: "characters")
    }
    
    func addCharacter(_ fight: Int)
    {
        characters.append(Character(fightType: fight))
    }
    
    func howManyCharacters() -> Int
    {
        return characters.count
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "settings")
    }
    
    class func loadSaved() -> Settings? {
        let data = UserDefaults.standard.object(forKey: "settings") as? Data
        if  data != nil {
            return NSKeyedUnarchiver.unarchiveObject(with: data!) as? Settings
        }
        return nil
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: "settings")
    }
    
}
