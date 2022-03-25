//
// Created by Egehan Acar on 14.03.2022.
//

import AVFoundation
import SwiftUI
import UIKit

final class CCScannerCameraView: UIViewController {
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .currentDeviceOrientation
        return previewLayer
    }()

    private var captureOutput = AVCaptureVideoDataOutput()
    var sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?

    override func loadView() {
        super.loadView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        previewLayer.connection?.videoOrientation = .currentDeviceOrientation
        addVideoOutput()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func startCapturing() {
        self.setupCaptureSession()
        self.captureSession.startRunning()
    }
    
    func stopCapturing() {
        self.captureSession.stopRunning()
    }

    private func setupCaptureSession() {
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
    }

    private func addCameraInput() {
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let cameraInput = try? AVCaptureDeviceInput(device: device)
        else {
            return
        }

        self.captureSession.sessionPreset = device.supportsSessionPreset(.hd4K3840x2160) ? .hd4K3840x2160 : .hd1920x1080
        try? device.lockForConfiguration()
        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
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
        guard let sampleBufferDelegate = sampleBufferDelegate else {
            return
        }

        self.captureOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]

        self.captureOutput.setSampleBufferDelegate(sampleBufferDelegate, queue: DispatchQueue(label: "com.egehan.ccscanner.queue", qos: .userInteractive))
        self.captureSession.addOutput(self.captureOutput)
        guard let connection = self.captureOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported
        else {
            return
        }
  
        connection.videoOrientation = .currentDeviceOrientation
    }
}

extension CCScannerCameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CCScannerCameraView {
        return self
    }

    func updateUIViewController(_ uiViewController: CCScannerCameraView, context: Context) {}
}
