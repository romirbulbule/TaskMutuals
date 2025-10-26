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
            }
    }
}
