//
//  AsyncAwaitBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 23.06.2022.
//

import SwiftUI

class AsynAwaitBootcampViewModel: ObservableObject {
    
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject private var viewModel = AsynAwaitBootcampViewModel()
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct AsyncAwaitBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootcamp()
    }
}
