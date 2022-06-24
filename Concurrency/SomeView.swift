//
//  SomeView.swift
//  Concurrency
//
//  Created by Fatih Kilit on 24.06.2022.
//

import SwiftUI

class SomeViewViewModel: ObservableObject {
    init() {
        print("ViewModel INIT")
    }
}

struct SomeView: View {
    @StateObject private var viewModel = SomeViewViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? .red : .blue)
    }
}

struct SomeHomeView: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        SomeView(isActive: isActive) // when isActive changes It'll create a new struct
            .onTapGesture {
                isActive.toggle()
            }
    }
}

struct SomeView_Previews: PreviewProvider {
    static var previews: some View {
        SomeView(isActive: true)
    }
}
