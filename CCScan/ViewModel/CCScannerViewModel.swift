//
//  CCScannerViewModel.swift
//  CCScan
//
//  Created by Egehan Acar on 22.03.2022.
//

import AVFoundation
import SwiftUI

final class CCScannerViewModel: NSObject, ObservableObject {
    @Published var strokeColor: Color = .red
    @Published var detectedFrame: CGRect = .zero
    @Published var cardOrientation: Orientation = .vertical
    @Published var ccResult: CCResult?

    private let ccDetector = CCDetector()
    private let ccReader = CCReader()

    var screenSize: CGSize?
    var interestArea: CGRect?

    var isReading = false

    func isCardInArea() -> Bool {
        if let interestArea = interestArea,
           interestArea.contains(detectedFrame)
        {
            return true
        }
        return false
    }

    func readCard(on pixelBuffer: CVImageBuffer) {
        isReading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let result = self?.ccReader.read(from: pixelBuffer) {
                DispatchQueue.main.async { [weak self] in
                    self?.ccResult = result
                }
            }
            self?.isReading = false
        }
    }

    func didDetected(result: CCDetectResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isReading { return }
            switch result {
            case .detected(let cgRect, let cvImageBuffer):
                self.detectedFrame = cgRect
                self.cardOrientation = cgRect.orientation
                if self.isCardInArea() {
                    self.strokeColor = .green
                    self.readCard(on: cvImageBuffer)
                } else {
                    self.strokeColor = .red
                }
            case .none:
                self.detectedFrame = .zero
                self.strokeColor = .red
            }
        }
    }

    func didTappedCreditCardText() {
        if let cardNo = ccResult?.cardNo {
            ccResult = ccReader.addCardNumberToStopWords(cardNo)
        }
    }

    func didTappedExpirationDateText() {
        if let date = ccResult?.expirationDate {
            ccResult = ccReader.addExpirationDateToStopWords(date)
        }
    }

    func didTappedNameText() {
        if let name = ccResult?.name {
            ccResult = ccReader.addNameToStopWords(name)
        }
    }
}

extension CCScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            !isReading,
            let screenSize = screenSize,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let detectedCCRectangle = ccDetector.detect(on: pixelBuffer)
        else {
            didDetected(result: .none)
            return
        }
        let w = CVPixelBufferGetWidth(pixelBuffer)
        let h = CVPixelBufferGetHeight(pixelBuffer)
        let size = CGSize(width: w, height: h)

        let transformedRect = detectedCCRectangle.boundingBox.transformToUIKitRect(with: screenSize)
        didDetected(result: .detected(transformedRect, pixelBuffer))
    }
}
