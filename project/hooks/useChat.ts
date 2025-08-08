import { useState, useEffect } from 'react';
import firestore from '@react-native-firebase/firestore';
import database from '@react-native-firebase/database';
import { useAuth } from './useAuth';

interface Message {
  id: string;
  text: string;
  senderId: string;
  timestamp: any;
  readAt?: any;
  deliveredAt?: any;
  status: 'sending' | 'sent' | 'delivered' | 'read';
}

interface ChatInfo {
  name: string;
  avatar: string;
  participants: string[];
}

export function useChat(chatId: string) {
  const { user } = useAuth();
  const [messages, setMessages] = useState<Message[]>([]);
  const [chatInfo, setChatInfo] = useState<ChatInfo | null>(null);
  const [isTyping, setIsTyping] = useState(false);
  const [userStatus, setUserStatus] = useState('offline');

  useEffect(() => {
    if (!user || !chatId) return;

    // Load chat info
    loadChatInfo();

    // Listen to messages
    const unsubscribeMessages = firestore()
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', 'asc')
      .onSnapshot((snapshot) => {
        const messageList: Message[] = [];
        
        snapshot.forEach((doc) => {
          const data = doc.data();
          messageList.push({
            id: doc.id,
            text: data.text,
            senderId: data.senderId,
            timestamp: data.timestamp,
            readAt: data.readAt,
            deliveredAt: data.deliveredAt,
            status: getMessageStatus(data, user.uid),
          });
        });
        
        setMessages(messageList);
      });

    // Listen to typing indicator
    const typingRef = database().ref(`/typing/${chatId}`);
    const unsubscribeTyping = typingRef.on('value', (snapshot) => {
      const typingData = snapshot.val();
      if (typingData) {
        const otherUserTyping = Object.keys(typingData).some(
          (userId) => userId !== user.uid && typingData[userId]
        );
        setIsTyping(otherUserTyping);
      } else {
        setIsTyping(false);
      }
    });

    return () => {
      unsubscribeMessages();
      database().ref(`/typing/${chatId}`).off('value', unsubscribeTyping);
    };
  }, [user, chatId]);

  const loadChatInfo = async () => {
    try {
      const chatDoc = await firestore().collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return;

      const chatData = chatDoc.data()!;
      const otherParticipantId = chatData.participants.find((p: string) => p !== user?.uid);
      
      if (otherParticipantId) {
        const userDoc = await firestore().collection('users').doc(otherParticipantId).get();
        if (userDoc.exists) {
          const userData = userDoc.data()!;
          setChatInfo({
            name: userData.displayName,
            avatar: userData.photoURL,
            participants: chatData.participants,
          });

          // Listen to user status
          const statusRef = database().ref(`/status/${otherParticipantId}`);
          statusRef.on('value', (snapshot) => {
            const status = snapshot.val();
            setUserStatus(status?.state || 'offline');
          });
        }
      }
    } catch (error) {
      console.error('Error loading chat info:', error);
    }
  };

  const sendMessage = async (text: string) => {
    if (!user || !chatId) return;

    try {
      const messageRef = firestore()
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

      await messageRef.set({
        text,
        senderId: user.uid,
        timestamp: firestore.FieldValue.serverTimestamp(),
        deliveredAt: firestore.FieldValue.serverTimestamp(),
        readAt: null,
      });

      // Update chat's last message
      await firestore().collection('chats').doc(chatId).update({
        lastMessage: text,
        lastUpdated: firestore.FieldValue.serverTimestamp(),
      });

      // Clear typing indicator
      await database().ref(`/typing/${chatId}/${user.uid}`).set(false);
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  };

  const markAsRead = async () => {
    if (!user || !chatId) return;

    try {
      const unreadMessages = messages.filter(
        (msg) => msg.senderId !== user.uid && !msg.readAt
      );

      const batch = firestore().batch();
      unreadMessages.forEach((msg) => {
        const msgRef = firestore()
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(msg.id);
        batch.update(msgRef, { readAt: firestore.FieldValue.serverTimestamp() });
      });

      if (unreadMessages.length > 0) {
        await batch.commit();
      }

      // Reset unread count
      await firestore().collection('chats').doc(chatId).update({
        [`unreadCounts.${user.uid}`]: 0,
      });
    } catch (error) {
      console.error('Error marking messages as read:', error);
    }
  };

  const getMessageStatus = (messageData: any, currentUserId: string): Message['status'] => {
    if (messageData.senderId !== currentUserId) return 'read';
    
    if (messageData.readAt) return 'read';
    if (messageData.deliveredAt) return 'delivered';
    if (messageData.timestamp) return 'sent';
    return 'sending';
  };

  return {
    messages,
    chatInfo,
    sendMessage,
    isTyping,
    userStatus,
    markAsRead,
  };
}