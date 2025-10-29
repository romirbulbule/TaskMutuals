//
//  ChatView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatView: View {
    @StateObject private var chatVM = ChatViewModel(userId: Auth.auth().currentUser?.uid ?? "")
    @EnvironmentObject var userVM: UserViewModel
    @State private var showUserSearch = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    if chatVM.chats.isEmpty {
                        Spacer()
                        Text("No chats yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        List(chatVM.chats) { chat in
                            NavigationLink(
                                destination: ConversationView(chat: chat)
                            ) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(chat.lastMessage.isEmpty ? "New Chat" : chat.lastMessage)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text(chat.lastUpdated, style: .date)
                                        .font(.caption).foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            .listRowBackground(Theme.background)
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showUserSearch = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showUserSearch) {
                UserSearchView(userVM: userVM) { selectedUser in
                    createOrOpenChat(with: selectedUser)
                }
            }
        }
    }

    func createOrOpenChat(with otherUser: UserProfile) {
        let db = Firestore.firestore()
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let participantIds = [currentUserId, otherUser.id ?? ""].sorted()
        let chatsRef = db.collection("chats")
        chatsRef
            .whereField("participants", isEqualTo: participantIds)
            .getDocuments { snapshot, error in
                if let chatDoc = snapshot?.documents.first {
                    chatVM.fetchChats()
                } else {
                    let newChatData: [String: Any] = [
                        "participants": participantIds,
                        "lastMessage": "",
                        "lastUpdated": Date()
                    ]
                    let newDoc = chatsRef.document()
                    newDoc.setData(newChatData) { err in
                        chatVM.fetchChats()
                    }
                }
            }
    }
}
