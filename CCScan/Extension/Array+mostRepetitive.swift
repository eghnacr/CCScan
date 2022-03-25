//
//  Array+mostRepetitive.swift
//  CCScan
//
//  Created by Egehan Acar on 24.03.2022.
//

import Foundation

extension Array where Element: Comparable & Hashable {
    func mostRepetitive() -> Element? {
        var mostRepetitiveCount = 0
        var mostRepetitive: Element? = nil
        var countMap = [Element: Int]()
        
        self.forEach { element in
            if let elementCount = countMap[element] {
                countMap[element] = elementCount + 1
                if elementCount > mostRepetitiveCount {
                    mostRepetitiveCount = elementCount
                    mostRepetitive = element
                }
            } else {
                countMap[element] = 1
            }
        }
        
        return mostRepetitive
    }
}
