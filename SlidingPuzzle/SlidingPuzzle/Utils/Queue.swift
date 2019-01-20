//
//  Queue.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 09/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation

public struct Queue<T> {
    fileprivate var array = [T]()
    
    public var count: Int {
        return array.count
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: T? {
        return array.first
    }
}
