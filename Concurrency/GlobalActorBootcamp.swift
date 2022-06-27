//
//  GlobalActorBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 26.06.2022.
//

import SwiftUI

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three"]
    }
}

class GlobalActorBootcampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    let manager: MyNewDataManager = MyNewDataManager()
    
    func getData() async {
        dataArray = await manager.getDataFromDatabase()
    }
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel: GlobalActorBootcampViewModel = GlobalActorBootcampViewModel()
     
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) {
                Text($0)
                    .font(.title)
                    .fontWeight(.black)
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
