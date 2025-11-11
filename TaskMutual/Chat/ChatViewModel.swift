//
//  ChatViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var totalUnreadCount: Int = 0

    let db = Firestore.firestore()
    let userId: String

    init(userId: String) {
        self.userId = userId
        fetchChats()
    }

    func fetchChats() {
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "lastUpdated", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.chats = documents.compactMap { try? $0.data(as: Chat.self) }

                // Calculate total unread count
                self.updateTotalUnreadCount()
            }
    }

    private func updateTotalUnreadCount() {
        let total = chats.reduce(0) { sum, chat in
            let unreadForUser = chat.unreadCount?[userId] ?? 0
            return sum + unreadForUser
        }
        totalUnreadCount = total

        // Update app badge
        NotificationManager.shared.updateBadgeCount(total)
    }
}
