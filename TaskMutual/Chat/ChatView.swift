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
                            .onTapGesture {
                                HapticsManager.shared.medium()
                            }
                        }
                        .listStyle(.plain)
                        .safeAreaInset(edge: .bottom) {
                            Color.clear.frame(height: 80)
                        }
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
    @State private var otherUserName: String = "Loading..."
    @State private var otherUsername: String = ""

    var body: some View {
        HStack(spacing: 12) {
            // Profile picture placeholder
            Circle()
                .fill(Theme.accent.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(otherUsername.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(Theme.accent)
                )

            VStack(alignment: .leading, spacing: 4) {
                // Show other participant's name
                Text(otherUserName)
                    .font(.headline)
                    .foregroundColor(.primary)

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

        guard !otherUserId.isEmpty else {
            otherUserName = "Unknown User"
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(otherUserId).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user profile: \(error)")
                DispatchQueue.main.async {
                    self.otherUserName = "Error loading"
                }
                return
            }

            guard let data = snapshot?.data() else {
                print("❌ No data for user: \(otherUserId)")
                DispatchQueue.main.async {
                    self.otherUserName = "User not found"
                }
                return
            }

            // Extract fields manually to avoid decoding issues
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let username = data["username"] as? String ?? ""

            DispatchQueue.main.async {
                self.otherUserName = "\(firstName) \(lastName)"
                self.otherUsername = username
                print("✅ Loaded chat user: \(self.otherUserName)")
            }
        }
    }
}
