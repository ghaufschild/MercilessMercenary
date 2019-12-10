//
//  Map.swift
//  Merciless Mercenary
//
//  Created by Garrett Haufschild on 4/7/16.
//  Copyright © 2016 Swag Productions. All rights reserved.
//

import Foundation
import UIKit

class Map: NSObject, NSCoding {
    
    var realMapLoc: [Coordinate] = []
    var visited: [Coordinate] = []
    var known: [Coordinate] = []
    var chests: [Coordinate] = []
    var cleared: [Coordinate] = []
    var respawnPoint: Coordinate!
    var currLoc: Coordinate!
    var spawnPoint: Coordinate!
    var keyPoint: Coordinate!
    var bossPoint: Coordinate!
    var maxWidth: Int!
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.maxWidth = aDecoder.decodeObject(forKey: "maxWidth") as? Int
        self.respawnPoint = aDecoder.decodeObject(forKey: "respawn") as? Coordinate
        self.cleared = aDecoder.decodeObject(forKey: "cleared") as! [Coordinate]
        self.realMapLoc = aDecoder.decodeObject(forKey: "realMapLoc") as! [Coordinate]
        self.visited = aDecoder.decodeObject(forKey: "visited") as! [Coordinate]
        self.known = aDecoder.decodeObject(forKey: "known") as! [Coordinate]
        self.chests = aDecoder.decodeObject(forKey: "chests") as! [Coordinate]
        self.currLoc = aDecoder.decodeObject(forKey: "currLoc") as? Coordinate
        self.spawnPoint = aDecoder.decodeObject(forKey: "spawnPoint") as? Coordinate
        self.keyPoint = aDecoder.decodeObject(forKey: "keyPoint") as? Coordinate
        self.bossPoint = aDecoder.decodeObject(forKey: "bossPoint") as? Coordinate
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.maxWidth, forKey: "maxWidth")
        coder.encode(self.respawnPoint, forKey: "respawn")
        coder.encode(self.cleared, forKey: "cleared")
        coder.encode(self.realMapLoc, forKey: "realMapLoc")
        coder.encode(self.visited, forKey: "visited")
        coder.encode(self.known, forKey: "known")
        coder.encode(self.chests, forKey: "chests")
        coder.encode(self.currLoc, forKey: "currLoc")
        coder.encode(self.spawnPoint, forKey: "spawnPoint")
        coder.encode(self.keyPoint, forKey: "keyPoint")
        coder.encode(self.bossPoint, forKey: "bossPoint")
    }
    
    init(version: Int)
    {
        super.init()
        switch version {
        case 1:
            let map: [[Int]] =
                [[0, 3, 1, 1, 0, 0, 0],
                 [0, 0, 0, 1, 1, 1, 1],
                 [0, 0, 0, 1, 0, 0, 4],
                 [1, 1, 1, 2, 0, 1, 1],
                 [1, 0, 0, 1, 0, 1, 0],
                 [1, 1, 0, 1, 1, 1, 0],
                 [0, 4, 0, 0, 3, 0, 0]]
            generateLocs(map)
            currLoc = spawnPoint
            maxWidth = map.count
        case 2:
            let map: [[Int]] =
                [[0, 4, 0, 0, 1, 1, 0],
                 [0, 1, 1, 1, 0, 1, 3],
                 [1, 1, 0, 1, 0, 1, 1],
                 [1, 0, 0, 2, 1, 1, 0],
                 [1, 1, 1, 1, 0, 0, 0],
                 [1, 0, 1, 0, 0, 0, 3],
                 [4, 1, 1, 1, 1, 1, 1]]
            generateLocs(map)
            currLoc = spawnPoint
            maxWidth = map.count
        default:
            let map: [[Int]] =
                [[0, 3, 1, 1, 0, 0, 0],
                 [0, 0, 0, 1, 1, 1, 1],
                 [0, 0, 0, 1, 0, 0, 4],
                 [1, 1, 1, 2, 0, 1, 1],
                 [1, 0, 0, 1, 0, 1, 0],
                 [1, 1, 0, 1, 1, 1, 0],
                 [0, 4, 0, 0, 3, 0, 0]]
            generateLocs(map)
            currLoc = spawnPoint
            maxWidth = map.count
        }
        update(currLoc)
    }
    
    func generateLocs(_ map: [[Int]])
    {
        let firstKey = Bool.random()
        let firstBoss = Bool.random()
        var seenFirstKey = false
        var seenFirstBoss = false
        for x in 0...6 {
            for y in 0...6 {
                switch map[x][y] {
                case 1:     //Regular Locaiton
                    let coord: Coordinate = Coordinate(xCoor: x, yCoor: y)
                    if(Int.random(in: 0..<100) < 100) {  //33% chance
                        print("\(coord.x!), \(coord.y!)")
                        let type: Int = Int.random(in: 0..<100)
                        if(type < 100) {              //5% legendary
                            coord.chest = "legendary"
                        } else if(type < 20) {      //15% rare
                            coord.chest = "rare"
                        } else if(type < 55) {      //35% uncommon
                            coord.chest = "uncommon"
                        } else {                    //45% common
                            coord.chest = "common"
                        }
                    }
 
                    realMapLoc.append(coord)
                case 2:     //Spawn Point
                    realMapLoc.append(Coordinate(xCoor: x, yCoor: y))
                    spawnPoint = realMapLoc[realMapLoc.count - 1]
                case 3:     //Key Location
                    realMapLoc.append(Coordinate(xCoor: x, yCoor: y))
                    if(firstKey) {
                        if(!seenFirstKey) {
                            keyPoint = realMapLoc[realMapLoc.count - 1]
                        }
                        seenFirstKey = true
                    } else if(!firstKey && seenFirstKey) {
                        keyPoint = realMapLoc[realMapLoc.count - 1]
                    }
                case 4:     //Boss Location
                    realMapLoc.append(Coordinate(xCoor: x, yCoor: y))
                    if(firstBoss) {
                        if(!seenFirstBoss) {
                            bossPoint = realMapLoc[realMapLoc.count - 1]
                        }
                        seenFirstBoss = true
                    } else if(!firstBoss && seenFirstBoss) {
                        bossPoint = realMapLoc[realMapLoc.count - 1]
                    }
                default: break
                }
            }
        }
        
        respawnPoint = spawnPoint
        cleared.append(spawnPoint)
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
    
    func getAdjacent(_ loc: Coordinate) -> [Coordinate]
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
    
    func updateVisited(_ loc: Coordinate)
    {
        if(!visited.contains(loc))
        {
            visited.append(loc)
        }
    }
    
    func updateKnown(_ locs: [Coordinate])
    {
        for spot in locs
        {
            if(!known.contains(spot))
            {
                known.append(spot)
            }
        }
    }
    
    func update(_ loc: Coordinate)
    {
        respawnPoint = currLoc
        currLoc = loc
        updateVisited(loc)
        updateKnown(getAdjacent(loc))
    }
    
    func cleared(_ loc: Coordinate)
    {
        if(!cleared.contains(loc))
        {
            cleared.append(loc)
        }
    }
}

class Coordinate: NSObject, NSCoding {
    var x: Int!
    var y: Int!
    var visited: Bool!
    var known: Bool!
    var cleared: Bool!
    var chest: String?

    override var description:String {
        return "(\(x ?? -1), \(y ?? -1)): \(chest ?? "No Chest")"
    }
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        self.x = aDecoder.decodeObject(forKey: "x") as? Int
        self.y = aDecoder.decodeObject(forKey: "y") as? Int
        self.chest = aDecoder.decodeObject(forKey: "chest") as? String
    }
    
    func encode(with coder: NSCoder)
    {
        coder.encode(self.x, forKey: "x")
        coder.encode(self.y, forKey: "y")
        coder.encode(self.chest, forKey: "chest")
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
    
    func equals(_ other: Coordinate) -> Bool
    {
        return x == other.x && y == other.y
    }
    
    func nextTo(_ other: Coordinate) -> Bool
    {
        if(abs(x - other.x) == 0 && abs(y - other.y) == 1 || abs(x - other.x) == 1 && abs(y - other.y) == 0)
        {
            return true
        }
        return false
    }
}
