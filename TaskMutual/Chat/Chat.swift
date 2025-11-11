//
//  Chat.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//

import Foundation
import FirebaseFirestore

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var lastMessage: String
    var lastUpdated: Date
    var lastSenderId: String? // Track who sent the last message
    var unreadCount: [String: Int]? // Map of userId to unread count
}

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Date
}

