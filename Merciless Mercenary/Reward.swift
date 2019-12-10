//
//  Reward.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 12/10/19.
//  Copyright © 2019 Swag Productions. All rights reserved.
//

import Foundation
import UIKit

enum Reward {
    case healthPot(num:Int = 1, name:String  = "Health Potions", image: UIImage = UIImage(named: "HealthPot")!)
    case speedPot(num: Int = 2, name:String  = "Speed Potions", image: UIImage = UIImage(named: "SpeedPot")!)
    case damagePot(num: Int = 3, name:String  = "Damage Potions", image: UIImage = UIImage(named: "DamagePot")!)
    case blockPot(num: Int = 4, name:String  = "Block Potions", image: UIImage = UIImage(named: "BlockPot")!)
    case sword(num: Int = 5, name:String  = "Melee", image: UIImage = UIImage(named: "Sword")!)
    case bow(num: Int = 6, name:String  = "Long Range", image: UIImage = UIImage(named: "Bow and Arrow")!)
    case fireball(num: Int = 7, name:String  = "Magic", image: UIImage = UIImage(named: "Fireball")!)
    case shuriken(num: Int = 8, name:String  = "Short Range", image: UIImage = UIImage(named: "Shuriken")!)
    case crit(num: Int = 9, name:String  = "Crit Chance", image: UIImage = UIImage(named: "Crit Chance")!)
    case armor(num: Int = 10, name:String  = "Armor", image: UIImage = UIImage(named: "Armor")!)
    case speed(num: Int = 11, name:String  = "Agility", image: UIImage = UIImage(named: "Speed")!)
    case health(num: Int = 12, name:String  = "Health", image: UIImage = UIImage(named: "8BitHeart")!)
    case block(num: Int = 13, name:String  = "Blocking", image: UIImage = UIImage(named: "Block")!)
}
