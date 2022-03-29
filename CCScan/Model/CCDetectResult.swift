//
//  CCDetectResult.swift
//  CCScan
//
//  Created by Egehan Acar on 28.03.2022.
//

import AVFoundation

enum CCDetectResult {
    case detected(CGRect, CVImageBuffer)
    case none
}
