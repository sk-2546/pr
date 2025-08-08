import { useState, useEffect } from 'react';
import firestore from '@react-native-firebase/firestore';
import { useAuth } from './useAuth';

interface CallHistoryItem {
  id: string;
  name: string;
  avatar: string;
  type: 'audio' | 'video';
  status: 'incoming' | 'outgoing' | 'missed';
  duration: string;
  time: string;
  timestamp: any;
}

export function useCallHistory() {
  const { user } = useAuth();
  const [callHistory, setCallHistory] = useState<CallHistoryItem[]>([]);

  useEffect(() => {
    if (!user) return;

    const unsubscribe = firestore()
      .collection('calls')
      .where('participants', 'array-contains', user.uid)
      .orderBy('createdAt', 'desc')
      .limit(50)
      .onSnapshot(async (snapshot) => {
        const historyPromises = snapshot.docs.map(async (doc) => {
          const callData = doc.data();
          const otherParticipantId = callData.participants.find((p: string) => p !== user.uid);
          
          if (!otherParticipantId) return null;

          const userDoc = await firestore().collection('users').doc(otherParticipantId).get();
          if (!userDoc.exists) return null;

          const userData = userDoc.data()!;
          
          // Determine call status
          let status: 'incoming' | 'outgoing' | 'missed' = 'outgoing';
          if (callData.callerId !== user.uid) {
            status = callData.status === 'ended' && !callData.answeredAt ? 'missed' : 'incoming';
          }

          // Calculate duration
          let duration = '00:00';
          if (callData.answeredAt && callData.endedAt) {
            const durationMs = callData.endedAt.toMillis() - callData.answeredAt.toMillis();
            const durationSec = Math.floor(durationMs / 1000);
            const minutes = Math.floor(durationSec / 60);
            const seconds = durationSec % 60;
            duration = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
          }

          // Format time
          const time = callData.createdAt?.toDate().toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit',
          }) || '';

          return {
            id: doc.id,
            name: userData.displayName,
            avatar: userData.photoURL,
            type: callData.type,
            status,
            duration,
            time,
            timestamp: callData.createdAt,
          };
        });

        const resolvedHistory = (await Promise.all(historyPromises)).filter(Boolean) as CallHistoryItem[];
        setCallHistory(resolvedHistory);
      });

    return unsubscribe;
  }, [user]);

  return {
    callHistory,
  };
}