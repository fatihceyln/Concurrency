//
//  GlobalActorBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 27.06.2022.
//

import SwiftUI

@globalActor struct MyFirstGlobalActor {
    static var shared: MyNewDataManager = MyNewDataManager()
}

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four"]
    }
}

// @MainActor
class GlobalActorBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    // let manager: MyNewDataManager = MyNewDataManager()
    let manager: MyNewDataManager = MyFirstGlobalActor.shared
    
    func getData() async {
        let data = await manager.getDataFromDatabase()
        
        await MainActor.run(body: {
            self.dataArray = data
        })
    }
    
    @MyFirstGlobalActor func getData2() {
//        DispatchQueue.main.async {
//            self.dataArray = ["1", "2", "3"]
//        }
        
        Task {
            await MainActor.run(body: {
                self.dataArray = ["1", "2"]
            })
        }
    }
}

struct GlobalActorBootcamp: View {
    @StateObject private var viewModel: GlobalActorBootcampViewModel = GlobalActorBootcampViewModel()
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) {
                Text($0)
            }
        }
        .task {
            //await viewModel.getData()
            
            await viewModel.getData2()
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
