import * as Notifications from 'expo-notifications';
import messaging from '@react-native-firebase/messaging';
import firestore from '@react-native-firebase/firestore';
import { Platform } from 'react-native';
import { router } from 'expo-router';

export class NotificationService {
  static async initialize() {
    try {
      // Request permissions
      const { status } = await Notifications.requestPermissionsAsync();
      if (status !== 'granted') {
        console.log('Notification permission not granted');
        return;
      }

      // Configure notification channel for Android
      if (Platform.OS === 'android') {
        await Notifications.setNotificationChannelAsync('messages', {
          name: 'Messages',
          importance: Notifications.AndroidImportance.HIGH,
          sound: 'default',
          vibrationPattern: [0, 250, 250, 250],
        });

        await Notifications.setNotificationChannelAsync('calls', {
          name: 'Calls',
          importance: Notifications.AndroidImportance.HIGH,
          sound: 'ringtone.wav',
          vibrationPattern: [0, 1000, 1000, 1000],
        });
      }

      // Get FCM token
      const fcmToken = await messaging().getToken();
      console.log('FCM Token:', fcmToken);

      // Save token to user document
      const user = auth().currentUser;
      if (user) {
        await firestore().collection('users').doc(user.uid).update({
          fcmToken,
          lastTokenUpdate: firestore.FieldValue.serverTimestamp(),
        });
      }

      // Listen for token refresh
      messaging().onTokenRefresh(async (token) => {
        console.log('FCM Token refreshed:', token);
        if (user) {
          await firestore().collection('users').doc(user.uid).update({
            fcmToken: token,
            lastTokenUpdate: firestore.FieldValue.serverTimestamp(),
          });
        }
      });

      // Handle foreground messages
      messaging().onMessage(async (remoteMessage) => {
        console.log('Foreground message:', remoteMessage);
        
        if (remoteMessage.data?.type === 'call') {
          // Handle incoming call notification
          this.handleIncomingCallNotification(remoteMessage);
        } else {
          // Handle regular message notification
          await Notifications.scheduleNotificationAsync({
            content: {
              title: remoteMessage.notification?.title || 'New Message',
              body: remoteMessage.notification?.body || 'You have a new message',
              data: remoteMessage.data,
            },
            trigger: null,
          });
        }
      });

      // Handle notification taps
      Notifications.addNotificationResponseReceivedListener((response) => {
        const data = response.notification.request.content.data;
        
        if (data?.chatId) {
          router.push(`/chat/${data.chatId}`);
        } else if (data?.callId) {
          router.push(`/incoming-call?callId=${data.callId}&callerName=${data.callerName}&callerAvatar=${data.callerAvatar}&callType=${data.callType}`);
        }
      });

    } catch (error) {
      console.error('Error initializing notifications:', error);
    }
  }

  static async sendMessageNotification(targetUserId: string, senderName: string, messageText: string, chatId: string) {
    try {
      const userDoc = await firestore().collection('users').doc(targetUserId).get();
      if (!userDoc.exists) return;

      const userData = userDoc.data()!;
      const fcmToken = userData.fcmToken;

      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: senderName,
            body: messageText,
          },
          data: {
            type: 'message',
            chatId,
            senderId: auth().currentUser!.uid,
          },
          android: {
            channelId: 'messages',
            priority: 'high',
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
              },
            },
          },
        };

        // Send via Firebase Cloud Functions or your backend
        console.log('Sending message notification:', message);
      }
    } catch (error) {
      console.error('Error sending message notification:', error);
    }
  }

  static async sendCallNotification(targetUserId: string, callerName: string, callerAvatar: string, callType: 'audio' | 'video', callId: string) {
    try {
      const userDoc = await firestore().collection('users').doc(targetUserId).get();
      if (!userDoc.exists) return;

      const userData = userDoc.data()!;
      const fcmToken = userData.fcmToken;

      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: `Incoming ${callType} call`,
            body: `${callerName} is calling you`,
          },
          data: {
            type: 'call',
            callId,
            callerName,
            callerAvatar,
            callType,
          },
          android: {
            channelId: 'calls',
            priority: 'high',
            ttl: 30000, // 30 seconds
          },
          apns: {
            payload: {
              aps: {
                sound: 'ringtone.wav',
                badge: 1,
                category: 'CALL_INVITATION',
              },
            },
          },
        };

        console.log('Sending call notification:', message);
      }
    } catch (error) {
      console.error('Error sending call notification:', error);
    }
  }

  static handleIncomingCallNotification(remoteMessage: any) {
    const { callId, callerName, callerAvatar, callType } = remoteMessage.data;
    
    // Navigate to incoming call screen
    router.push(`/incoming-call?callId=${callId}&callerName=${callerName}&callerAvatar=${callerAvatar}&callType=${callType}`);
  }
}