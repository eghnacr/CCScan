//
//  OCR2.swift
//  CCScan
//
//  Created by Egehan Acar on 28.03.2022.
//

import Vision

final class OCR {
    private let handler = VNSequenceRequestHandler()
    private let request: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest()
        request.usesLanguageCorrection = false
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 0.005
        request.revision = VNRecognizeTextRequestRevision2
        return request
    }()

    func recognizeTexts(on pixelBuffer: CVPixelBuffer) -> [VNRecognizedText] {
        do {
            try handler.perform([request], on: pixelBuffer)
            if let observations = request.results {
                let result = observations.compactMap { observation in
                    observation.topCandidates(1).first
                }
                log(recognizedTexts: result)
                return result
            }
        } catch {
            print(error)
        }
        return []
    }
    
    private func log(recognizedTexts: [VNRecognizedText]) {
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
