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
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 64))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No Messages")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("Start a conversation with someone")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollViewWithTabBar {
                            LazyVStack(spacing: 0) {
                                ForEach(chatVM.chats) { chat in
                                    NavigationLink(
                                        destination: ConversationView(chat: chat)
                                            .environmentObject(userVM)
                                    ) {
                                        ChatRowView(chat: chat, currentUserId: Auth.auth().currentUser?.uid ?? "", userVM: userVM)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onTapGesture {
                                        HapticsManager.shared.medium()
                                    }

                                    Divider()
                                        .padding(.leading, 84)
                                }
                            }
                            .padding(.bottom, 80)
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

// Chat Row View that shows the other participant's name - Instagram style
struct ChatRowView: View {
    let chat: Chat
    let currentUserId: String
    @ObservedObject var userVM: UserViewModel
    @State private var otherUserName: String = "Loading..."
    @State private var otherUsername: String = ""
    @State private var profileImageURL: String?

    var body: some View {
        HStack(spacing: 12) {
            // Profile picture - circular with image or initials
            if let urlString = profileImageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    default:
                        Circle()
                            .fill(LinearGradient(
                                colors: [Theme.accent.opacity(0.6), Theme.accent.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Text(otherUsername.prefix(1).uppercased())
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            } else {
                Circle()
                    .fill(LinearGradient(
                        colors: [Theme.accent.opacity(0.6), Theme.accent.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(otherUsername.prefix(1).uppercased())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 3) {
                // Name in bold
                Text(otherUserName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                // Last message preview
                Text(chat.lastMessage.isEmpty ? "Tap to start chatting" : chat.lastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Timestamp and chevron
            VStack(alignment: .trailing, spacing: 4) {
                Text(chat.lastUpdated, style: .relative)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.3))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
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
            let imageURL = data["profileImageURL"] as? String

            DispatchQueue.main.async {
                self.otherUserName = "\(firstName) \(lastName)"
                self.otherUsername = username
                self.profileImageURL = imageURL
                print("✅ Loaded chat user: \(self.otherUserName)")
            }
        }
    }
}
