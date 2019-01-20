//
//  AI.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 09/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation

final class AI {
    
    var startingNode: Node
    
    init(grid: [Tile], size: Int) {
        self.startingNode = Node(grid: grid,
                                 size: size)
    }
    
    func getWinningMoves() -> [ShiftDirection] {
         return idaWinningMoves()
        //return dfsWinningMoves()
        //return bfsWinningMoves()
    }
    
    func idaWinningMoves() -> [ShiftDirection] {
        var threshold = startingNode.cost
        var node = startingNode
        while !node.isSolution {
            node = ida(node: startingNode, cost: 0, threshold: threshold)
            if node.isSolution == false {
                threshold = node.estimatedMinimumCost
            }
        }
        return recreatePathFrom(node: node)
    }
    
    func ida(node: Node, cost: Int, threshold: Int) -> Node {
        let estimatedCost = node.cost + cost
        if node.isSolution
            || estimatedCost > threshold {
            node.estimatedMinimumCost = estimatedCost
            return node
        }
        var minimumCost = Int.max
        if let blankTile = node.boardManager.getBlankTile() as Tile? {
            for move in getPossibleMovesWithoutReversals(node: node, blankTile: blankTile) {
                let childNode = getChildOfNodeAndMove(node: node, move: move)
                let childIda = ida(node: childNode, cost: cost + 1, threshold: threshold)
                if childIda.isSolution {
                    return childIda
                }
                if childIda.estimatedMinimumCost < minimumCost {
                    minimumCost = childIda.estimatedMinimumCost
                }
            }
        }
        node.estimatedMinimumCost = minimumCost
        return node
    }

    func bfsWinningMoves() -> [ShiftDirection] {
        var queue = Queue<Node>()
        queue.enqueue(startingNode)
        var visitedNodes = Set<Node>()
        while let current = queue.dequeue() {
            if current.boardManager.getIsWinning() {
                return recreatePathFrom(node: current)
            }
            if let blankTile = current.boardManager.getBlankTile() as Tile! {
                for move in blankTile.possibleMoveDirections {
                    let childNode = getChildOfNodeAndMove(node: current, move: move)
                    if !visitedNodes.contains(childNode) {
                        visitedNodes.insert(current)
                        queue.enqueue(childNode)
                    }
                }
            }
        }
        return []
    }
    
    func dfsWinningMoves() -> [ShiftDirection] {
        var stack = Stack<Node>()
        var visitedNodes = Set<Node>()
        stack.push(startingNode)
        while let current = stack.pop() {
            if current.boardManager.getIsWinning() {
                 return recreatePathFrom(node: current)
            }
            if let blankTile = current.boardManager.getBlankTile() as Tile? {
                for move in blankTile.possibleMoveDirections {
                    let childNode = getChildOfNodeAndMove(node: current, move: move)
                    if !visitedNodes.contains(childNode) {
                        visitedNodes.insert(current)
                        stack.push(childNode)
                    }
                }
            }
        }
        return []
    }
    
    private func getPossibleMovesWithoutReversals(node: Node, blankTile: Tile) -> [ShiftDirection] {
        let possibleMoves = blankTile.possibleMoveDirections
        if let previousMove = node.previousMove as ShiftDirection? {
            var reverseMove: ShiftDirection!
            switch previousMove {
            case .up:
                reverseMove = .down
            case .down:
                reverseMove = .up
            case .left:
                reverseMove = .right
            case .right:
                reverseMove = .left
            }
            return possibleMoves.filter { $0 != reverseMove }
        }
        return possibleMoves
    }
    
    private func recreatePathFrom(node: Node) -> [ShiftDirection] {
        var moves = [ShiftDirection]()
        func getMovesFrom(node: Node) -> [ShiftDirection] {
            if let previousMove = node.previousMove as ShiftDirection?, let previousNode = node.previousNode as Node? {
                moves.append(previousMove)
                return getMovesFrom(node: previousNode)
            } else {
                return moves
            }
        }
        return getMovesFrom(node: node).reversed()
    }
    
    private func getChildOfNodeAndMove(node: Node, move: ShiftDirection) -> Node {
        let childNode = Node(grid: node.boardManager.getGridCopy(), size: node.size)
        childNode.boardManager.shift(direction: move, delegate: nil, completionBlock: { })
        childNode.previousMove = move
        childNode.previousNode = node
        return childNode
    }
}
