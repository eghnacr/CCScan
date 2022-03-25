//
//  OCR.swift
//  CCScan
//
//  Created by Egehan Acar on 23.03.2022.
//

import Vision

final class OCR {
    
    static let hand = VNSequenceRequestHandler()
    static let req = createRequest(level: .accurate)
    
    static func recognizeTexts(on image: CGImage,
                               _ recognitionLevel: VNRequestTextRecognitionLevel = .accurate) -> [VNRecognizedText]
    {
        let request = createRequest(level: recognitionLevel)
        let result = perform(on: image, with: request)
        //log(recognizedTexts: result)
        return result
    }

    private static func perform(on image: CGImage, with request: VNRecognizeTextRequest) -> [VNRecognizedText] {
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([request])
            guard let observations = request.results else {
                return []
            }
            return observations.compactMap { observation in
                observation.topCandidates(1).first
            }
        } catch {
            return []
        }
    }
    
    static func recognizeTexts(on pixelBuffer: CVPixelBuffer,
                               _ recognitionLevel: VNRequestTextRecognitionLevel = .accurate) -> [VNRecognizedText]
    {
        do {
            try hand.perform([req], on: pixelBuffer)
            guard let observation = req.results else {
                return []
            }
            return observation.compactMap { observation in
                observation.topCandidates(1).first
            }
        } catch {
            print(error)
            return []
        }
    }

    private static func createRequest(level recognitionLevel: VNRequestTextRecognitionLevel) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.usesLanguageCorrection = false
        request.recognitionLevel = recognitionLevel
        request.minimumTextHeight = 0.005
        request.revision = VNRecognizeTextRequestRevision2
        return request
    }

    private static func log(recognizedTexts: [VNRecognizedText]) {
        #if DEBUG
        var message = "================OCR================\n"
        recognizedTexts.forEach {
            message += "|-> \($0.string)\n"
        }
        message += "==================================="
        print(message)
        #endif
    }
}
