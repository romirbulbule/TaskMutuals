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
    var minHeight: CGFloat
    var maxHeight: CGFloat
    var background: UIColor
    var cornerRadius: CGFloat

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextField

        init(_ parent: MultilineTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = background
        textView.layer.cornerRadius = cornerRadius
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = text.isEmpty ? placeholder : text
        textView.textColor = text.isEmpty ? UIColor.lightGray : UIColor.label
        textView.isScrollEnabled = true

        // Add native toolbar with Done button!
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: textView,
            action: #selector(textView.resignFirstResponder)
        )
        doneButton.tintColor = UIColor.systemBlue
        toolbar.items = [UIBarButtonItem.flexibleSpace(), doneButton]
        textView.inputAccessoryView = toolbar

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text.isEmpty ? placeholder : text
        textView.textColor = text.isEmpty ? UIColor.lightGray : UIColor.label
        textView.backgroundColor = background
        textView.layer.cornerRadius = cornerRadius
        textView.textColor = .white

        // Height constraint if you want (optional for full grow):
        let fittingSize = CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let size = textView.sizeThatFits(fittingSize)
        let height = min(max(size.height, minHeight), maxHeight)
        textView.constraints.forEach { c in
            if c.firstAttribute == .height {
                c.constant = height
            }
        }
    }
}
