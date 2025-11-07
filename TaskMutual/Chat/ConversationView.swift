//
//  ConversationView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//

import SwiftUI
import FirebaseAuth

struct ConversationView: View {
    let chat: Chat
    @StateObject private var messagesVM: MessagesViewModel
    @State private var messageText = ""
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
                        // TODO: Add camera functionality
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.accent)
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
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Theme.accent)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )

                    // Like button (when no text)
                    if messageText.isEmpty {
                        Button(action: {
                            HapticsManager.shared.medium()
                            messagesVM.send(text: "❤️", senderId: userId)
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 22))
                                .foregroundColor(Theme.accent)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
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
