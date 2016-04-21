//
//  Character.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/7/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class Character: NSObject {

    var fighterType: Int! //1 is melee, 2 is archery, 3 is mage
    var equippedWeapon: Weapon? = nil
    var equippedArmor: Armor? = nil
    var inventory: Inventory!

    var currentHealth: Int!
    var maxHealth: Int!
    var moveSpeed: Int!
    
    var level: Int!
    var map: Map!
    
    func Character(fightType: Int)
    {
        fighterType = fightType
        if(fightType == 1)  // Melee high health, low speed, medium attack
        {
            maxHealth = 6
            currentHealth = maxHealth
            moveSpeed = 5
        }
        else if(fightType == 2) //Archer medium health, high speed, low attack
        {
            maxHealth = 5
            currentHealth = maxHealth
            moveSpeed = 9
        }
        else if(fightType == 3) //Mage low health, medium speed, high attack
        {
            maxHealth = 4
            currentHealth = maxHealth
            moveSpeed = 7
        }
        level = 1
        map = Map(version: 1)
    }
}
