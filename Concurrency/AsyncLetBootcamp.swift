//
//  AsyncLetBootcamp.swift
//  Concurrency
//
//  Created by Fatih Kilit on 23.06.2022.
//

import SwiftUI

struct AsyncLetBootcamp: View {
    
    @State private var images: [UIImage] = []
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/1000")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .navigationTitle("Async Let")
        }
        .onAppear {
            Task {
                do {
                    
                    // Purpose of "async let" is making async work without awaiting the others to complete their job
                    
                    async let fetchImage1 = fetchImage()
                    async let fetchImage2 = fetchImage()
                    async let fetchImage3 = fetchImage()
                    async let fetchImage4 = fetchImage()

                    // It'll wait for four fetchImage async function and then assign results of them
                    let (image1, image2, image3, image4) = try await (fetchImage1, fetchImage2, fetchImage3, fetchImage4)

                    // You can make try? or try specific to function if you want
//                    let (image1, image2, image3, image4) = try await (try? fetchImage1, try? fetchImage2, try fetchImage3, try fetchImage4)

                    images.append(contentsOf: [image1, image2, image3, image4])

                    
                    // It'll await for all awaitened results in order
                    // So the images will pop up in order
//                    let image1 = try await fetchImage()
//                    images.append(image1)
//
//                    let image2 = try await fetchImage()
//                    images.append(image2)
//
//                    let image3 = try await fetchImage()
//                    images.append(image3)
//
//                    let image4 = try await fetchImage()
//                    images.append(image4)
                } catch {
                    
                }
            }
        }
    }
    
    func fetchImage() async throws -> UIImage {
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

struct AsyncLetBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootcamp()
    }
}
