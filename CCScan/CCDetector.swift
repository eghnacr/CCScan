//
//  CCDetector.swift
//  CCScan
//
//  Created by Egehan Acar on 14.03.2022.
//

import Vision

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

enum CCDetectResult {
    case vertical(CGRect)
    case horizontal(CGRect)
    case none
}

final class CCDetector {
    private let rectangleRequest: VNDetectRectanglesRequest
    private let textRectangleRequest: VNDetectTextRectanglesRequest // to check if the rectangle contains text
    private let handler: VNSequenceRequestHandler

    init(in layer: CGRect) {
        rectangleRequest = Self.createRectangleRequest()
        textRectangleRequest = VNDetectTextRectanglesRequest()
        handler = VNSequenceRequestHandler()
    }

    func detect(on frame: CVImageBuffer) -> VNRectangleObservation? {
        do {
            try handler.perform([rectangleRequest, textRectangleRequest], on: frame)

            if
                let rect = rectangleRequest.results?.first,
                let texts = textRectangleRequest.results?.first,
                rect.boundingBox.contains(texts.boundingBox)
            {
                print(rect)
                return rect
            }
        
        } catch {
            print(error)
        }
        return nil
    }
    
    private func isVertical(_ rect: CGRect) -> Bool {
        return rect.height / rect.width > 1
    }

    private static func createRectangleRequest() -> VNDetectRectanglesRequest {
        let request = VNDetectRectanglesRequest()
        let aspectRatio = CCDimension.vertical.aspectRatio // Doesn't matter if it's horizontal or vertical
        request.maximumObservations = 5
        request.minimumConfidence = 0.59
        request.minimumAspectRatio = aspectRatio * 0.9
        request.maximumAspectRatio = aspectRatio * 1.1
        return request
    }
}
