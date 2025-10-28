//
//  MultilineTextField.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/28/25.
//


import SwiftUI

struct MultilineTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var minHeight: CGFloat = 48
    var maxHeight: CGFloat = 100
    var background: UIColor = UIColor(white: 1, alpha: 0.07)
    var cornerRadius: CGFloat = 10

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextField

        init(parent: MultilineTextField) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.white
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.gray
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            // Enforce character limit
            if textView.text.count > 150 {
                textView.text = String(textView.text.prefix(150))
            }
            parent.text = textView.text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.backgroundColor = background
        textView.layer.cornerRadius = cornerRadius
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 10, bottom: 11, right: 10)
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = text.isEmpty ? UIColor.gray : UIColor.white
        textView.tintColor = UIColor.systemBlue

        textView.text = text.isEmpty ? placeholder : text

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text && !(uiView.isFirstResponder && uiView.textColor == UIColor.white) {
            uiView.text = text.isEmpty && !uiView.isFirstResponder ? placeholder : text
            uiView.textColor = text.isEmpty && !uiView.isFirstResponder ? UIColor.gray : UIColor.white
        }
        uiView.backgroundColor = background
    }
}
