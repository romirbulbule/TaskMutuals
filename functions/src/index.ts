import {onDocumentCreated} from 'firebase-functions/v2/firestore';
import {onDocumentUpdated} from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';

admin.initializeApp();

/**
 * Cloud Function triggered when a new message is added to a chat
 * Sends push notification to the recipient
 */
export const sendMessageNotification = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log('No data associated with the event');
      return;
    }

    const message = snapshot.data();
    const chatId = event.params.chatId;
    const senderId = message.senderId;
    const messageText = message.text;

    console.log(`📨 New message in chat ${chatId} from ${senderId}`);

    try {
      // Get chat document to find recipient
      const chatDoc = await admin.firestore()
        .collection('chats')
        .doc(chatId)
        .get();

      if (!chatDoc.exists) {
        console.error('❌ Chat document not found');
        return;
      }

      const chat = chatDoc.data();
      const participants = chat?.participants || [];
      const recipientId = participants.find((id: string) => id !== senderId);

      if (!recipientId) {
        console.error('❌ Recipient not found');
        return;
      }

      // Get sender's profile
      const senderDoc = await admin.firestore()
        .collection('users')
        .doc(senderId)
        .get();

      const sender = senderDoc.data();
      const senderName = sender
        ? `${sender.firstName} ${sender.lastName}`
        : 'Someone';

      // Get recipient's FCM token
      const recipientDoc = await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .get();

      const recipient = recipientDoc.data();
      const fcmToken = recipient?.fcmToken;

      if (!fcmToken) {
        console.log(`⚠️ Recipient ${recipientId} has no FCM token`);
        return;
      }

      // Send push notification
      const payload: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: senderName,
          body: messageText,
        },
        data: {
          chatId: chatId,
          senderId: senderId,
          senderName: senderName,
          type: 'chat_message',
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              alert: {
                title: senderName,
                body: messageText,
              },
              badge: 1,
              sound: 'default',
              'content-available': 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(payload);
      console.log(`✅ Notification sent successfully: ${response}`);

    } catch (error) {
      console.error('❌ Error sending notification:', error);
    }
  }
);

/**
 * Cloud Function to update badge count when chat unread count changes
 */
export const updateBadgeCount = onDocumentUpdated(
  'chats/{chatId}',
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (!beforeData || !afterData) {
      return;
    }

    const unreadCountBefore = beforeData.unreadCount || {};
    const unreadCountAfter = afterData.unreadCount || {};

    // Check if unread count changed for any user
    const participants = afterData.participants || [];

    for (const userId of participants) {
      const countBefore = unreadCountBefore[userId] || 0;
      const countAfter = unreadCountAfter[userId] || 0;

      if (countBefore !== countAfter) {
        console.log(`🔔 Badge count changed for user ${userId}: ${countBefore} → ${countAfter}`);

        // Calculate total unread count across all chats
        const totalUnread = await calculateTotalUnreadCount(userId);

        // Update badge via silent push
        await updateUserBadge(userId, totalUnread);
      }
    }
  }
);

/**
 * Helper function to calculate total unread count for a user
 */
async function calculateTotalUnreadCount(userId: string): Promise<number> {
  const chatsSnapshot = await admin.firestore()
    .collection('chats')
    .where('participants', 'array-contains', userId)
    .get();

  let total = 0;
  chatsSnapshot.forEach(doc => {
    const chat = doc.data();
    const unreadCount = chat.unreadCount?.[userId] || 0;
    total += unreadCount;
  });

  return total;
}

/**
 * Helper function to update user's badge via silent push
 */
async function updateUserBadge(userId: string, badgeCount: number): Promise<void> {
  const userDoc = await admin.firestore()
    .collection('users')
    .doc(userId)
    .get();

  const user = userDoc.data();
  const fcmToken = user?.fcmToken;

  if (!fcmToken) {
    console.log(`⚠️ User ${userId} has no FCM token for badge update`);
    return;
  }

  const payload: admin.messaging.Message = {
    token: fcmToken,
    apns: {
      headers: {
        'apns-priority': '5',
      },
      payload: {
        aps: {
          badge: badgeCount,
          'content-available': 1,
        },
      },
    },
    data: {
      type: 'badge_update',
      badgeCount: badgeCount.toString(),
    },
  };

  try {
    await admin.messaging().send(payload);
    console.log(`✅ Badge updated to ${badgeCount} for user ${userId}`);
  } catch (error) {
    console.error(`❌ Error updating badge for user ${userId}:`, error);
  }
}
