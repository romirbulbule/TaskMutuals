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
    var onPost: (String, String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Task Title")
                        .foregroundColor(Color.white)
                        .font(.caption)
                    TextField("Title", text: $title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                }
                VStack(alignment: .leading) {
                    Text("Description")
                        .foregroundColor(Color.white)
                        .font(.caption)
                    TextField("Description", text: $description)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("New Task", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onPost(title, description)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Post")
                            .frame(width: 60, height: 34)
                            .foregroundColor(.white)
                            .background(Theme.accent)
                            .cornerRadius(8)
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }
}






