//
//  CropView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/27/25.
//


import SwiftUI

struct CropView: View {
    @Binding var image: UIImage?
    @State private var showCropper = false
    @Environment(\.presentationMode) var presentationMode

    var onSet: (UIImage) -> Void
    var onChooseAnother: () -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 34) {
                Spacer(minLength: 40)
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 3))
                        .shadow(radius: 8)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.12))
                            .frame(width: 180, height: 180)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                VStack(spacing: 16) {
                    // CROp button styled to match Set Profile Picture
                    Button(action: { showCropper = true }) {
                        Text("Crop")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .cornerRadius(16)
                            .shadow(color: Color.accentColor.opacity(0.23), radius: 6, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(image == nil)
                    .sheet(isPresented: $showCropper) {
                        CropperSheet(image: $image)
                    }

                    Button(action: {
                        onSet(image!)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Set Profile Picture")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .cornerRadius(16)
                            .shadow(color: Color.accentColor.opacity(0.23), radius: 6, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(image == nil)

                    Button(action: {
                        onChooseAnother()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Choose Another")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 32)
                Spacer(minLength: 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}



