//
//  ContentView.swift
//  CCScan
//
//  Created by Egehan Acar on 14.03.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            ccScannerCameraView(delegate: viewModel)
            ZStack {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(.black)
                        .frame(width: proxy.size.width,
                               height: proxy.size.height)
                        .opacity(0.7)
                    InterestArea(strokeColor: $viewModel.strokeColor,
                                 orientation: $viewModel.cardOrientation)
                }
            }.compositingGroup()
            DetectedRectangle(frame: $viewModel.detectedFrame)

        }.ignoresSafeArea()
    }

    private func ccScannerCameraView(delegate: CCScannerCameraViewDelegate) -> some View {
        #if targetEnvironment(simulator)
        return Image("camera.place.holder")
            .resizable()
        #else
        let ccScannerCameraView = CCScannerCameraView()
        ccScannerCameraView.delegate = delegate
        return ccScannerCameraView
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    final class ViewModel: ObservableObject, CCScannerCameraViewDelegate {
        @Published var ccFrame: CGRect = .zero
        @Published var strokeColor: Color = .red
        @Published var detectedFrame: CGRect = .zero
        @Published var cardOrientation: Orientation = .vertical

        func didDetected(result: CCDetectResult) {
            DispatchQueue.main.async { [weak self] in
                withAnimation(.linear) {
                    switch result {
                    case .vertical(let cgRect):
                        self?.detectedFrame = cgRect
                        self?.cardOrientation = .vertical
                    case .horizontal(let cgRect):
                        self?.detectedFrame = cgRect
                        self?.cardOrientation = .horizontal
                    case .none:
                        self?.detectedFrame = .zero
                    }
                }
            }
        }

        func didError(with: CCScannerError) {}
    }
}

struct InterestArea: View {
    @Binding var strokeColor: Color
    @Binding var orientation: Orientation

    let cornerRadius: CGFloat = 10
//    var body: some View {
//        Rectangle()
//            .frame(width: frame.width, height: frame.height)
//            .cornerRadius(cornerRadius)
//            .blendMode(.destinationOut)
//            .overlay(
//                RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(strokeColor, lineWidth: 3)
//            )
//            .position(x: frame.origin.x, y: frame.origin.y)
//    }

    var body: some View {
        GeometryReader { proxy in
            let cc: CCDimension = orientation == .vertical ? CCDimension.vertical : CCDimension.horizontal
            let ccHeight = CGFloat(cc.height)
            let ccWidth = CGFloat(cc.width)
            let width = proxy.size.width * (orientation == .vertical ? 0.65 : 0.9)
            let height = ccHeight * (width / ccWidth)
            let x = proxy.size.width / 2
            let y = (height / 2) + (proxy.size.height * 0.05)
            Rectangle()
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)
                .blendMode(.destinationOut)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(strokeColor, lineWidth: 3)
                )
                .position(x: x, y: y)
        }
    }
}

struct DetectedRectangle: View {
    @Binding var frame: CGRect

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.yellow, lineWidth: 2)
            .frame(width: frame.width, height: frame.height)
            .position(x: frame.midX, y: frame.midY)
    }
}
