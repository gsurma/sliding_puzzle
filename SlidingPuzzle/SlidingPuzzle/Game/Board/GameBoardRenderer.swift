//
//  GameBoardRenderer.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 04/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import UIKit

final class GameBoardRenderer {
    
    private weak var boardView: GameBoardView?
    private var tileViews = [TileView]()
    private var size: CGFloat
    
    init(boardView: GameBoardView, size: Int) {
        boardView.subviews.forEach { $0.removeFromSuperview() }
        self.boardView = boardView
        self.size = CGFloat(size)
    }
    
    func setTiles(tiles: [Tile]) {
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll(keepingCapacity: true)
        tiles.forEach { addTile(tile: $0) }
    }
    
    private func addTile(tile: Tile) {
        let tileView = TileView(position: tile.position,
                                color: colorForTile(tile: tile))
        tileView.center = centerForTile(position: tile.position)
        tileView.alpha = 0.0
        boardView!.addSubview(tileView)
        
        var value = ""
        if let tileValue = tile.value as Int?, tileValue != 0 {
            value = "\(tileValue)"
        }
        
        var bounds = tileView.bounds
        bounds.size = tileSize
        tileView.bounds = bounds
        tileView.valueLabel.text = value
        tileView.valueLabel.frame = bounds
        tileView.valueLabel.font = UIFont.boldSystemFont(ofSize: tileSize.width/2)
        UIView.animate(withDuration: 0.2, animations: {
            tileView.alpha = 1.0
        }) { _ in }
        
        tileViews.append(tileView)
    }
    
    func swapTiles(firstTile: Tile, secondTile: Tile, speed: TimeInterval, completionBlock: @escaping () -> Void) {
        if let firstTileView = tileViews.filter({$0.position == firstTile.position}).first as TileView?,
            let secondTileView = tileViews.filter({$0.position == secondTile.position}).first as TileView? {
            UIView.animate(withDuration: speed, animations: {
                firstTileView.center = self.centerForTile(position: secondTile.position)
                secondTileView.center = self.centerForTile(position: firstTile.position)
            }) { _ in
                firstTileView.position = secondTile.position
                secondTileView.position = firstTile.position
                completionBlock()
            }
        }
    }
    
    func presentWinningState() {
        for tileView in tileViews {
            if let currentColor = tileView.backgroundColor as UIColor? {
                UIView.animate(withDuration: 0.2, animations: {
                    tileView.backgroundColor = currentColor.darker()
                })
            }
            tileView.isUserInteractionEnabled = false
        }
    }
    
    private func colorForTile(tile: Tile) -> UIColor {
        if tile.value == 0 {
            return .clear
        }
        switch size {
        case 3:
            return UIColor(rgb: 0xF17D80)
        case 4:
            return UIColor(rgb: 0x956D89)
        case 5:
            return UIColor(rgb: 0x385E92)
        case 6:
            return UIColor(rgb: 0x66A5AA)
        default:
            return UIColor(rgb: 0x354458)
        }
    }
    
    private func centerForTile(position: Position) -> CGPoint {
        let x = (offset * CGFloat(position.x)) + (tileSize.width * CGFloat(position.x)) + (tileSize.width / 2.0) + offset
        let y = (offset * CGFloat(position.y)) + (tileSize.height * CGFloat(position.y)) + (tileSize.height / 2.0) + offset
        return CGPoint(x: x, y: y)
    }
    
    private var offset: CGFloat {
        return 1.5
    }
    
    private var tileSize: CGSize {
        let edge = (defaultBoardSize - ((size+CGFloat(1))*offset))/size
        return CGSize(width: edge, height: edge)
    }
}
