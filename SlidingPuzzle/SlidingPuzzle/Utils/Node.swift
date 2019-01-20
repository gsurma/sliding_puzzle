//
//  Node.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 10/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation

final class CostTranspositionTable {
    
    static let sharedInstance = CostTranspositionTable()
    var transpositionTable = [Node: Int]()
}

final class Node {
    
    let grid: [Tile]
    let boardManager: GameBoardManager
    let size: Int
    
    var previousMove: ShiftDirection? = nil
    var previousNode: Node? = nil
    
    var estimatedMinimumCost = Int.max
    
    var isSolution: Bool {
        return boardManager.getIsWinning()
    }
    
    lazy var cost: Int = {
        if let retrievedCost = CostTranspositionTable.sharedInstance.transpositionTable[self] as Int? {
            return retrievedCost
        } else {
            let calculatedCost = boardManager.getManhattanDistance()
            CostTranspositionTable.sharedInstance.transpositionTable[self] = calculatedCost
            return calculatedCost
        }
    }()
    
    init(grid: [Tile], size: Int) {
        self.grid = grid
        self.size = size
        self.boardManager = GameBoardManager(tiles: grid, size: size)
    }
}

extension Node: Hashable {
    var hashValue: Int {
        return Set(grid).hashValue
    }
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
