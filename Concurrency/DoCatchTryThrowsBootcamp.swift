//
//  DoCatchTryThrowsBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 23.06.2022.
//

import SwiftUI

class DoCatchTryThrowsBootcampDataManger {
    var isActive: Bool = false
    
    func getText() -> (String?, Error?) {
        if isActive {
            return ("NEW TEXT", nil)
        } else {
            return(nil, URLError(.badURL))
        }
    }
    
    func getText2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT 2")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
//    func getText3() throws -> String {
//        if isActive {
//            return "NEW TEXT 3"
//        } else {
//            throw URLError(.badURL)
//        }
//    }
    
    func getText3() throws -> String {
        throw URLError(.badURL)
    }
    
    func getText4() throws -> String {
        if isActive {
            return "FINAL TEXT"
        } else {
            throw URLError(.badURL)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    @Published var text: String = "Starting Text."
    var manager = DoCatchTryThrowsBootcampDataManger()
    
    func fetchText() {
        let returnedValue = manager.getText()
        
        if let newText = returnedValue.0 {
            self.text = newText
        } else if let error = returnedValue.1 {
            self.text = error.localizedDescription
        }
    }
    
    func fetchText2() {
        let result = manager.getText2()
        
        switch result {
        case .success(let newText):
            self.text = newText
        case .failure(let error):
            self.text = error.localizedDescription
        }
    }
    
    func fetchText3() {
        do {
            let newText = try manager.getText3()
            self.text = newText
        } catch {
            self.text = error.localizedDescription
        }
    }
    
    func fetchText4() {
        do {
            let newText = try? manager.getText3()
            if let newText = newText {
                self.text = newText
            }
            
            let newText2 = try manager.getText4()
            self.text = newText2
        } catch {
            self.text = error.localizedDescription
        }
    }
}

struct DoCatchTryThrowsBootcamp: View {
    @StateObject private var viewModel: DoCatchTryThrowsBootcampViewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        VStack(alignment: .center) {
            Toggle("isActive: \(viewModel.manager.isActive.description)", isOn: $viewModel.manager.isActive)
                .padding()
                .background(.ultraThickMaterial)
            
            Text(viewModel.text)
                .frame(width: 300, height: 300)
                .background(Color.blue)
                .onTapGesture {
                    viewModel.fetchText4()
                }
        }
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
