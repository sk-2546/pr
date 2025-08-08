import database from '@react-native-firebase/database';
import firestore from '@react-native-firebase/firestore';
import { AppState } from 'react-native';

export class PresenceService {
  private static userId: string | null = null;
  private static isInitialized = false;

  static async initialize(userId: string) {
    if (this.isInitialized) return;
    
    this.userId = userId;
    this.isInitialized = true;

    try {
      const userStatusDatabaseRef = database().ref(`/status/${userId}`);
      const isOfflineForDatabase = {
        state: 'offline',
        last_changed: firestore.FieldValue.serverTimestamp(),
      };
      const isOnlineForDatabase = {
        state: 'online',
        last_changed: firestore.FieldValue.serverTimestamp(),
      };

      // Set up presence system
      const connectedRef = database().ref('.info/connected');
      connectedRef.on('value', (snapshot) => {
        if (snapshot.val() === false) {
          return;
        }

        // Set offline status when disconnected
        userStatusDatabaseRef.onDisconnect().set(isOfflineForDatabase).then(() => {
          // Set online status
          userStatusDatabaseRef.set(isOnlineForDatabase);
        });
      });

      // Handle app state changes
      AppState.addEventListener('change', (nextAppState) => {
        if (nextAppState === 'active') {
          userStatusDatabaseRef.set(isOnlineForDatabase);
        } else if (nextAppState === 'background' || nextAppState === 'inactive') {
          userStatusDatabaseRef.set(isOfflineForDatabase);
        }
      });

      // Set initial online status
      await userStatusDatabaseRef.set(isOnlineForDatabase);
    } catch (error) {
      console.error('Error initializing presence:', error);
    }
  }

  static async setTyping(chatId: string, isTyping: boolean) {
    if (!this.userId) return;

    try {
      await database().ref(`/typing/${chatId}/${this.userId}`).set(isTyping);
      
      if (isTyping) {
        // Auto-clear typing after 3 seconds
        setTimeout(() => {
          database().ref(`/typing/${chatId}/${this.userId}`).set(false);
        }, 3000);
      }
    } catch (error) {
      console.error('Error setting typing status:', error);
    }
  }

  static async cleanup() {
    if (!this.userId) return;

    try {
      await database().ref(`/status/${this.userId}`).set({
        state: 'offline',
        last_changed: firestore.FieldValue.serverTimestamp(),
      });
      
      this.isInitialized = false;
      this.userId = null;
    } catch (error) {
      console.error('Error cleaning up presence:', error);
    }
  }
}