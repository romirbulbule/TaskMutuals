//
//  MessagesViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class MessagesViewModel: ObservableObject {
    @Published var messages: [Message] = []

    let db = Firestore.firestore()
    let chatId: String
    let currentUserId: String
    private var lastMessageCount = 0

    init(chatId: String) {
        self.chatId = chatId
        self.currentUserId = Auth.auth().currentUser?.uid ?? ""
        listenForMessages()
    }

    func listenForMessages() {
        db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { try? $0.data(as: Message.self) }

                // Check for new messages and send notification
                if self.messages.count > self.lastMessageCount && self.lastMessageCount > 0 {
                    if let lastMessage = self.messages.last, lastMessage.senderId != self.currentUserId {
                        self.notifyNewMessage(lastMessage)
                    }
                }
                self.lastMessageCount = self.messages.count
            }
    }

    func send(text: String, senderId: String) {
        let message = Message(senderId: senderId, text: text, timestamp: Date())
        let chatDoc = db.collection("chats").document(chatId)
        let msgDoc = chatDoc.collection("messages").document()

        // Get chat document to find other participant
        chatDoc.getDocument { snapshot, error in
            guard let chat = try? snapshot?.data(as: Chat.self) else { return }
            let otherUserId = chat.participants.first(where: { $0 != senderId }) ?? ""

            // Update unread count for the other user
            var unreadCount = chat.unreadCount ?? [:]
            unreadCount[otherUserId] = (unreadCount[otherUserId] ?? 0) + 1

            do {
                try msgDoc.setData(from: message)
                chatDoc.setData([
                    "lastMessage": text,
                    "lastUpdated": Date(),
                    "lastSenderId": senderId,
                    "unreadCount": unreadCount
                ], merge: true)
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }

    // Mark messages as read (clear unread count)
    func markAsRead() {
        let chatDoc = db.collection("chats").document(chatId)

        chatDoc.getDocument { snapshot, error in
            guard var chat = try? snapshot?.data(as: Chat.self) else { return }
            var unreadCount = chat.unreadCount ?? [:]
            unreadCount[self.currentUserId] = 0

            chatDoc.setData([
                "unreadCount": unreadCount
            ], merge: true)

            // Clear notifications for this chat
            NotificationManager.shared.clearNotifications(for: self.chatId)
        }
    }

    private func notifyNewMessage(_ message: Message) {
        // Fetch sender name and profile image, then send notification
        db.collection("users").document(message.senderId).getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let senderName = "\(firstName) \(lastName)"
            let profileImageURL = data["profileImageURL"] as? String

            NotificationManager.shared.sendMessageNotification(
                from: senderName,
                message: message.text,
                chatId: self.chatId,
                senderId: message.senderId,
                profileImageURL: profileImageURL
            )
        }
    }
}
