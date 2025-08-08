import { useState, useEffect } from 'react';
import * as Notifications from 'expo-notifications';
import messaging from '@react-native-firebase/messaging';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';
import { useAuth } from './useAuth';

// Configure notification behavior
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export function useNotifications() {
  const { user } = useAuth();
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [expoPushToken, setExpoPushToken] = useState<string | null>(null);

  useEffect(() => {
    if (user) {
      setupNotifications();
    }
  }, [user]);

  const setupNotifications = async () => {
    try {
      // Request permissions
      const { status: existingStatus } = await Notifications.getPermissionsAsync();
      let finalStatus = existingStatus;

      if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
      }

      if (finalStatus !== 'granted') {
        console.log('Notification permission not granted');
        return;
      }

      // Get Expo push token
      const token = await Notifications.getExpoPushTokenAsync({
        projectId: 'sk-chat-7be6f',
      });
      setExpoPushToken(token.data);

      // Get FCM token for Android
      if (Platform.OS === 'android') {
        const fcmToken = await messaging().getToken();
        console.log('FCM Token:', fcmToken);
        
        // Save FCM token to user document
        if (user) {
          await firestore().collection('users').doc(user.uid).update({
            fcmToken: fcmToken,
            expoPushToken: token.data,
          });
        }
      }

      // Listen for foreground messages
      const unsubscribe = messaging().onMessage(async (remoteMessage) => {
        console.log('Foreground message:', remoteMessage);
        
        // Show local notification
        await Notifications.scheduleNotificationAsync({
          content: {
            title: remoteMessage.notification?.title || 'New Message',
            body: remoteMessage.notification?.body || 'You have a new message',
            data: remoteMessage.data,
          },
          trigger: null,
        });
      });

      // Handle background messages
      messaging().setBackgroundMessageHandler(async (remoteMessage) => {
        console.log('Background message:', remoteMessage);
      });

      return unsubscribe;
    } catch (error) {
      console.error('Error setting up notifications:', error);
    }
  };

  const toggleNotifications = async () => {
    const newValue = !notificationsEnabled;
    setNotificationsEnabled(newValue);
    
    try {
      await AsyncStorage.setItem('notificationsEnabled', JSON.stringify(newValue));
      
      if (newValue) {
        await setupNotifications();
      }
    } catch (error) {
      console.error('Error toggling notifications:', error);
    }
  };

  const sendPushNotification = async (targetUserId: string, title: string, body: string, data?: any) => {
    try {
      const userDoc = await firestore().collection('users').doc(targetUserId).get();
      if (!userDoc.exists) return;

      const userData = userDoc.data()!;
      const fcmToken = userData.fcmToken;

      if (fcmToken) {
        // Send FCM notification
        await messaging().sendMessage({
          to: fcmToken,
          notification: {
            title,
            body,
          },
          data: data || {},
        });
      }
    } catch (error) {
      console.error('Error sending push notification:', error);
    }
  };

  return {
    notificationsEnabled,
    expoPushToken,
    toggleNotifications,
    sendPushNotification,
  };
}