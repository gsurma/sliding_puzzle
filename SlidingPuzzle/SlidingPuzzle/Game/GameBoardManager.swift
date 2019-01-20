//
//  GameBoardManager.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 09/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation
import UIKit

final class GameBoardManager {
    
    private var tiles: [Tile]
    private var size: Int
    
    init(tiles: [Tile], size: Int) {
        self.tiles = tiles
        self.size = size
    }
    
    func getGridCopy() -> [Tile] {
        var newTiles = [Tile]()
        for oldTile in tiles {
            newTiles.append(Tile(position: oldTile.position, value: oldTile.value, goalValue: oldTile.goalValue))
        }
        refreshNeighborTiles(tiles: newTiles)
        return newTiles
    }
    
    func getIsWinning() -> Bool {
        for tile in tiles where tile.value != tile.goalValue {
            return false
        }
        return true
    }
    
    func getManhattanDistance() -> Int {
        var manhattanDistance = 0
        for tile in tiles {
            if let goal = getTileForValue(value: tile.goalValue) as Tile? {
                manhattanDistance += countManhattanDistance(tileA: tile, tileB: goal)
            }
        }
        return manhattanDistance
    }
    
    func getBlankTile() -> Tile? {
        return tiles.filter { $0.value == 0 }.first
    }
    
    func shift(direction: ShiftDirection, speed: TimeInterval = 0.1, delegate: GameLogicManagerDelegate?, completionBlock: @escaping () -> Void) {
        if let blankTile = getBlankTile() as Tile? {
            var neighborToSwap: Tile?
            switch direction {
            case .up:
                neighborToSwap = blankTile.bottomTile
            case .down:
                neighborToSwap = blankTile.upTile
            case .left:
                neighborToSwap = blankTile.rightTile
            case .right:
                neighborToSwap = blankTile.leftTile
            }
            
            if let existingNeighborToSwap = neighborToSwap as Tile? {
                let firstTileValue = blankTile.value
                let secondTileValue = existingNeighborToSwap.value
                blankTile.value = secondTileValue
                existingNeighborToSwap.value = firstTileValue
                
                if let delegate = delegate as GameLogicManagerDelegate? {
                    delegate.gameLogicManagerDidSwapTiles(firstTile: blankTile, secondTile: existingNeighborToSwap, speed: speed, completionBlock: {
                        completionBlock()
                    })
                } else {
                    // AI
                    completionBlock()
                }
            } else {
                // Move not possible in current situation
                completionBlock()
            }
        }
    }
    
    func refreshNeighborTiles(tiles: [Tile]) {
        for tile in tiles {
            let up = Position(x: tile.position.x, y: tile.position.y - 1)
            tile.upTile = tileForPosition(position: up, tiles: tiles)
            
            let right = Position(x: tile.position.x + 1, y: tile.position.y)
            tile.rightTile = tileForPosition(position: right, tiles: tiles)
           
            let bottom = Position(x: tile.position.x, y: tile.position.y + 1)
            tile.bottomTile = tileForPosition(position: bottom, tiles: tiles)
            
            let left = Position(x: tile.position.x - 1, y: tile.position.y)
            tile.leftTile = tileForPosition(position: left, tiles: tiles)
        }
    }
    
    private func countManhattanDistance(tileA: Tile, tileB: Tile) -> Int {
        var manhattanDistance = 0
        manhattanDistance += abs(tileA.position.x-tileB.position.x)
        manhattanDistance += abs(tileA.position.y-tileB.position.y)
        return manhattanDistance
    }
    
    private func getTileForValue(value: Int) -> Tile? {
        return tiles.filter { $0.value == value }.first
    }
    
    private func tileForPosition(position: Position, tiles: [Tile]) -> Tile? {
        return tiles.filter({$0.position == position}).first
    }
}
