//
//  CCScannerView2.swift
//  CCScan
//
//  Created by Egehan Acar on 24.03.2022.
//

import SwiftUI

struct CCScannerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: CCScannerViewModel

    private let cameraView = CCScannerCameraView()
    private let completionHandler: (CCResult) -> Void

    init(viewModel: CCScannerViewModel = .init(), _ completionHandler: @escaping (CCResult) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.completionHandler = completionHandler
    }

    var body: some View {
        GeometryReader { screen in
            ZStack {
                #if targetEnvironment(simulator)
                Image("camera.place.holder")
                    .resizable()
                #else
                cameraView
                    .onAppear {
                        cameraView.sampleBufferDelegate = viewModel
                        viewModel.screenSize = screen.size
                        cameraView.startCapturing()
                    }
                    .onDisappear {
                        cameraView.stopCapturing()
                    }
                #endif

                ZStack {
                    blurredLayer
                    VStack {
                        interestArea
                        Spacer()
                        infoScreen
                        doneButton
                    }
                }
                .compositingGroup()
                #if DEBUG
                detectedRectangle
                #endif
            }
        }
        .ignoresSafeArea()
    }

    // MARK: Info Screen

    private var infoScreen: some View {
        VStack {
            Text("Please center your card in the space above.")
                .foregroundColor(.white)
                .font(.footnote)
                .padding(1)
            Text("You can change the incorrectly read data by tapping on it.")
                .foregroundColor(.white)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(1)

            Text(viewModel.ccResult?.cardNo ?? "#### #### #### ####")
                .foregroundColor(.white)
                .font(.title)
                .padding(3)
                .onTapGesture {
                    viewModel.didTappedCreditCardText()
                }
            HStack {
                Text(viewModel.ccResult?.name ?? "NAME SURNAME")
                    .foregroundColor(.white)
                    .font(.title2)
                    .onTapGesture {
                        viewModel.didTappedNameText()
                    }
                Spacer()
                Text(viewModel.ccResult?.expirationDate ?? "MM/YY")
                    .foregroundColor(.white)
                    .font(.title2)
                    .onTapGesture {
                        viewModel.didTappedExpirationDateText()
                    }
            }
        }
        .frame(maxWidth: 400)
        .padding([.leading, .trailing])
        .offset(x: 0, y: -20)
    }

    private var doneButton: some View {
        Button {
            if let ccResult = self.viewModel.ccResult {
                self.completionHandler(ccResult)
            }
            self.dismiss()
        } label: {
            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 300, height: 50)
        .background(.red)
        .cornerRadius(10)
        .padding([.leading, .trailing, .bottom])
        .offset(x: 0, y: -20)
    }

    // MARK: Interest Area

    private var interestArea: some View {
        GeometryReader { proxy in
            var rect = calculateInteresAreaRectangle(for: proxy.size)
            Rectangle()
                .frame(width: rect.width,
                       height: rect.height)
                .cornerRadius(10)
                .blendMode(.destinationOut)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.strokeColor,
                                lineWidth: 3)
                )
                .position(x: rect.midX, y: rect.midY)
                .onChange(of: viewModel.cardOrientation) { _ in
                    rect = calculateInteresAreaRectangle(for: proxy.size)
                }
        }
    }

    private var blurredLayer: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(.black)
                .frame(width: proxy.size.width,
                       height: proxy.size.height)
                .opacity(0.5)

            Rectangle()
                .frame(width: proxy.size.width,
                       height: proxy.size.height)
                .background(.ultraThinMaterial)
        }
    }

    private func calculateInteresAreaRectangle(for size: CGSize) -> CGRect {
        let ccDimension: CCDimension = viewModel.cardOrientation == .vertical ? .vertical : .horizontal
        let ccHeight = CGFloat(ccDimension.height)
        let ccWidth = CGFloat(ccDimension.width)
        let width: CGFloat
        if ccDimension == .vertical { // to limit max width for iPad.
            width = min(size.width * 0.65, 300)
        } else {
            width = min(size.width * 0.9, 550)
        }
        let height = ccHeight * (width / ccWidth)
        let x = (size.width / 2) - (width / 2)
        let y = (height / 2) + (size.height * 0.1) - (height / 2)
        let rect = CGRect(x: x,
                          y: y,
                          width: width,
                          height: height)
        viewModel.interestArea = rect
        return rect
    }

    // MARK: Detected Rectangle

    private var detectedRectangle: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(.yellow, lineWidth: 2)
            .frame(width: viewModel.detectedFrame.width,
                   height: viewModel.detectedFrame.height)
            .position(x: viewModel.detectedFrame.midX,
                      y: viewModel.detectedFrame.midY)
    }
}

struct CCScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CCScannerView { _ in }
            .previewDevice("iPhone 12 mini")

        if true {
            CCScannerView { _ in }
                .previewInterfaceOrientation(.landscapeRight)
                .previewDevice("iPad Pro (9.7-inch)")
        }
    }
}
