//
//  ConversationView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//

import SwiftUI
import FirebaseAuth

// ViewModifier to hide tab bar
extension View {
    func hideTabBar() -> some View {
        self.modifier(HideTabBarModifier())
    }
}

struct HideTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
                        tabBarController.tabBar.isHidden = true
                    }
                }
            }
            .onDisappear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
                        tabBarController.tabBar.isHidden = false
                    }
                }
            }
    }
}

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
                List {
                    ForEach(messagesVM.messages, id: \.id) { msg in
                        MessageBubble(msg: msg, isCurrentUser: msg.senderId == userId)
                            .id(msg.id)
                    }
                }
                .listStyle(.plain)
                .background(Theme.background)
                .onChange(of: messagesVM.messages.count) { _ in
                    if let last = messagesVM.messages.last {
                        withAnimation { scrollProxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Message...", text: $messageText)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(14)
                Button(action: {
                    if !messageText.isEmpty {
                        HapticsManager.shared.medium()
                        messagesVM.send(text: messageText, senderId: userId)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(Theme.accent)
                }
                .padding(.horizontal, 2)
            }
            .padding()
            .background(Theme.background)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }
}

// --- Subview for each message bubble ---
struct MessageBubble: View {
    let msg: Message
    let isCurrentUser: Bool

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
            HStack {
                if isCurrentUser { Spacer() }
                VStack(alignment: isCurrentUser ? .trailing : .leading) {
                    HStack(spacing: 6) {
                        if !isCurrentUser {
                            Circle()
                                .fill(Color.blue.opacity(0.5))
                                .frame(width: 28, height: 28)
                                .overlay(Text("👤"))
                        }
                        Text(msg.text)
                            .padding()
                            .background(
                                isCurrentUser
                                ? Theme.accent.opacity(0.18)
                                : Color(.systemGray6)
                            )
                            .cornerRadius(15)
                            .foregroundColor(isCurrentUser ? .white : .primary)
                    }
                    Text(msg.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(isCurrentUser ? .trailing : .leading, 12)
                }
                if isCurrentUser {
                    Circle()
                        .fill(Color.green.opacity(0.4))
                        .frame(width: 28, height: 28)
                        .overlay(Text("🙂"))
                } else { Spacer() }
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Theme.background)
    }
}
