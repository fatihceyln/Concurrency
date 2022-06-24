//
//  DownloadImageAsync.swift
//  Concurrency
//
//  Created by Fatih Kilit on 23.06.2022.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    let url: URL = URL(string: "https://picsum.photos/1000")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300,
            let image = UIImage(data: data)
        else {
            return nil
        }
        
        return image
    }
    
    func downloadWithEscape(completionHandler: @escaping(_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            let image = self?.handleResponse(data: data, response: response)
            
            completionHandler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .map { (data: Data, response: URLResponse) in
                self.handleResponse(data: data, response: response)
            }
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
//    func downloadWithAsync() async throws -> UIImage? {
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
//            let image = handleResponse(data: data, response: response)
//            return image
//        } catch {
//            throw error
//        }
//    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                return nil
            }
            return UIImage(data: data)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        
        // Download with escape
        /*
        loader.downloadWithEscape { [weak self] image, error in
            if let image = image {
                // Publishing changes from background threads is not allowed
                DispatchQueue.main.async {
                    self?.image = image
                }
            } else if let error = error {
                fatalError(error.localizedDescription)
            }
        }
         */
        
        // Download with combine
        /*
         loader.downloadWithCombine()
         .receive(on: DispatchQueue.main)
         .sink { _ in
         
         } receiveValue: { [weak self] image in
         // since we're receiving on main thread there is no need to DispatchQueue.main.async closure
         self?.image = image
         }
         .store(in: &cancellables)
         */
        
        // Download with async
        let image = try? await loader.downloadWithAsync()
        // DON'T DO THAT
//        DispatchQueue.main.async {
//            self.image = image
//        }

        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    @StateObject private var viewModel: DownloadImageAsyncViewModel = DownloadImageAsyncViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                    }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
        .onTapGesture {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
