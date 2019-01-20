//
//  Tile.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 04/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation
import CoreGraphics

func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

struct Position: Equatable {
    var x, y: Int
}

class Tile {
    
    var position: Position
    var value: Int
    var goalValue: Int
    
    var upTile: Tile?
    var rightTile: Tile?
    var bottomTile: Tile?
    var leftTile: Tile?
    
    init(position: Position, value: Int, goalValue: Int) {
        self.position = position
        self.value = value
        self.goalValue = goalValue
    }
    
    lazy var possibleMoveDirections: [ShiftDirection] = {
        var possibleMoveDirections = [ShiftDirection]()
        if let _ = upTile as Tile? {
            possibleMoveDirections.append(ShiftDirection.down)
        }
        if let _ = leftTile as Tile? {
            possibleMoveDirections.append(ShiftDirection.right)
        }
        if let _ = rightTile as Tile? {
            possibleMoveDirections.append(ShiftDirection.left)
        }
        if let _ = bottomTile as Tile? {
            possibleMoveDirections.append(ShiftDirection.up)
        }
        return possibleMoveDirections
    }()
    
    var description: String {
        return "x: \(position.x), y: \(position.y), value: \(value), goalValue: \(goalValue)"
    }
}

extension Tile: Hashable {
    var hashValue: Int {
        return (String(position.x) + String(position.y) + String(describing: value)).hashValue
    }
    
    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        return lhs.position == rhs.position && lhs.value == rhs.value
    }
    
    
}
