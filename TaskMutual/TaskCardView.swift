//
//  TaskCardView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/1/25.
//

import SwiftUI

struct TaskCardView: View {
    let task: Task
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onReport: () -> Void
    var onRespond: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.headline)
                .foregroundColor(Theme.accent)
            Text(task.description)
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.13), radius: 8, x: 0, y: 3)
        )
        .padding(.vertical, 6)
        .contextMenu {
            Button("Edit") { onEdit() }
            Button("Delete", role: .destructive) { onDelete() }
            Button("Report") { onReport() }
            Button("Respond") { onRespond() }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}














