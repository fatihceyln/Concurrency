//
//  TaskGroupBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 24.06.2022.
//

import SwiftUI

class TaskGroupBootcampDataManager {
    
    func fetchImageWithAsycnLet() async throws -> [UIImage] {
        async let fetchImage1 = await fetchImage(urlString: "https://picsum.photos/1000")
        async let fetchImage2 = await fetchImage(urlString: "https://picsum.photos/1000")
        async let fetchImage3 = await fetchImage(urlString: "https://picsum.photos/1000")
        async let fetchImage4 = await fetchImage(urlString: "https://picsum.photos/1000")
        
        let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)
        
        return [image1, image2, image3, image4]
    }
    
    /*
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []
            
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/1000")
            }
            
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/1000")
            }
            
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/1000")
            }
            
            group.addTask {
                try await self.fetchImage(urlString: "https://picsum.photos/1000")
            }
            
            // try await each result in the group
            for try await image in group {
                images.append(image)
            }
            
            return images
        }
    }
    */
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlStrings: [String] = [
            "https://picsum.photos/1000",
            "https://picsum.photos/1000",
            "https://picsum.photos/1000",
            "https://picsum.photos/1000",
            "https://picsum.photos/1000",
            "https://picsum.photos/1000",
            "https://picsum.photos/1000"
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings {
                // all of these tasks are inheriting the metadata from the parent taks. for example if the parent task had a high priority so would all of these child tasks unless we added our custom priority
                group.addTask {
                    // if one of them fails, it's just going to return a nil value rather than failing the entire task
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            // try await each result in the group
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupBootcampDataManager()
    
    func getImages() async {
//        if let images = try? await manager.fetchImageWithAsycnLet() {
//            self.images = images
//        }
        
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            await MainActor.run(body: {
                self.images = images
            })
        }
    }
}

struct TaskGroupBootcamp: View {
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !viewModel.images.isEmpty {
                    LazyVGrid(columns: columns) {
                        ForEach(viewModel.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .overlay(content: {
                if viewModel.images.isEmpty {
                    ProgressView()
                }
            })
            .navigationTitle("Task Group")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}
