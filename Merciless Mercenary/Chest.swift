//
//  Chest.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 12/9/19.
//  Copyright © 2019 Swag Productions. All rights reserved.
//

import Foundation
import UIKit

class Chest: NSObject, NSCoding {
    let chestType: ChestType
    var items: [Reward] = []
    
    override var description: String {
        return "\(chestType)"
    }
    
    public override init() {
        let type = Int.random(in: 0..<100)
        var times: Int
        if(type < 5) {  //5% legendary
            chestType = .legendary
            times = 24
        } else if(type < 20) {   //15% rare
            chestType = .rare
            times = 10
        } else if(type < 55) {    //35% uncommon
            chestType = .uncommon
            times = 4
        } else {                 //45% common
            times = 2
            chestType = .common
        }
        
        items = []
    }
    
    required init(coder aDecoder: NSCoder) {
        self.chestType = aDecoder.decodeObject(forKey: "chestType") as! ChestType
        self.items = aDecoder.decodeObject(forKey: "items") as! [Reward]
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.chestType, forKey: "chestType")
        coder.encode(self.items, forKey: "items")
    }
    
    func generateRewards() -> [Reward] {
        var times: Int
        if(chestType == .legendary) {  //5% legendary
            times = 24
        } else if(chestType == .rare) {   //15% rare
            times = 10
        } else if(chestType == .uncommon) {    //35% uncommon
            times = 4
        } else {                 //45% common
            times = 2
        }
        
        for _ in 0..<times {
            items.append(generateReward())
        }
        
        return items
    }
    
    func generateReward() -> Reward
    {
        let chestType = Int.random(in: 0..<100)
        if(chestType < 25)  //25% chance
        {
            return randomDefense()    //Defense
        }
        else if(chestType < 50) //25% chance
        {
            return randomAttack()    //Attack
        }
        else    //50% chance
        {
            return randomPotion()    //Potions
        }
    }
    
    func randomPotion() -> Reward
    {
        let chestType = Int.random(in: 0..<100)
        if(chestType < 40)  //40% chance
        {
            return Reward.healthPot()    //Health Potions
        }
        else if(chestType < 60) //20% chance
        {
            return Reward.speedPot()    //Speed Potions
        }
        else if(chestType < 80) //20% chance
        {
            return Reward.damagePot()    //Damage Potions
        }
        else    //20% chance
        {
            return Reward.blockPot()   //Block Chance Potions
        }
    }
    
    func randomAttack() -> Reward
    {
        let chestType = Int.random(in: 0..<100)
        if(chestType < 23)  //23% chance
        {
            return Reward.sword()    //Sword Upgrade
        }
        else if(chestType < 46) //23% chance
        {
            return Reward.bow()   //Bow Upgrade
        }
        else if(chestType < 69) //23% chance
        {
            return Reward.fireball()    //Fireball Upgrade
        }
        else if(chestType < 92) //23% chance
        {
            return Reward.shuriken()    //Shuriken Upgrade
        }
        else    //8% chance
        {
            return Reward.crit()    //Crit Chance Upgrade
        }
    }
    
    func randomDefense() -> Reward
    {
        let chestType = Int.random(in: 0..<100)
        if(chestType < 40)  //40% chance
        {
            return Reward.armor()    //Armor Upgrade
        }
        else if(chestType < 60) //20% chance
        {
            return Reward.speed()    //Speed Upgrade
        }
        else if(chestType < 80) //20% chance
        {
            return Reward.health()    //Health Upgrade
        }
        else    //20% chance
        {
            return Reward.block()    //Block Chance Upgrade
        }
    }
}
