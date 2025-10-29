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
    
    init(chatId: String) {
        self.chatId = chatId
        listenForMessages()
    }
    
    func listenForMessages() {
        db.collection("chats").document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { try? $0.data(as: Message.self) }
            }
    }
    
    func send(text: String, senderId: String) {
        let message = Message(senderId: senderId, text: text, timestamp: Date())
        let chatDoc = db.collection("chats").document(chatId)
        let msgDoc = chatDoc.collection("messages").document()
        do {
            try msgDoc.setData(from: message)
            chatDoc.setData([
                "lastMessage": text,
                "lastUpdated": Date()
            ], merge: true)
        } catch {
            print("Failed to send message: \(error)")
        }
    }
}
