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
        var isEditing: Bool = false

        init(_ parent: MultilineTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // Only update the binding if we're not in the middle of clearing placeholder
            if isEditing {
                parent.text = textView.text
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true
            if textView.textColor == UIColor.lightGray {
                textView.text = ""
                textView.textColor = .white
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
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
        // Only update if text actually changed to avoid cursor jumping
        // Don't restore placeholder if user is actively editing (textView is first responder)
        if text.isEmpty && !textView.isFirstResponder {
            if textView.text != placeholder {
                textView.text = placeholder
                textView.textColor = UIColor.lightGray
            }
        } else if !text.isEmpty {
            if textView.text != text {
                textView.text = text
            }
            textView.textColor = .white
        }
        // If text is empty AND textView is first responder, don't change anything
        // (user is editing, let delegate methods handle it)

        textView.backgroundColor = background
        textView.layer.cornerRadius = cornerRadius

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
