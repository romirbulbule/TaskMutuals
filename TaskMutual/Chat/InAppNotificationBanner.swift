//
//  InAppNotificationBanner.swift
//  TaskMutual
//
//  Custom notification banner that appears at the top of the screen
//  Supports tap-to-navigate, swipe-up-to-dismiss, and swipe-down-for-reply
//

import SwiftUI
import FirebaseAuth

struct InAppNotificationBanner: View {
    let data: InAppNotificationData
    let onTap: () -> Void
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -200
    @State private var showReply = false
    @State private var replyText = ""
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Background blur when showing reply
            if showReply {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            showReply = false
                        }
                    }
            }

            VStack(spacing: 0) {
                // Banner
                bannerContent
                    .offset(y: offset + dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Only allow vertical dragging
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                let velocity = value.predictedEndTranslation.height - value.translation.height

                                if value.translation.height < -50 || velocity < -100 {
                                    // Swipe up - dismiss
                                    withAnimation(.spring(response: 0.3)) {
                                        offset = -200
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onDismiss()
                                    }
                                } else if value.translation.height > 50 || velocity > 100 {
                                    // Swipe down - show reply
                                    withAnimation(.spring(response: 0.3)) {
                                        showReply = true
                                        dragOffset = 0
                                    }
                                } else {
                                    // Return to original position
                                    withAnimation(.spring(response: 0.3)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        // Tap to navigate
                        HapticsManager.shared.light()
                        withAnimation(.spring(response: 0.3)) {
                            offset = -200
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onTap()
                        }
                    }

                // Reply view
                if showReply {
                    replyView
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
            }
        }
        .onAppear {
            // Animate in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                offset = 0
            }

            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                if !showReply {
                    withAnimation(.spring(response: 0.3)) {
                        offset = -200
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }
            }
        }
    }

    private var bannerContent: some View {
        HStack(spacing: 12) {
            // Profile picture
            if let urlString = data.profileImageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    default:
                        Circle()
                            .fill(LinearGradient(
                                colors: [Theme.accent.opacity(0.6), Theme.accent.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(data.senderName.prefix(1).uppercased())
                                    .font(.system(size: 18, weight: .semibold))
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
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(data.senderName.prefix(1).uppercased())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(data.senderName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                Text(data.message)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Close button
            Button(action: {
                HapticsManager.shared.light()
                withAnimation(.spring(response: 0.3)) {
                    offset = -200
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 12)
        .padding(.top, 50) // Below status bar
    }

    private var replyView: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Reply to \(data.senderName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showReply = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                }
            }

            // Original message
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Theme.accent)
                    .frame(width: 3)

                Text(data.message)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Spacer()
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Reply input
            HStack(spacing: 12) {
                TextField("Message...", text: $replyText)
                    .font(.system(size: 15))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )

                Button(action: sendReply) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(replyText.isEmpty ? .secondary : Theme.accent)
                }
                .disabled(replyText.isEmpty)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        )
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private func sendReply() {
        guard !replyText.isEmpty else { return }

        HapticsManager.shared.medium()

        // Send the reply message
        let messagesVM = MessagesViewModel(chatId: data.chatId)
        messagesVM.send(text: replyText, senderId: Auth.auth().currentUser?.uid ?? "")

        // Dismiss reply view and banner
        withAnimation(.spring(response: 0.3)) {
            showReply = false
            offset = -200
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

#Preview {
    InAppNotificationBanner(
        data: InAppNotificationData(
            senderName: "John Doe",
            message: "Hey! How's it going? I wanted to ask you about that project we discussed earlier.",
            chatId: "test-chat-id",
            senderId: "test-sender-id",
            profileImageURL: nil
        ),
        onTap: {
            print("Tapped banner")
        },
        onDismiss: {
            print("Dismissed banner")
        }
    )
}
