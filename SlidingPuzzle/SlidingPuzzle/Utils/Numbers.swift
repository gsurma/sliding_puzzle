//
//  Numbers.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 06/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation

extension Date {
    
    func countElapsedTime() -> Int {
        return  Int(round(Date().timeIntervalSince1970 - self.timeIntervalSince1970))
    }
}
