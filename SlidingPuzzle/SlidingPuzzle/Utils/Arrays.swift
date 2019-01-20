//
//  Arrays.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 05/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    func randomize() -> Array {
        return Array(Set(self))
    }
    
    func randomElement() -> Element? {
        guard !self.isEmpty else {
            return nil
        }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}
