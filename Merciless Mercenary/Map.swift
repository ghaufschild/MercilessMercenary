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
    var visited: [Coordinate] = []
    var known: [Coordinate] = []
    var spawnPoint: Coordinate!
    var keyPoint: Coordinate!
    var bossPoint: Coordinate!
    
    init(version: Int)
    {
        super.init()
        switch version {
        case 1:
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 1))
            spawnPoint = Coordinate(xCoor: 3, yCoor: 3)
            generateLocs(realMapLoc)
        case 2:
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 3))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 6))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 7))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 2))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 1))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 0))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 0))
            realMapLoc.append(Coordinate(xCoor: 4, yCoor: 0))
            realMapLoc.append(Coordinate(xCoor: 5, yCoor: 0))
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 0))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 4))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 2, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 5))
            realMapLoc.append(Coordinate(xCoor: 1, yCoor: 0))
            realMapLoc.append(Coordinate(xCoor: 0, yCoor: 0))
            realMapLoc.append(Coordinate(xCoor: 3, yCoor: 7))   //KEY
            realMapLoc.append(Coordinate(xCoor: 6, yCoor: 1))   //KEY
            spawnPoint = Coordinate(xCoor: 3, yCoor: 3)
            generateLocs(realMapLoc)
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
    
    func generateLocs(locs: [Coordinate])
    {
        var check: Int = Int(arc4random_uniform(2))
        if(check == 0)
        {
            keyPoint = locs[locs.count - 1]
        }
        else if (check == 1)
        {
            keyPoint = locs[locs.count - 2]
        }
        check = Int(arc4random_uniform(6))
        bossPoint = locs[check]
    }
    
    func getSpawn() -> Coordinate
    {
        return spawnPoint
    }
    
    func getBoss() -> Coordinate
    {
        return bossPoint
    }
    
    func getKey() -> Coordinate
    {
        return keyPoint
    }
    
    func getAdjacent(loc: Coordinate) -> [Coordinate]
    {
        var nextTo: [Coordinate] = []
        for spot in realMapLoc
        {
            if(spot.nextTo(loc))
            {
                nextTo.append(spot)
            }
        }
        return nextTo
    }
    
    func visited(loc: Coordinate)
    {
        if(!visited.contains(loc))
        {
            visited.append(loc)
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
    
    func equals(other: Coordinate) -> Bool
    {
        if(x == other.x && y == other.y)
        {
            return true
        }
        return false
    }
    
    func nextTo(other: Coordinate) -> Bool
    {
        if(abs(x - other.x) == 0 && abs(y - other.y) == 1 || abs(x - other.x) == 1 && abs(y - other.y) == 0)
        {
            return true
        }
        return false
    }
}
