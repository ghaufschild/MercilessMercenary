//
//  Character.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/7/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

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
        self.fighterType = aDecoder.decodeIntegerForKey("fighterType")
        self.currentHealth = aDecoder.decodeIntegerForKey("currentHealth")
        self.maxHealth = aDecoder.decodeIntegerForKey("maxHealth")
        self.moveSpeed = aDecoder.decodeIntegerForKey("moveSpeed")
        self.level = aDecoder.decodeIntegerForKey("level")
        self.map = aDecoder.decodeObjectForKey("map") as! Map
        self.equippedWeapon = aDecoder.decodeObjectForKey("equippedWeapon") as! String
        self.inventory = aDecoder.decodeObjectForKey("inventory") as! Inventory
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeInteger(self.fighterType, forKey: "fighterType")
        coder.encodeInteger(self.currentHealth, forKey: "currentHealth")
        coder.encodeInteger(self.maxHealth, forKey: "maxHealth")
        coder.encodeInteger(self.moveSpeed, forKey: "moveSpeed")
        coder.encodeInteger(self.level, forKey: "level")
        coder.encodeObject(self.map, forKey: "map")
        coder.encodeObject(self.equippedWeapon, forKey: "equippedWeapon")
        coder.encodeObject(self.inventory, forKey: "inventory")
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
