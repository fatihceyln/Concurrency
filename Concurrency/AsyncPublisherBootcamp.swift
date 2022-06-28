//
//  AsyncPublisher.swift
//  Concurrency
//
//  Created by Fatih Kilit on 28.06.2022.
//

import SwiftUI
import Combine

actor AsyncPublisherDataManager {
    
    @Published var dataArray: [String] = []
    
    func addData() {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            dataArray.append("Apple")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            dataArray.append("Banana")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            dataArray.append("Orange")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            dataArray.append("Watermelon")
        }
    }
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        
        
        Task {
            await MainActor.run(body: {
                self.dataArray.append("1")
            })
        }
        
        Task {
            
            // if you don't break it'll wait forever so the following codes won't work
            // To avoid that you can subscribe to publishers on separate Tasks or you can break subscriptions
            for await value in await manager.$dataArray.values {
                await MainActor.run(body: {
                    self.dataArray.append(contentsOf: value)
                })
                if !value.isEmpty {
                    break // -> IMPORTANT TO BREAKING SUBSCRIPTION
                }
            }
            
            await MainActor.run(body: {
                self.dataArray.append("2")
            })
        }
        
        
        //        manager.$dataArray
        //            .receive(on: DispatchQueue.main)
        //            .sink { dataArray in
        //                self.dataArray = dataArray
        //            }
        //            .store(in: &cancellables)
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBootcamp: View {
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) {
                Text($0)
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisher_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
