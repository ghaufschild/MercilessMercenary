//
//  Inventory.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 2/18/16.xc
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class Inventory: NSObject, NSCoding {

    var items: [Item] = []
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.items = aDecoder.decodeObjectForKey("items") as! [Item]
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(self.items, forKey: "items")
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
    
    func add(name: String) -> Bool    //Return true if picked up, false if full
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
    
    func get(name: String) -> Item?
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
    
    func remove(name: String) -> Bool   //True if removed, false if none
    {
        for item in items
        {
            if(item.getName() == name)
            {
                if(item.getAmount() > 0)
                {
                    item.amount = item.amount - 1
                    return true
                }
                else
                {
                    return false
                }
            }
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
        self.cap = aDecoder.decodeIntegerForKey("cap")
        self.amount = aDecoder.decodeIntegerForKey("amount")
        self.name = aDecoder.decodeObjectForKey("name") as! String
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeInteger(self.cap, forKey: "cap")
        coder.encodeInteger(self.amount, forKey: "amount")
        coder.encodeObject(self.name, forKey: "name")
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
        if(!(amount + 1 > cap))
        {
            amount += 1
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
