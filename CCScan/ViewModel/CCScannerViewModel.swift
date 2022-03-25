//
//  CCScannerViewModel.swift
//  CCScan
//
//  Created by Egehan Acar on 22.03.2022.
//

import AVFoundation
import SwiftUI

extension UIImage {
    func cropToRect(rect: CGRect) -> UIImage? {
        var scale = rect.width/self.size.width
        scale = self.size.height * scale < rect.height ? rect.height/self.size.height : scale

        let croppedImsize = CGSize(width: rect.width/scale, height: rect.height/scale)
        let croppedImrect = CGRect(origin: CGPoint(x: (self.size.width-croppedImsize.width)/2.0,
                                                   y: (self.size.height-croppedImsize.height)/2.0),
                                   size: croppedImsize)
        UIGraphicsBeginImageContextWithOptions(croppedImsize, true, 0)
        self.draw(at: CGPoint(x: -croppedImrect.origin.x, y: -croppedImrect.origin.y))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}

final class CCScannerViewModel: NSObject, ObservableObject {
    @Published var strokeColor: Color = .red
    @Published var detectedFrame: CGRect = .zero
    @Published var cardOrientation: Orientation = .vertical

    @Published var ccResult: CCResult?

    let ccDetector: CCDetector
    let ccReader: CCReader
    let isDetectedFrameVisible: Bool

    var screenSize: CGSize?
    var interestArea: CGRect?

    var isReading = false

    override init() {
        #if DEBUG
            self.isDetectedFrameVisible = true
        #else
            self.isDetectedFrameVisible = false
        #endif
        self.ccDetector = CCDetector()
        self.ccReader = CCReader()
    }

    func isCardInArea() -> Bool {
        if let interestArea = interestArea,
           interestArea.contains(detectedFrame)
        {
            return true
        }
        return false
    }

    func readCard(on pixelBuffer: CVImageBuffer) {
        if self.isReading { return }
        self.isReading = true
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            return
        }

        let uiImage = UIImage(cgImage: cgImage)
        if let result = ccReader.read(from: pixelBuffer) {
            DispatchQueue.main.async {
                self.ccResult = result
            }
        }
        // UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(self.didSaved), nil)
        self.isReading = false
    }

    @objc func didSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)

        } else {
            print("Success")
        }
    }

    func didDetected(result: CCDetectResult) {
//        if self.isReading {
//            return
//        }
        DispatchQueue.main.async {
            switch result {
            case .detected(let cgRect, let pixelBuffer):
                self.detectedFrame = cgRect
                self.cardOrientation = cgRect.orientation == .vertical ? .vertical : .horizontal
                if self.isCardInArea() {
                    self.strokeColor = .green
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.readCard(on: pixelBuffer)
                    }
                } else {
                    self.strokeColor = .red
                }
            case .none:
                self.detectedFrame = .zero
                self.strokeColor = .red
            }
        }
    }

    func didTappedDone() {
        print("didTappedDone")
    }

    func didTappedCreditCardText() {
        if let cardNo = self.ccResult?.cardNo {
            self.ccResult = self.ccReader.addCardNumberToStopWords(cardNo)
        }
    }

    func didTappedExpirationDateText() {
        if let date = self.ccResult?.expirationDate {
            self.ccResult = self.ccReader.addExpirationDateToStopWords(date)
        }
    }

    func didTappedNameText() {
        if let name = self.ccResult?.name {
            self.ccResult = self.ccReader.addNameToStopWords(name)
        }
    }
}

extension CCScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            let screenSize = screenSize,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let detectedCCRectangle = ccDetector.detect(on: pixelBuffer)
        else {
            self.didDetected(result: .none)
            return
        }

        let transformedRect = detectedCCRectangle.boundingBox.transformToUIKitRect(with: screenSize)
        self.didDetected(result: .detected(transformedRect, pixelBuffer))
    }
}
