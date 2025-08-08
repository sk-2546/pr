import { useState, useEffect } from 'react';
import firestore from '@react-native-firebase/firestore';
import database from '@react-native-firebase/database';
import { useAuth } from './useAuth';

interface Chat {
  id: string;
  name: string;
  avatar: string;
  lastMessage: string;
  timestamp: any;
  unreadCount: number;
  isGPT?: boolean;
  isOnline?: boolean;
}

export function useChatList() {
  const { user } = useAuth();
  const [chats, setChats] = useState<Chat[]>([]);

  useEffect(() => {
    if (!user) return;

    // Add GPT chat as first item
    const gptChat: Chat = {
      id: 'shubham-gpt',
      name: 'ShubhamGPT',
      avatar: 'https://img.icons8.com/fluency/48/bot.png',
      lastMessage: 'Ask me anything!',
      timestamp: null,
      unreadCount: 0,
      isGPT: true,
      isOnline: true,
    };

    setChats([gptChat]);

    // Listen to user's chats
    const unsubscribe = firestore()
      .collection('chats')
      .where('participants', 'array-contains', user.uid)
      .orderBy('lastUpdated', 'desc')
      .onSnapshot(async (snapshot) => {
        const chatPromises = snapshot.docs.map(async (doc) => {
          const chatData = doc.data();
          const otherParticipantId = chatData.participants.find((p: string) => p !== user.uid);
          
          if (!otherParticipantId) return null;

          const userDoc = await firestore().collection('users').doc(otherParticipantId).get();
          if (!userDoc.exists) return null;

          const userData = userDoc.data()!;
          
          // Check online status
          const statusSnapshot = await database().ref(`/status/${otherParticipantId}`).once('value');
          const status = statusSnapshot.val();
          const isOnline = status?.state === 'online';

          return {
            id: doc.id,
            name: userData.displayName,
            avatar: userData.photoURL,
            lastMessage: chatData.lastMessage || 'No messages yet',
            timestamp: chatData.lastUpdated,
            unreadCount: chatData.unreadCounts?.[user.uid] || 0,
            isOnline,
          };
        });

        const resolvedChats = (await Promise.all(chatPromises)).filter(Boolean) as Chat[];
        setChats([gptChat, ...resolvedChats]);
      });

    return unsubscribe;
  }, [user]);

  const addNewChat = async (email: string) => {
    if (!user) throw new Error('User not authenticated');
    
    if (email === user.email) {
      throw new Error('You cannot add yourself');
    }

    try {
      const userQuery = await firestore()
        .collection('users')
        .where('email', '==', email)
        .get();

      if (userQuery.empty) {
        throw new Error('User not found');
      }

      const targetUser = userQuery.docs[0].data();
      const chatId = [user.uid, targetUser.uid].sort().join('_');
      
      const chatRef = firestore().collection('chats').doc(chatId);
      const chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        await chatRef.set({
          participants: [user.uid, targetUser.uid],
          createdAt: firestore.FieldValue.serverTimestamp(),
          lastUpdated: firestore.FieldValue.serverTimestamp(),
          unreadCounts: {
            [user.uid]: 0,
            [targetUser.uid]: 0,
          },
        });
      }
    } catch (error: any) {
      throw new Error(error.message);
    }
  };

  return {
    chats,
    addNewChat,
  };
}