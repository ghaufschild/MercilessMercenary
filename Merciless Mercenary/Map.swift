//
//  Map.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/7/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import UIKit

class Map: NSObject {

    var realMapLoc: [Coordinate] = []
    var spawnPoint: Coordinate!
    var keyPoint: Coordinate!
    var bossPoint: Coordinate!
    
    init(version: Int)
    {
        switch version {
        case 1:
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 6))
            spawnPoint = Coordinate(xCoor: 3, yCoor: 3)
            keyPoint = Coordinate(xCoor: 1, yCoor: 6)
            bossPoint = Coordinate(xCoor: 1, yCoor: 1)
        case 2:
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 6))
            spawnPoint = Coordinate(xCoor: 3, yCoor: 3)
            keyPoint = Coordinate(xCoor: 1, yCoor: 6)
            bossPoint = Coordinate(xCoor: 1, yCoor: 1)
        case 3:
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 6))
            spawnPoint = Coordinate(xCoor: 3, yCoor: 3)
            keyPoint = Coordinate(xCoor: 1, yCoor: 6)
            bossPoint = Coordinate(xCoor: 1, yCoor: 1)
        case 4:
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 6))
            spawnPoint = Coordinate(xCoor: 3, yCoor: 3)
            keyPoint = Coordinate(xCoor: 1, yCoor: 6)
            bossPoint = Coordinate(xCoor: 1, yCoor: 1)
        default:
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 6))
            spawnPoint = Coordinate(xCoor: 3, yCoor: 3)
            keyPoint = Coordinate(xCoor: 1, yCoor: 6)
            bossPoint = Coordinate(xCoor: 1, yCoor: 1)
        }
    }
    
}

class Coordinate: NSObject {
    var x: Int!
    var y: Int!
    
    init(xCoor: Int, yCoor: Int)
    {
        x = xCoor
        y = yCoor
    }
    
    func getCoor() -> (x: Int, y: Int)
    {
        return (x, y)
    }
}
