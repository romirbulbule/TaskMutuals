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
                if let error = error {
                    print("❌ Error fetching chats: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                // Decode with error logging
                self.chats = documents.compactMap { doc in
                    do {
                        return try doc.data(as: Chat.self)
                    } catch {
                        print("❌ Failed to decode chat \(doc.documentID): \(error.localizedDescription)")
                        return nil
                    }
                }

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

    // MARK: - Data Migration

    /// One-time migration to fix incomplete chat documents
    /// Call this once on app launch for existing users to fix broken chats
    func migrateIncompleteChatDocuments() {
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Migration error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let batch = self.db.batch()
                var needsMigration = false

                for doc in documents {
                    let data = doc.data()

                    // Check if missing required fields
                    let missingFields = data["lastSenderId"] == nil || data["unreadCount"] == nil

                    if missingFields {
                        needsMigration = true

                        let participants = data["participants"] as? [String] ?? []
                        var unreadCount: [String: Int] = [:]
                        for participant in participants {
                            unreadCount[participant] = 0
                        }

                        batch.updateData([
                            "lastSenderId": "",
                            "unreadCount": unreadCount
                        ], forDocument: doc.reference)

                        print("🔧 Migrating chat: \(doc.documentID)")
                    }
                }

                if needsMigration {
                    batch.commit { error in
                        if let error = error {
                            print("❌ Migration failed: \(error.localizedDescription)")
                        } else {
                            print("✅ Chat documents migrated successfully")
                            // Refresh chats after migration
                            self.fetchChats()
                        }
                    }
                } else {
                    print("✅ No chats need migration")
                }
            }
    }
}
