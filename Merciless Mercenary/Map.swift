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
    var chests: [Coordinate] = []
    var currLoc: Coordinate!
    var spawnPoint: Coordinate!
    var keyPoint: Coordinate!
    var bossPoint: Coordinate!
    var maxWidth: Int!
    
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
            currLoc = spawnPoint
            maxWidth = 7
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
            currLoc = spawnPoint
            maxWidth = 7
        default:
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
            currLoc = spawnPoint
            maxWidth = 7
        }
        update(currLoc)
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
        for spot in realMapLoc
        {
            if !(spot.equals(keyPoint) || spot.equals(bossPoint) || spot.equals(spawnPoint))
            {
                if(Int(arc4random_uniform(100)) < 10)    //10% chance
                {
                    let type = Int(arc4random_uniform(100))
                    if(type < 2)   //2% legendary
                    {
                        spot.chest = "legendary"
                        chests.append(spot)
                    }
                    else if(type < 12)    //10% rare
                    {
                        spot.chest = "rare"
                        chests.append(spot)
                    }
                    else if(type < 37)    //25% uncommon
                    {
                        spot.chest = "uncommon"
                        chests.append(spot)
                    }
                    else
                    {
                        spot.chest = "common"
                        chests.append(spot)
                    }
                }
            }
        }
    }
    
    func getWidth() -> Int
    {
        return maxWidth
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
    
    func getCurr() -> Coordinate
    {
        return currLoc
    }
    
    func getLeft() -> Coordinate?
    {
        for spot in realMapLoc
        {
            if(currLoc.x - spot.getCoor().x == 1 && currLoc.y - spot.getCoor().y == 0)
            {
                return spot
            }
        }
        return nil
    }
    
    func getRight() -> Coordinate?
    {
        for spot in realMapLoc
        {
            if(currLoc.x - spot.getCoor().x == -1 && currLoc.y - spot.getCoor().y == 0)
            {
                return spot
            }
        }
        return nil
    }
    
    func getUp() -> Coordinate?
    {
        for spot in realMapLoc
        {
            if(currLoc.x - spot.getCoor().x == 0 && currLoc.y - spot.getCoor().y == 1)
            {
                return spot
            }
        }
        return nil
    }
    
    func getDown() -> Coordinate?
    {
        for spot in realMapLoc
        {
            if(currLoc.x - spot.getCoor().x == 0 && currLoc.y - spot.getCoor().y == -1)
            {
                return spot
            }
        }
        return nil
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
    
    func getChest() -> [Coordinate]
    {
        return chests
    }
    
    func updateVisited(loc: Coordinate)
    {
        if(!visited.contains(loc))
        {
            visited.append(loc)
        }
    }
    
    func updateKnown(locs: [Coordinate])
    {
        for spot in locs
        {
            if(!known.contains(spot))
            {
                known.append(spot)
            }
        }
    }
    
    func update(loc: Coordinate)
    {
        currLoc = loc
        updateVisited(loc)
        updateKnown(getAdjacent(loc))
    }
}

class Coordinate: NSObject {
    var x: Int!
    var y: Int!
    var chest: String!
    
    override var description:String {
        return "(\(x), \(y)): \(chest)"
    }
    
    init(xCoor: Int, yCoor: Int)
    {
        x = xCoor
        y = yCoor
        chest = nil
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
