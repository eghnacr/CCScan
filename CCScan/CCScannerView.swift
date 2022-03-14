//
// Created by Egehan Acar on 14.03.2022.
//

import AVFoundation
import SwiftUI
import UIKit

final class CCScannerView: UIViewController {
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()
    private var captureOutput = AVCaptureVideoDataOutput()


    override func loadView() {
        self.view = UIView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCaptureSession()
        self.captureSession.startRunning()
    }

    private func setupCaptureSession() {
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
    }

    private func addCameraInput() {
        let device = AVCaptureDevice.default(for: .video)!
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }

    private func addPreviewLayer() {
        self.view.layer.addSublayer(self.previewLayer)
    }

    private func addVideoOutput() {
        self.captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        self.captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.egehan.ccscanner.queue"))
        self.captureSession.addOutput(self.captureOutput)
        guard let connection = self.captureOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
    }
}

extension CCScannerView: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

    }
}

extension CCScannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CCScannerView {
        CCScannerView()
    }

    func updateUIViewController(_ uiViewController: CCScannerView, context: Context) {
    }
}
