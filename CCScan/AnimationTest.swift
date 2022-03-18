//
//  AnimationTest.swift
//  CCScan
//
//  Created by Egehan Acar on 15.03.2022.
//

import SwiftUI

struct AnimationTest: View {
    @StateObject
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            MyRect(change: $viewModel.change)
        }.onAppear(perform: viewModel.onAppear)
    }
}

extension AnimationTest {
    final class ViewModel: ObservableObject {
        @Published var change: Bool = true
        
        func onAppear() {
            Timer.scheduledTimer(timeInterval: 1,
                  target: self,
                  selector: #selector(timed),
                  userInfo: nil, repeats: true)
                .fire()
        }
        
        @objc private func timed() {
            withAnimation(.easeInOut) {
                self.change.toggle()
            }
           
        }
    }
}

struct MyRect: View {
    @Binding var change: Bool
    
    var body: some View {
        Rectangle()
            .fill(change ? .red : .blue)
            .frame(width: 250, height: 150)
            .cornerRadius(10)
    }
}

struct AnimationTest_Previews: PreviewProvider {
    static var previews: some View {
        AnimationTest(viewModel: AnimationTest.ViewModel())
    }
}
