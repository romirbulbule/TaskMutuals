//
//  TaskImageGallery.swift
//  TaskMutual
//
//  Image gallery component for displaying task images
//

import SwiftUI

struct TaskImageGallery: View {
    let imageURLs: [String]
    @State private var selectedImageIndex: Int?
    @State private var showFullScreen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !imageURLs.isEmpty {
                Text("Images")
                    .font(.headline)
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, urlString in
                            if let url = URL(string: urlString) {
                                Button(action: {
                                    selectedImageIndex = index
                                    showFullScreen = true
                                }) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 120, height: 120)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        case .failure:
                                            Image(systemName: "photo")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white.opacity(0.5))
                                                .frame(width: 120, height: 120)
                                                .background(Color.white.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                .fullScreenCover(isPresented: $showFullScreen) {
                    if let index = selectedImageIndex {
                        FullScreenImageGallery(
                            imageURLs: imageURLs,
                            currentIndex: index,
                            isPresented: $showFullScreen
                        )
                    }
                }
            }
        }
    }
}

struct FullScreenImageGallery: View {
    let imageURLs: [String]
    @State var currentIndex: Int
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(imageURLs.enumerated()), id: \.offset) { index, urlString in
                    if let url = URL(string: urlString) {
                        ZoomableImageView(url: url)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

struct ZoomableImageView: View {
    let url: URL
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                // Reset if zoomed out too much
                                if scale < 1.0 {
                                    withAnimation {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                }
                                // Limit max zoom
                                if scale > 5.0 {
                                    withAnimation {
                                        scale = 5.0
                                        lastScale = 5.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            case .failure:
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.7))
                    Text("Failed to load image")
                        .foregroundColor(.white.opacity(0.7))
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    TaskImageGallery(imageURLs: [
        "https://via.placeholder.com/600",
        "https://via.placeholder.com/600/FF0000",
        "https://via.placeholder.com/600/00FF00"
    ])
}
