//
//  NotificationsView.swift
//  TaskMutual
//
//  View for displaying user notifications
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var notificationService = NotificationService()
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.accent)
                    }
                    Spacer()
                    Text("Notifications")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if !notificationService.notifications.isEmpty {
                        Button(action: markAllAsRead) {
                            Text("Mark All Read")
                                .font(.caption)
                                .foregroundColor(Theme.accent)
                        }
                    } else {
                        Spacer().frame(width: 20)
                    }
                }
                .padding()

                if notificationService.notifications.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No notifications")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(notificationService.notifications) { notification in
                                NotificationCard(
                                    notification: notification,
                                    onTap: {
                                        handleNotificationTap(notification)
                                    },
                                    onDelete: {
                                        deleteNotification(notification)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            if let userId = userVM.profile?.id {
                notificationService.startListeningToNotifications(userId: userId)
            }
        }
    }

    private func markAllAsRead() {
        guard let userId = userVM.profile?.id else { return }

        notificationService.markAllAsRead(userId: userId) { result in
            if case .failure(let error) = result {
                print("❌ Failed to mark all as read: \(error.localizedDescription)")
            }
        }
    }

    private func handleNotificationTap(_ notification: AppNotification) {
        // Mark as read
        if let notificationId = notification.id, !notification.isRead {
            notificationService.markAsRead(notificationId: notificationId) { _ in }
        }

        // TODO: Navigate to relevant screen based on notification type
        // This would require updating the navigation system
    }

    private func deleteNotification(_ notification: AppNotification) {
        guard let notificationId = notification.id else { return }

        notificationService.deleteNotification(notificationId: notificationId) { result in
            if case .failure(let error) = result {
                print("❌ Failed to delete notification: \(error.localizedDescription)")
            }
        }
    }
}

struct NotificationCard: View {
    let notification: AppNotification
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.2))
                    .clipShape(Circle())

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(notification.body)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)

                    Text(notification.timeAgo)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            .background(notification.isRead ? Color.white.opacity(0.05) : Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var iconColor: Color {
        switch notification.type {
        case .newResponse: return .blue
        case .responseAccepted: return .green
        case .taskCompleted: return .purple
        case .newMessage: return .orange
        case .paymentReceived: return .green
        case .newRating: return .yellow
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(UserViewModel())
}
