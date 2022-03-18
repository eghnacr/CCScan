//
// Created by Egehan Acar on 14.03.2022.
//

import AVFoundation
import SwiftUI
import UIKit

enum CCScannerError: Error {
    case cameraCouldNotLoad
}

protocol CCScannerCameraViewDelegate {
    func didDetected(result: CCDetectResult)
    func didError(with: CCScannerError)
}

final class CCScannerCameraView: UIViewController {
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()

    private var captureOutput = AVCaptureVideoDataOutput()
    var detector: CCDetector?
    var output: ((CCDetectResult) -> Void)?
    var delegate: CCScannerCameraViewDelegate?
    

    override func loadView() {
        super.loadView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCaptureSession()
        self.captureSession.startRunning()
        self.detector = CCDetector(in: self.view.bounds)
    }

    private func setupCaptureSession() {
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
    }

    private func addCameraInput() {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.sessionPreset = device.supportsSessionPreset(.hd4K3840x2160) ? .hd4K3840x2160 : .hd1920x1080
        try? device.lockForConfiguration()
        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        if device.isFocusPointOfInterestSupported {
            // device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
        }
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        if device.isLowLightBoostSupported {
            device.automaticallyEnablesLowLightBoostWhenAvailable = true
        }
        if device.isTorchModeSupported(.auto) {
            // device.torchMode = .auto
        }
        device.unlockForConfiguration()

        self.captureSession.addInput(cameraInput)
    }

    private func addPreviewLayer() {
        self.view.layer.addSublayer(self.previewLayer)
    }

    private func addVideoOutput() {
        self.captureOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]

        self.captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.egehan.ccscanner.queue", qos: .userInteractive))
        self.captureSession.addOutput(self.captureOutput)
        guard let connection = self.captureOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported
        else {
            return
        }
        connection.videoOrientation = .portrait
    }
}

extension CCScannerCameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let detectedRectangle = detector?.detect(on: pixelBuffer)
        else {
            self.delegate?.didError(with: .cameraCouldNotLoad)
            return
        }
        
        let transformedRect = detectedRectangle.boundingBox.transformToUIKitRect(with: self.previewLayer.bounds)
        if transformedRect.orientation == .vertical {
            self.delegate?.didDetected(result: .vertical(transformedRect))
        } else {
            self.delegate?.didDetected(result: .horizontal(transformedRect))
        }
        
    }
}

extension CCScannerCameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CCScannerCameraView {
        return self
    }

    func updateUIViewController(_ uiViewController: CCScannerCameraView, context: Context) {}
}
