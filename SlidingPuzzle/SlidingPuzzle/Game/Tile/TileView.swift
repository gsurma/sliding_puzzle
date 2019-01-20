//
//  TileView.swift
//  SlidingPuzzle
//
//  Created by Grzegorz Surma on 04/03/2018.
//  Copyright © 2018 Grzegorz Surma. All rights reserved.
//

import Foundation
import UIKit

final class TileView: UIView {
    
    var valueLabel: UILabel!
    
    var position: Position
    
    init(position: Position, color: UIColor) {
        self.valueLabel = UILabel()
        self.valueLabel.textColor = UIColor.white
        self.valueLabel.textAlignment = .center
        
        self.position = position
        super.init(frame: CGRect.zero)
        backgroundColor = color
        
        addSubview(valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
