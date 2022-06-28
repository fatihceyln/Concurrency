//
//  SendableBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 28.06.2022.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: ClassUserInfo) {
        
    }
}

// Structs Sendable by default because they are value type, because they are thread safe
struct StructUserInfo: Sendable {
    var name: String
}

// Classes are not thread safe by default, thus if you want to pass your class to concurrent environment you have to conform Sendable and mark it @unchecked also you have to make your class thread safe by yourself
final class ClassUserInfo: @unchecked Sendable {
    private(set) var name: String
    private let queue: DispatchQueue = DispatchQueue(label: "com.fatih.ClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        // We are making thread safe
        queue.async {
            self.name = name
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager: CurrentUserManager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        //let info = StructUserInfo(name: "info")
        let info = ClassUserInfo(name: "info")
        
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
