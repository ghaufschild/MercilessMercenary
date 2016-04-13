//
//  Inventory.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 2/18/16.xc
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class Inventory: NSObject {
    //Capacity Size
    var capacity: Int!
    var size: Int!
    var items: [item] = []
    
    override init()
    {
        size = 0
        capacity = 100
    }
    
    func add(pickedUp: item) -> Bool    //Return true if picked up, false if full
    {
        if(pickedUp.getSize() + size <= capacity)
        {
            items.append(pickedUp)
            size = size + pickedUp.getSize()
            return true
        }
        else
        {
            return false
        }
    }
    
    //Sword of divinity
    //Shield of Vulneary
    //OGGMOR
    //Valiant
    //Juice Box
    //Dagger

}

class item: NSObject
{
    var size: Int!
    
    init(s: Int)
    {
        size = s
    }
    
    func getSize() -> Int
    {
        return size
    }
}

class Weapon: item {
    //Capacity
    //Damage
}

class Armor: item {
    
}

//Melee vs. Range
//Magic Resist vs. Armor
//Block Crit Strike
//Can't be impaired
//Speed increases
