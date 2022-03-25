//
//  CGRect+transform.swift
//  CCScan
//
//  Created by Egehan Acar on 15.03.2022.
//

import CoreGraphics

extension CGRect {
    func transformToUIKitRect(with size: CGSize) -> CGRect {
        let x = (size.width * self.origin.x)
        let y = (size.height * (1 - self.origin.y  - self.height))
        let width = size.width * self.width
        let height = size.height * self.height
        return CGRect(x: x,
                      y: y,
                      width: width,
                      height: height)
    }
}
