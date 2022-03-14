//
//  ContentView.swift
//  CCScan
//
//  Created by Egehan Acar on 14.03.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ccScannerView()
            ZStack {
                GeometryReader { proxy in
                    let w = proxy.size.width * 0.9
                    let h = 53.98 * (w / 85.6)
                    let x = proxy.size.width / 2
                    let y = (h / 2) + (proxy.size.height * 0.05)
                    Rectangle()
                        .fill(.black)
                        .frame(width: proxy.size.width,
                               height: proxy.size.height)
                        .opacity(0.7)
                    Rectangle()
                        .frame(width: w, height: h)
                        .cornerRadius(15)
                        .blendMode(.destinationOut)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.red, lineWidth: 5)
                        )
                        .position(x: x, y: y)
                }
            }.compositingGroup()
        }.ignoresSafeArea()
    }

    private func ccScannerView() -> some View {
        #if targetEnvironment(simulator)
        return Image("camera.place.holder")
            .resizable()
        #else
        return CCScannerView()
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
