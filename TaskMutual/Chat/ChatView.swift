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
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var showUserSearch = false
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))

                        TextField("Search", text: $searchText)
                            .font(.system(size: 17))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))

                // Messages header with Requests
                HStack {
                    HStack(spacing: 8) {
                        Text("Messages")
                            .font(.system(size: 22, weight: .bold))

                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("Requests")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.accent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))

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
                            ForEach(filteredChats) { chat in
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
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticsManager.shared.medium()
                        showUserSearch = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
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

    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chatVM.chats
        }
        return chatVM.chats.filter { chat in
            // You could filter based on user names here
            // For now, just return all
            true
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
                        "lastUpdated": Date(),
                        "lastSenderId": "",
                        "unreadCount": [currentUserId: 0, otherUser.id ?? "": 0]
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

            VStack(alignment: .leading, spacing: 4) {
                // Name in bold
                Text(otherUserName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                // Last message preview
                HStack(spacing: 4) {
                    Text(chat.lastMessage.isEmpty ? "Tap to start chatting" : chat.lastMessage)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    if !chat.lastMessage.isEmpty {
                        Text("·")
                            .foregroundColor(.secondary)
                            .font(.system(size: 15))

                        Text(formatRelativeTime(chat.lastUpdated))
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Camera icon (like Instagram)
            Image(systemName: "camera")
                .font(.system(size: 24))
                .foregroundColor(.secondary.opacity(0.6))
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

    func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let seconds = Int(now.timeIntervalSince(date))
        let calendar = Calendar.current

        if seconds < 60 {
            return "now"
        } else if seconds < 3600 {
            return "\(seconds / 60)m"
        } else if seconds < 86400 {
            return "\(seconds / 3600)h"
        } else if seconds < 604800 {
            let days = seconds / 86400
            return "\(days)d"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            // Same year: show "MMM dd"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        } else {
            // Different year: show "MMM dd, yyyy"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}
