//
//  Task.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/2/25.
//


import Foundation
import FirebaseFirestore

struct Task: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var timestamp: Date = Date()
}
