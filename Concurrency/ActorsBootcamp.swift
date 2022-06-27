//
//  ActorsBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 26.06.2022.
//

import SwiftUI

/*
class MyDataManager {
    static let shared: MyDataManager = MyDataManager()
    private init() {}
 
    var data: [String] = []
 
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
}
 */

/*
class MyDataManager {
    static let shared: MyDataManager = MyDataManager()
    private init() {}
    
    var data: [String] = []
    private let queue: DispatchQueue = DispatchQueue(label: "com.fatih.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}
*/

actor MyDataManager {
    static let shared: MyDataManager = MyDataManager()
    private init() {}
    
    var data: [String] = []
    nonisolated let myRandomText = "Something"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    /*
     NOTE:
     You can't access the isolated function from the non-isolated function
     But you can reach within Task
     */
    
    // We don't want to wait to get this function
    nonisolated func getSavedData() -> String {
        // let data = getRandomData() ---> It doesn't work
        
        /*
         Task {
         let data = await getRandomData()
         print("data")
         }
         */
        
        return "New Data"
    }
}

struct HomeView: View {
    let manager: MyDataManager = MyDataManager.shared
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear(perform: {
            let newString = manager.getSavedData()
            print(newString)
            print(manager.myRandomText)
        })
        .onReceive(timer) { _ in
            /*
            DispatchQueue.global(qos: .background).async {
                manager.getRandomData { data in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.text = data
                        }
                    }
                }
            }
             */
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        }
    }
}

struct BrowseView: View {
    
    let manager: MyDataManager = MyDataManager.shared
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            /*
            DispatchQueue.global(qos: .default).async {
                manager.getRandomData { data in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.text = data
                        }
                    }
                }
            }
            */
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        }
    }
}


struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
