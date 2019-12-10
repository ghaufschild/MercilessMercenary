//
//  Character.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/7/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import Foundation
import UIKit

class Character: NSObject, NSCoding {
    
    var fighterType: Int!   //1 is melee, 2 is archery, 3 is mage
    var equippedWeapon: String!
    var inventory: Inventory!
    
    var currentHealth: Int!
    var maxHealth: Int!
    var moveSpeed: Int!
    
    var level: Int!
    var map: Map!
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.fighterType = aDecoder.decodeObject(forKey: "fighterType") as? Int
        self.currentHealth = aDecoder.decodeObject(forKey: "currentHealth") as? Int
        self.maxHealth = aDecoder.decodeObject(forKey: "maxHealth") as? Int
        self.moveSpeed = aDecoder.decodeObject(forKey: "moveSpeed") as? Int
        self.level = aDecoder.decodeObject(forKey: "level") as? Int
        self.map = aDecoder.decodeObject(forKey: "map") as? Map
        self.equippedWeapon = aDecoder.decodeObject(forKey: "equippedWeapon") as? String
        self.inventory = aDecoder.decodeObject(forKey: "inventory") as? Inventory
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.fighterType, forKey: "fighterType")
        coder.encode(self.currentHealth, forKey: "currentHealth")
        coder.encode(self.maxHealth, forKey: "maxHealth")
        coder.encode(self.moveSpeed, forKey: "moveSpeed")
        coder.encode(self.level, forKey: "level")
        coder.encode(self.map, forKey: "map")
        coder.encode(self.equippedWeapon, forKey: "equippedWeapon")
        coder.encode(self.inventory, forKey: "inventory")
    }
    
    init(fightType: Int)
    {
        fighterType = fightType
        if(fightType == 1)  // Melee high health, low speed, medium attack
        {
            maxHealth = 6
            currentHealth = maxHealth
            moveSpeed = 5
            equippedWeapon = "Melee"
        }
        else if(fightType == 2) //Archer medium health, high speed, low attack
        {
            maxHealth = 5
            currentHealth = maxHealth
            moveSpeed = 9
            equippedWeapon = "Long Range"
        }
        else if(fightType == 3) //Mage low health, medium speed, high attack
        {
            maxHealth = 4
            currentHealth = maxHealth
            moveSpeed = 7
            equippedWeapon = "Magic"
        }
        else if(fightType == 4) //Short Range medium health, medium speed, medium attack
        {
            maxHealth = 5
            currentHealth = maxHealth
            moveSpeed = 7
            equippedWeapon = "Short Range"
        }
        inventory = Inventory(type: fightType)
        level = 1
        map = Map(version: 1)
    }
}

