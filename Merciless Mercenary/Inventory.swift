//
//  Inventory.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 2/18/16.xc
//  Copyright © 2016 Swag Productions. All rights reserved.
//


import Foundation
import UIKit

class Inventory: NSObject, NSCoding {
    
    var items: [Item] = []
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.items = aDecoder.decodeObject(forKey: "items") as! [Item]
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.items, forKey: "items")
    }
    
    init(type: Int)
    {
        if(type == 1)   //Sword
        {
            items.append(Item(n: "Melee", c: 99, a: 1))
            items.append(Item(n: "Long Range", c: 99, a: 0))
            items.append(Item(n: "Magic", c: 99, a: 0))
            items.append(Item(n: "Short Range", c: 99, a: 0))
        }
        else if(type == 2)  //Bow
        {
            items.append(Item(n: "Melee", c: 99, a: 0))
            items.append(Item(n: "Long Range", c: 99, a: 1))
            items.append(Item(n: "Magic", c: 99, a: 0))
            items.append(Item(n: "Short Range", c: 99, a: 0))
        }
        else if(type == 3)  //Mage
        {
            items.append(Item(n: "Melee", c: 99, a: 0))
            items.append(Item(n: "Long Range", c: 99, a: 0))
            items.append(Item(n: "Magic", c: 99, a: 1))
            items.append(Item(n: "Short Range", c: 99, a: 0))
        }
        else    //Rogue
        {
            items.append(Item(n: "Melee", c: 99, a: 0))
            items.append(Item(n: "Long Range", c: 99, a: 0))
            items.append(Item(n: "Magic", c: 99, a: 0))
            items.append(Item(n: "Short Range", c: 99, a: 1))
        }
        
        items.append(Item(n: "Health Potions", c: 15, a: 0))
        items.append(Item(n: "Damage Potions", c: 15, a: 0))
        items.append(Item(n: "Speed Potions", c: 15, a: 0))
        items.append(Item(n: "Block Potions", c: 15, a: 0))
        
        items.append(Item(n: "Armor", c: 99, a: 0))
        items.append(Item(n: "Agility", c: 99, a: 0))
        items.append(Item(n: "Health", c: 99, a: 0))
        items.append(Item(n: "Block Chance", c: 99, a: 0))
        items.append(Item(n: "Crit Chance", c: 99, a: 0))
    }
    
    func add(_ name: String) -> Bool    //Return true if picked up, false if full
    {
        for item in items
        {
            if(item.getName() == name)
            {
                return item.upgrade()
            }
        }
        return false
    }
    
    func get(_ name: String) -> Item?
    {
        for item in items
        {
            if(item.getName() == name)
            {
                return item
            }
        }
        return nil
    }
    
    func remove(_ name: String) -> Bool   //True if removed, false if none
    {
        let item = get(name)
        if item?.amount ?? 0 > 0 {
            item?.amount -= 1
            return true
        }
        return false
    }
    
    //Sword of divinity
    //Shield of Vulneary
    //OGGMOR
    //Valiant
    //Juice Box
    //Dagger
    
}

class Item: NSObject, NSCoding
{
    var name: String = ""
    var cap: Int = 0
    var amount: Int = 0
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.cap = aDecoder.decodeInteger(forKey: "cap")
        self.amount = aDecoder.decodeInteger(forKey: "amount")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.cap, forKey: "cap")
        coder.encode(self.amount, forKey: "amount")
        coder.encode(self.name, forKey: "name")
    }
    
    init(n: String, c: Int, a: Int)
    {
        cap = c
        name = n
        amount = a
    }
    
    func getCap() -> Int
    {
        return cap
    }
    
    func getName() -> String
    {
        return name
    }
    
    func getAmount() -> Int
    {
        return amount
    }
    
    func upgrade() -> Bool
    {
        if amount < cap {
            amount += 1
            return true
        }
        return false
    }
    
    func equals(other: Item) -> Bool {
        return name == other.name
    }
}

class Skill: NSObject, NSCoding {
    var name: String = ""
    var cap: Int = 0
    var level: Int = 0
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.cap = aDecoder.decodeInteger(forKey: "cap")
        self.level = aDecoder.decodeInteger(forKey: "level")
        self.name = aDecoder.decodeObject(forKey: "name") as! String
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.cap, forKey: "cap")
        coder.encode(self.level, forKey: "level")
        coder.encode(self.name, forKey: "name")
    }
    
    init(n: String, c: Int, l: Int)
    {
        cap = c
        name = n
        level = l
    }
    
    func getCap() -> Int
    {
        return cap
    }
    
    func getName() -> String
    {
        return name
    }
    
    func getLevel() -> Int
    {
        return level
    }
    
    func upgrade() -> Bool
    {
        if level < cap {
            level += 1
            return true
        }
        return false
    }
}
//Melee vs. Range
//Magic Resist vs. Armor
//Block Crit Strike
//Can't be impaired
//Speed increases
