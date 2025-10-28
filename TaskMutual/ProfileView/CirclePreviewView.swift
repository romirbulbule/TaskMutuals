//
//  CirclePreviewView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/27/25.
//


import SwiftUI

struct CirclePreviewView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    let onContinue: () -> Void
    let onChooseAnother: () -> Void
    let onSetAsProfile: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Preview")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .white.opacity(0.3), radius: 10)
                Text("This is how your profile picture will appear")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                VStack(spacing: 16) {
                    Button(action: onContinue) {
                        HStack {
                            Image(systemName: "crop")
                            Text("Continue to Crop")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    Button(action: onSetAsProfile) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Use as Profile Picture")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    Button(action: onChooseAnother) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Choose Another Photo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

