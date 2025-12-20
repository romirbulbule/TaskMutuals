//
//  ConversationView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ConversationView: View {
    let chat: Chat
    @StateObject private var messagesVM: MessagesViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var messageText = ""
    @State private var otherUserName: String = ""
    @State private var otherUsername: String = ""
    @State private var profileImageURL: String?
    private let userId = Auth.auth().currentUser?.uid ?? ""

    init(chat: Chat) {
        self.chat = chat
        _messagesVM = StateObject(wrappedValue: MessagesViewModel(chatId: chat.id ?? ""))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messagesVM.messages, id: \.id) { msg in
                            MessageBubble(msg: msg, isCurrentUser: msg.senderId == userId)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
                .background(Color(.systemBackground))
                .onChange(of: messagesVM.messages.count) { _ in
                    if let last = messagesVM.messages.last {
                        withAnimation { scrollProxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // Message input bar - Instagram style
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    // Camera button
                    Button(action: {
                        HapticsManager.shared.light()
                        // TODO: Add camera functionality
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }

                    // Message input
                    HStack(spacing: 8) {
                        TextField("Message...", text: $messageText)
                            .font(.system(size: 15))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)

                        if !messageText.isEmpty {
                            Button(action: {
                                HapticsManager.shared.medium()
                                messagesVM.send(text: messageText, senderId: userId)
                                messageText = ""
                            }) {
                                Text("Send")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Theme.accent)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )

                    // Additional buttons when no text
                    if messageText.isEmpty {
                        // Voice button
                        Button(action: {
                            HapticsManager.shared.light()
                            // TODO: Add voice recording
                        }) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }

                        // Gallery button
                        Button(action: {
                            HapticsManager.shared.light()
                            // TODO: Add gallery picker
                        }) {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }

                        // Sticker button
                        Button(action: {
                            HapticsManager.shared.light()
                            // TODO: Add sticker picker
                        }) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                // Instagram-style header with profile picture and name
                HStack(spacing: 8) {
                    // Profile picture
                    if let urlString = profileImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            default:
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Theme.accent.opacity(0.6), Theme.accent.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(otherUsername.prefix(1).uppercased())
                                            .font(.system(size: 14, weight: .semibold))
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
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(otherUsername.prefix(1).uppercased())
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(otherUserName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(otherUsername)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .hideTabBar()
        .onAppear {
            // Mark messages as read when user opens the chat
            messagesVM.markAsRead()

            // Clear local notifications for this chat
            NotificationManager.shared.clearNotifications(for: chat.id ?? "")

            // Fetch other user's profile
            fetchOtherUserProfile()
        }
    }

    func fetchOtherUserProfile() {
        // Get the other participant's ID
        let otherUserId = chat.participants.first(where: { $0 != userId }) ?? ""

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

            // Extract fields manually
            let firstName = data["firstName"] as? String ?? ""
            let lastName = data["lastName"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            let imageURL = data["profileImageURL"] as? String

            DispatchQueue.main.async {
                self.otherUserName = "\(firstName) \(lastName)"
                self.otherUsername = username
                self.profileImageURL = imageURL
                print("✅ Loaded conversation user: \(self.otherUserName)")
            }
        }
    }
}

// --- Subview for each message bubble - Instagram style ---
struct MessageBubble: View {
    let msg: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(msg.text)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isCurrentUser
                        ? Theme.accent
                        : Color(.systemGray5)
                    )
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(18)

                Text(msg.timestamp, style: .time)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
}
