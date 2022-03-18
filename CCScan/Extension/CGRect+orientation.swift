//
//  CGRect+orientation.swift
//  CCScan
//
//  Created by Egehan Acar on 15.03.2022.
//

import CoreGraphics

enum Orientation {
    case horizontal
    case vertical
}

extension CGRect {
    
    var orientation: Orientation {
        if self.height / self.width > 1 {
            return .vertical
        }
        return .horizontal
    }
}
