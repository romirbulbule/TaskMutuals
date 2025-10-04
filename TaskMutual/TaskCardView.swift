//
//  TaskCardView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/1/25.
//

import SwiftUI

struct TaskCardView: View {
    var task: Task
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onReport: () -> Void
    var onRespond: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // <--- leading alignment here
            Text(task.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Theme.accent)
            Text(task.description)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading) // <--- Force leading text alignment
            HStack {
                if !task.responses.isEmpty {
                    Text("💬 \(task.responses.count)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(task.timestamp, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.07), radius: 7, x: 0, y: 2)
        .contextMenu {
            Button("Edit", action: onEdit)
            Button("Delete", action: onDelete)
            Button("Report", action: onReport)
            Button("Respond", action: onRespond)
        }
    }
}














