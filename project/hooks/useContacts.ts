import { useState, useEffect } from 'react';
import firestore from '@react-native-firebase/firestore';
import database from '@react-native-firebase/database';
import { useAuth } from './useAuth';

interface Contact {
  id: string;
  name: string;
  email: string;
  photoURL: string;
  isOnline: boolean;
  chatId: string;
}

export function useContacts() {
  const { user } = useAuth();
  const [contacts, setContacts] = useState<Contact[]>([]);

  useEffect(() => {
    if (!user) return;

    // Get all users that have chats with current user
    const unsubscribe = firestore()
      .collection('chats')
      .where('participants', 'array-contains', user.uid)
      .onSnapshot(async (snapshot) => {
        const contactPromises = snapshot.docs.map(async (doc) => {
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
            id: otherParticipantId,
            name: userData.displayName,
            email: userData.email,
            photoURL: userData.photoURL,
            isOnline,
            chatId: doc.id,
          };
        });

        const resolvedContacts = (await Promise.all(contactPromises)).filter(Boolean) as Contact[];
        setContacts(resolvedContacts);
      });

    return unsubscribe;
  }, [user]);

  return {
    contacts,
  };
}