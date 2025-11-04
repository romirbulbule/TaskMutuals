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
    var creatorUserId: String
    var creatorUsername: String
    var creatorUserType: String? // "looking_for_services" or "providing_services"
    var timestamp: Date = Date()
    var responses: [Response] = []
    var isArchived: Bool = false
}

struct Response: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var fromUserId: String
    var fromUsername: String
    var message: String
    var timestamp: Date = Date()
}
