//
//  CropperSheet.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/28/25.
//


import SwiftUI
import TOCropViewController

struct CropperSheet: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, TOCropViewControllerDelegate {
        var parent: CropperSheet
        init(_ parent: CropperSheet) { self.parent = parent }

        func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.image = image
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.image = image
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> TOCropViewController {
        let imageToCrop = image ?? UIImage()
        // Initialize with circular cropping style
        let cropVC = TOCropViewController(croppingStyle: .circular, image: imageToCrop)
        cropVC.delegate = context.coordinator

        // UI
        cropVC.title = "Crop Profile Photo"
        cropVC.modalPresentationStyle = .fullScreen
        return cropVC
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}
}