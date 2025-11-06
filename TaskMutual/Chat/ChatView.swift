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
                                    .environmentObject(userVM)
                            ) {
                                ChatRowView(chat: chat, currentUserId: Auth.auth().currentUser?.uid ?? "", userVM: userVM)
                            }
                            .listRowBackground(Theme.background)
                            .listRowSeparator(.hidden)
                            .simultaneousGesture(TapGesture().onEnded {
                                HapticsManager.shared.medium()
                            })
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

// Chat Row View that shows the other participant's name
struct ChatRowView: View {
    let chat: Chat
    let currentUserId: String
    @ObservedObject var userVM: UserViewModel
    @State private var otherUserProfile: UserProfile?

    var body: some View {
        HStack(spacing: 12) {
            // Profile picture placeholder
            Circle()
                .fill(Theme.accent.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(Theme.accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                // Show other participant's name
                if let otherUser = otherUserProfile {
                    Text("\(otherUser.firstName) \(otherUser.lastName)")
                        .font(.headline)
                        .foregroundColor(.primary)
                } else {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                // Last message preview
                Text(chat.lastMessage.isEmpty ? "No messages yet" : chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Timestamp
            Text(chat.lastUpdated, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onAppear {
            fetchOtherUserProfile()
        }
    }

    func fetchOtherUserProfile() {
        // Get the other participant's ID
        let otherUserId = chat.participants.first(where: { $0 != currentUserId }) ?? ""

        guard !otherUserId.isEmpty else { return }

        let db = Firestore.firestore()
        db.collection("users").document(otherUserId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let profile = try? Firestore.Decoder().decode(UserProfile.self, from: data) {
                DispatchQueue.main.async {
                    self.otherUserProfile = profile
                }
            }
        }
    }
}
