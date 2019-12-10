//
//  Enemy.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 5/7/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Enemy: NSObject {
    
    let maxHealth: Int!
    var currentHealth: Int!
    var damage: Int!
    var moveSpeed: Int!
    var type: Int!
    var sprite: SKSpriteNode!
    var flickerCounter = 0
    var timer = Timer()
    
    init(h: Int, dam: Int, move: Int, num: Int, enemy: SKSpriteNode)
    {
        maxHealth = h
        currentHealth = h
        damage = dam
        moveSpeed = move
        type = num
        sprite = enemy
    }
    
    func gotHit(_ dam: Int) -> Bool       //return true if still alive, false if dead
    {
        currentHealth = currentHealth - dam
        if currentHealth > 0
        {
            return true
        }
        return false
    }
    
    func flicker()
    {
        timer.invalidate()
        flickerCounter = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(Enemy.changeAlpha), userInfo: nil, repeats: true)
    }
    
    @objc func changeAlpha()
    {
        flickerCounter += 1
        if(flickerCounter < 6)
        {
            sprite.alpha = CGFloat(12 - (flickerCounter * 2))/10
        }
        else
        {
            sprite.alpha = CGFloat((flickerCounter - 5) * 2)/10
        }
        if(flickerCounter == 10)
        {
            flickerCounter = 0
            timer.invalidate()
        }
    }
    
    func getDamage() -> Int
    {
        return damage
    }
    
    func getMoveSpeed() -> Int
    {
        return moveSpeed
    }
    
    func getCurrent() -> Int
    {
        return currentHealth
    }
    
    func getMax() -> Int
    {
        return maxHealth
    }
    
}
