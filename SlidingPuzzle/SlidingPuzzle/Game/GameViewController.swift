//
//  GameViewController.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 04/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

final class GameViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var aiSolverButton: UIButton!
    @IBOutlet weak var movesCounterLabel: UIBarButtonItem!
    @IBOutlet weak var blurMask: UIVisualEffectView!
    @IBOutlet weak var boardView: GameBoardView!
    private var titleButton: UIButton!
    private var renderer: GameBoardRenderer!
    private let gameManager = GameLogicManager()
    private var isShuffling = false
    private var isAISolving = false
    private var size: Int = defaultBoardDimmension {
        didSet {
            titleButton.setTitle("\(size)x\(size)", for: .normal)
            configureForSize(size: size)
        }
    }
    private var moves = 0 {
        didSet {
            movesCounterLabel.title = String(moves)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleButton =  UIButton(type: .system)
        titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleButton.tintColor = UIColor(red: 23/255, green: 23/255, blue: 56/255, alpha: 1.0)
        titleButton.addTarget(self, action: #selector(self.titleAction), for: .touchUpInside)
        navigationItem.titleView = titleButton
        
        boardView.delegate = self
        gameManager.delegate = self
        size = max(defaultBoardDimmension, UserDefaults.standard.getHighestCompletedLevel() == finalLevel ? finalLevel : UserDefaults.standard.getHighestCompletedLevel() + 1)
        
        gameManager.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.hasSeenTutorial() {
            tutorialAction(self)
        }
    }
    
    private func configureForSize(size: Int) {
        aiSolverButton.isHidden = size != 3
        renderer = GameBoardRenderer(boardView: boardView, size: size)
        gameManager.size = size
    }
    
    @objc func titleAction(button: UIButton) {
        guard !isShuffling else {
            return
        }
        let levelSelectionMenu = UIAlertController(title: "Select board size", message: "", preferredStyle: .actionSheet)
        let lowerBound = Int(defaultBoardDimmension)
        let availableLevels = max(lowerBound, UserDefaults.standard.getHighestCompletedLevel() + 1)
        let upperBound = min(availableLevels, finalLevel)
        guard lowerBound < upperBound else {
            return
        }
        for i in lowerBound...upperBound {
            let levelAction = UIAlertAction(title: "\(i)x\(i)", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.size = i
                self.restartAction(nil)
            })
            levelSelectionMenu.addAction(levelAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        levelSelectionMenu.addAction(cancelAction)
        
        levelSelectionMenu.popoverPresentationController?.sourceView = titleButton
        levelSelectionMenu.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        levelSelectionMenu.popoverPresentationController?.sourceRect = CGRect(x: titleButton.frame.midX, y: 0, width: 0, height: 0)
        present(levelSelectionMenu, animated: true, completion: nil)
    }

    @IBAction func tutorialAction(_ sender: Any) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func restartAction(_ sender: Any?) {
        guard !isShuffling else {
            return
        }
        spinner.isHidden = true
        moves = 0
        gameManager.start()
    }

    @IBAction func aiFinish(_ sender: Any) {
        guard !isAISolving else {
            return
        }
        gameManager.performAIFinish()
        isAISolving = true
        spinner.isHidden = false
    }
    
    private func toggleBlurMask(show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.blurMask.alpha = show ? 0.5 : 0.0
        }
    }
    
    private func handleGameOver() {
        renderer.presentWinningState()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + popupDelay, execute: {
            UserDefaults.standard.saveHighScore(moves: self.moves, size: self.size)
            if self.size == finalLevel {
                 HUD.flash(.labeledSuccess(title: "Congratulations! 🏆", subtitle: "You solved the final puzzle in \(self.moves) moves"), delay: popupDelay, completion: { (bool) in
                    self.restartAction(nil)
                })
            } else {
                self.size += 1
                HUD.flash(.labeledSuccess(title: "Well done! 🏅", subtitle: "You solved this puzzle in \(self.moves) moves"), delay: popupDelay, completion: { (bool) in
                    self.restartAction(nil)
                })
            }
        })
    }
}

extension GameViewController: GameBoardViewDelegate {
    
    func gameBoardView(view: GameBoardView, didSwipeInDirection direction: ShiftDirection) {
        moves += 1
        gameManager.shift(direction: direction, completionBlock: {
            if self.gameManager.checkIfGameOver() {
                self.handleGameOver()
            }
        })
    }
}

extension GameViewController: GameLogicManagerDelegate {
    
    func gameLogicManagerDidAISolve(moves: Int) {
        isAISolving = false
        if self.gameManager.checkIfGameOver() {
            self.spinner.isHidden = true
            self.renderer.presentWinningState()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + popupDelay/2, execute: {
                HUD.flash(.labeledSuccess(title: "AI solved it!", subtitle: "in \(moves) moves"), delay: popupDelay, completion: { (bool) in
                    self.restartAction(nil)
                })
            })
        }
    }
    
    func gameLogicManagerDidEnableInteractions() {
        boardView.isUserInteractionEnabled = true
    }
    
    func gameLogicManagerDidDisableInteractions() {
        boardView.isUserInteractionEnabled = false
    }
    
    func gameLogicManagerDidStartShuffle() {
        isShuffling = true
        toggleBlurMask(show: true)
    }
    
    func gameLogicManagerDidEndShuffle() {
        isShuffling = false
        toggleBlurMask(show: false)
    }
    
    func gameLogicManagerDidSetTiles(tiles: [Tile]) {
        renderer.setTiles(tiles: tiles)
    }
    
    func gameLogicManagerDidSwapTiles(firstTile: Tile, secondTile: Tile, speed: TimeInterval, completionBlock: @escaping () -> Void) {
        renderer.swapTiles(firstTile: firstTile, secondTile: secondTile, speed: speed, completionBlock: completionBlock)
    }
}
