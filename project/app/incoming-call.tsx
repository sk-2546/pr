import React, { useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Image,
  Vibration,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { Phone, PhoneOff } from 'lucide-react-native';
import { Audio } from 'expo-av';
import { useTheme } from '@/hooks/useTheme';
import { CallService } from '@/services/CallService';

export default function IncomingCallScreen() {
  const { callId, callerName, callerAvatar, callType } = useLocalSearchParams<{
    callId: string;
    callerName: string;
    callerAvatar: string;
    callType: string;
  }>();
  const { colors } = useTheme();

  useEffect(() => {
    // Start ringtone and vibration
    playRingtone();
    startVibration();

    return () => {
      stopRingtone();
      Vibration.cancel();
    };
  }, []);

  const playRingtone = async () => {
    try {
      const { sound } = await Audio.Sound.createAsync(
        require('@/assets/sounds/ringtone.mp3'),
        { shouldPlay: true, isLooping: true }
      );
      // Store sound reference for cleanup
    } catch (error) {
      console.log('Error playing ringtone:', error);
    }
  };

  const stopRingtone = async () => {
    // Stop ringtone logic
  };

  const startVibration = () => {
    const pattern = [1000, 1000];
    Vibration.vibrate(pattern, true);
  };

  const handleAcceptCall = async () => {
    try {
      Vibration.cancel();
      stopRingtone();
      await CallService.acceptCall(callId as string);
      router.replace(`/call/${callId}`);
    } catch (error) {
      Alert.alert('Error', 'Failed to accept call');
    }
  };

  const handleRejectCall = async () => {
    try {
      Vibration.cancel();
      stopRingtone();
      await CallService.rejectCall(callId as string);
      router.back();
    } catch (error) {
      Alert.alert('Error', 'Failed to reject call');
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.callerInfo}>
          <Image
            source={{ uri: callerAvatar }}
            style={styles.callerAvatar}
          />
          <Text style={styles.callerName}>{callerName}</Text>
          <Text style={styles.callType}>
            Incoming {callType} call...
          </Text>
        </View>

        <View style={styles.callActions}>
          <TouchableOpacity
            style={[styles.callButton, styles.rejectButton]}
            onPress={handleRejectCall}
          >
            <PhoneOff size={32} color="white" />
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.callButton, styles.acceptButton]}
            onPress={handleAcceptCall}
          >
            <Phone size={32} color="white" />
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.9)',
  },
  content: {
    flex: 1,
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 80,
  },
  callerInfo: {
    alignItems: 'center',
  },
  callerAvatar: {
    width: 150,
    height: 150,
    borderRadius: 75,
    marginBottom: 24,
    borderWidth: 4,
    borderColor: 'white',
  },
  callerName: {
    color: 'white',
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 8,
    textAlign: 'center',
  },
  callType: {
    color: 'white',
    fontSize: 18,
    textAlign: 'center',
  },
  callActions: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
    paddingHorizontal: 80,
  },
  callButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  acceptButton: {
    backgroundColor: '#22c55e',
  },
  rejectButton: {
    backgroundColor: '#ef4444',
  },
});