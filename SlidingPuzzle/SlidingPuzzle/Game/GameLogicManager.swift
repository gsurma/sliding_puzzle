//
//  GameLogicManager.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 04/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation
import UIKit

protocol GameLogicManagerDelegate {
    func gameLogicManagerDidAISolve(moves: Int)
    func gameLogicManagerDidEnableInteractions()
    func gameLogicManagerDidDisableInteractions()
    func gameLogicManagerDidStartShuffle()
    func gameLogicManagerDidEndShuffle()
    func gameLogicManagerDidSetTiles(tiles: [Tile])
    func gameLogicManagerDidSwapTiles(firstTile: Tile, secondTile: Tile, speed: TimeInterval, completionBlock: @escaping () -> Void)
}

final class GameLogicManager {
    
    var delegate: GameLogicManagerDelegate?
    var size: Int = defaultBoardDimmension
    var moveEnabled = true
    var boardManager: GameBoardManager?
    private var tiles = [Tile]()
    
    func start() {
        prepare()
        shuffleInitialTiles()
    }
    
    func shift(direction: ShiftDirection, speed: TimeInterval = 0.1, completionBlock: @escaping () -> Void) {
        boardManager?.shift(direction: direction, speed: speed, delegate: delegate) {
            completionBlock()
        }
    }
    
    func performAIFinish() {
        delegate?.gameLogicManagerDidDisableInteractions()
        DispatchQueue.global(qos: .background).async { [weak self] () -> Void in
            guard let strongSelf = self else { return }
            let startTime = Date().timeIntervalSince1970
            let winningMoves = AI(grid: strongSelf.getGridCopy(), size: strongSelf.size).getWinningMoves()
            let aiTime = Date().timeIntervalSince1970 - startTime
            print("Calculated winning sequence of \(winningMoves.count) in \(aiTime)")
            DispatchQueue.main.async { () -> Void in
                strongSelf.performAIMoves(moves: winningMoves) {
                    strongSelf.delegate?.gameLogicManagerDidEnableInteractions()
                    strongSelf.delegate?.gameLogicManagerDidAISolve(moves: winningMoves.count)
                }
            }
        }
    }
    
    func checkIfGameOver() -> Bool {
        return boardManager?.getIsWinning() ?? false
    }
    
    private func getGridCopy() -> [Tile] {
        return boardManager?.getGridCopy() ?? []
    }
    
    private func prepare() {
        tiles = [Tile]()
        for y in 0..<size {
            for x in 0..<size {
                var goalValue = tiles.count + 1
                var value = tiles.count + 1
                if tiles.count == (size*size) - 1 {
                    goalValue = 0
                    value = 0
                }
                let tile = Tile(position: Position(x: x, y: y),
                                value: value,
                                goalValue: goalValue)
                tiles.append(tile)
            }
        }
        
        boardManager = GameBoardManager(tiles: tiles, size: size)
        boardManager?.refreshNeighborTiles(tiles: tiles)
        delegate?.gameLogicManagerDidSetTiles(tiles: tiles)
    }
    
    private func shuffleInitialTiles() {
        var moves = [ShiftDirection]()
        let possibleMoves: [ShiftDirection] = [.up, .down, .left, .right]
        for _ in 0..<size*60 {
            let randomMove = possibleMoves.randomElement()!
            moves.append(randomMove)
        }
        
        delegate?.gameLogicManagerDidStartShuffle()
        performAIMoves(moves: moves, speed: 0.0001) {
            self.delegate?.gameLogicManagerDidEndShuffle()
        }
    }
    
    private func performAIMoves(moves: [ShiftDirection], speed: TimeInterval = 0.1, completionBlock: @escaping () -> Void) {
        var movesQueue = Queue<ShiftDirection>()
        moves.forEach { movesQueue.enqueue($0) }
        func moveIfPossible() {
            if let moveToPerform = movesQueue.dequeue() as ShiftDirection? {
                shift(direction: moveToPerform, speed: speed, completionBlock: {
                    moveIfPossible()
                })
            } else {
                delegate?.gameLogicManagerDidEnableInteractions()
                completionBlock()
            }
        }
        delegate?.gameLogicManagerDidDisableInteractions()
        moveIfPossible()
    }
}
