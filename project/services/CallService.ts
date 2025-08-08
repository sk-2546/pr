import firestore from '@react-native-firebase/firestore';
import { router } from 'expo-router';
import { Alert } from 'react-native';

export class CallService {
  static async startCall(chatId: string, type: 'audio' | 'video') {
    try {
      const chatDoc = await firestore().collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        throw new Error('Chat not found');
      }

      const chatData = chatDoc.data()!;
      const calleeId = chatData.participants.find((p: string) => p !== auth().currentUser?.uid);
      
      if (!calleeId) {
        throw new Error('Callee not found');
      }

      // Create call document
      const callRef = firestore().collection('calls').doc();
      await callRef.set({
        callerId: auth().currentUser!.uid,
        calleeId,
        type,
        status: 'ringing',
        active: true,
        createdAt: firestore.FieldValue.serverTimestamp(),
        participants: [auth().currentUser!.uid, calleeId],
      });

      // Navigate to call screen
      router.push(`/call/${callRef.id}`);
    } catch (error) {
      console.error('Error starting call:', error);
      Alert.alert('Error', 'Failed to start call');
    }
  }

  static async acceptCall(callId: string) {
    try {
      await firestore().collection('calls').doc(callId).update({
        status: 'connected',
        answeredAt: firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      console.error('Error accepting call:', error);
      throw error;
    }
  }

  static async rejectCall(callId: string) {
    try {
      await firestore().collection('calls').doc(callId).update({
        status: 'ended',
        endedAt: firestore.FieldValue.serverTimestamp(),
        active: false,
      });
    } catch (error) {
      console.error('Error rejecting call:', error);
      throw error;
    }
  }

  static async endCall(callId: string) {
    try {
      await firestore().collection('calls').doc(callId).update({
        status: 'ended',
        endedAt: firestore.FieldValue.serverTimestamp(),
        active: false,
      });
    } catch (error) {
      console.error('Error ending call:', error);
      throw error;
    }
  }
}