//
//  CGRect+transform.swift
//  CCScan
//
//  Created by Egehan Acar on 15.03.2022.
//

import CoreGraphics

extension CGRect {
    func transformToUIKitRect(with rect: CGRect) -> CGRect {
        let transform = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -rect.height)
        let scale = CGAffineTransform
            .identity
            .scaledBy(x: rect.width, y: rect.height)

        return self.applying(scale).applying(transform)
    }
}
