//
//  UserDefaults.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 06/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Key: String {
        case HighScore = "HighScore"
        case Level = "Level"
        case HasSeenTutorial = "HasSeenTutorial"
    }
    
    func hasSeenTutorial() -> Bool {
        return UserDefaults.standard.bool(forKey: Key.HasSeenTutorial.rawValue)
    }
    
    func setHasSeenTutorial() {
        UserDefaults.standard.set(true, forKey: Key.HasSeenTutorial.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    private func saveScoreForLevel(level: Int, score: Int) {
        let scoreForLevel = getScoreForLevel(level: level)
        if score < scoreForLevel || scoreForLevel == 0 {
            UserDefaults.standard.set(score, forKey: Key.Level.rawValue+String(level))
            UserDefaults.standard.synchronize()
        }
    }
    
    private func getScoreForLevel(level:Int) -> Int {
        return UserDefaults.standard.integer(forKey: Key.Level.rawValue+String(level))
    }
    
    func getHighestCompletedLevel() -> Int {
        return UserDefaults.standard.integer(forKey: Key.HighScore.rawValue)
    }
    
    private func saveHighestCompletedLevel(score: Int) {
        if score > getHighestCompletedLevel() {
            UserDefaults.standard.set(score, forKey: Key.HighScore.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    func saveHighScore(moves: Int, size: Int) {
        saveScoreForLevel(level: size, score: moves)
        saveHighestCompletedLevel(score: size)
    }
}
