//
//  MainView.swift
//  CCScan
//
//  Created by Egehan Acar on 23.03.2022.
//

import SwiftUI

struct MainView: View {
    @State
    var isPresented = false

    var body: some View {
        Button("Scan") {
            isPresented = true
        }
        .fullScreenCover(isPresented: $isPresented) {
            CCScannerView { result in
                print(result)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
