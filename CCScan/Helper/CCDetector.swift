//
//  CCDetector.swift
//  CCScan
//
//  Created by Egehan Acar on 14.03.2022.
//

import AVFoundation
import Vision

final class CCDetector {
    private let handler = VNSequenceRequestHandler()
    private let textRectangleRequest = VNDetectTextRectanglesRequest() // to check if the rectangle contains text
    private let rectangleRequest: VNDetectRectanglesRequest = {
        let request = VNDetectRectanglesRequest()
        //let aspectRatio = CCDimension.vertical.aspectRatio // Doesn't matter if it's horizontal or vertical
        //request.minimumAspectRatio = aspectRatio * 0.9
        //request.maximumAspectRatio = aspectRatio * 1.1
        //request.maximumObservations = 5
        request.minimumConfidence = 0.6
        return request
    }()

    func detect(on frame: CVImageBuffer) -> VNRectangleObservation? {
        do {
            try handler.perform([rectangleRequest, textRectangleRequest], on: frame)

            if
                let rect = rectangleRequest.results?.first,
                let texts = textRectangleRequest.results?.first,
                rect.boundingBox.contains(texts.boundingBox)
            {
                return rect
            }

        } catch {
            print(error)
        }
        return nil
    }
}
