//
//  ContinuationBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 24.06.2022.
//

import SwiftUI

class CheckedContinuationBootcampNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                // we're going to call resume exactly one time on this continuation !!!
                
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabaseEscaping(completionHandler: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completionHandler(UIImage(systemName: "heart.fill"))
        }
    }
    
    func getHeartImageFromDatabaseAsync() async throws -> UIImage {
        return try await withCheckedThrowingContinuation({ continuation in
            getHeartImageFromDatabaseEscaping { image in
                if let image = image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
        })
    }
}


class CheckedContinuationBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/1000") else {
            return
        }
        
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func getHeartImage() async {
        do {
            let image = try await networkManager.getHeartImageFromDatabaseAsync()
            
            await MainActor.run(body: {
                self.image = image
            })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

struct CheckedContinuationBootcamp: View {
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .task {
            // await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

struct ContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
