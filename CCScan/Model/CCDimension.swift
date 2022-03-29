//
//  CCDimension.swift
//  CCScan
//
//  Created by Egehan Acar on 28.03.2022.
//

import Foundation

enum CCDimension {
    case vertical
    case horizontal

    var width: Float {
        switch self {
        case .vertical: return 53.98
        case .horizontal: return 85.6
        }
    }

    var height: Float {
        switch self {
        case .vertical: return 85.6
        case .horizontal: return 53.98
        }
    }

    var aspectRatio: Float {
        return height / width // Vision aspect ratio based on heigth / width.
    }
}
