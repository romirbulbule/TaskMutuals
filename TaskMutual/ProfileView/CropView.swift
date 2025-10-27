//
//  CropView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/27/25.
//


import SwiftUI
import TOCropViewController

struct CropView: UIViewControllerRepresentable {
    let image: UIImage
    var didCrop: (UIImage) -> Void

    class Coordinator: NSObject, TOCropViewControllerDelegate {
        let parent: CropView

        init(_ parent: CropView) { self.parent = parent }

        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
            cropViewController.dismiss(animated: true)
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
            parent.didCrop(image)
            cropViewController.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropVC = TOCropViewController(image: image)
        cropVC.delegate = context.coordinator
        cropVC.aspectRatioPreset = CGSize(width: 1, height: 1) // Square ratio (needed for circle display)
        cropVC.aspectRatioLockEnabled = true
        cropVC.resetButtonHidden = true
        cropVC.rotateButtonsHidden = true
        return cropVC
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}
}

