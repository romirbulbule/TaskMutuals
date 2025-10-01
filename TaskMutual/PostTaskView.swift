//
//  PostTaskView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/27/25.
//

import SwiftUI

struct PostTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""

    // 👇 this closure now *must* be provided by the parent
    var onPost: ((String, String) -> Void)

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Title")) {
                    TextField("Title", text: $title)
                }
                Section(header: Text("Description")) {
                    TextField("Description", text: $description)
                }
            }
            .navigationBarTitle("New Task", displayMode: .inline)
            .navigationBarItems(trailing:
                Button("Post") {
                    onPost(title, description) // 👈 call closure
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || description.isEmpty)
            )
        }
    }
}








