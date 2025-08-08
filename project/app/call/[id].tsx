import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Image,
  Alert,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import { 
  Phone, 
  PhoneOff, 
  Video, 
  VideoOff, 
  Mic, 
  MicOff, 
  RotateCcw,
  Speaker
} from 'lucide-react-native';
import { RTCView } from 'react-native-webrtc';
import { useTheme } from '@/hooks/useTheme';
import { useCall } from '@/hooks/useCall';
import { CallService } from '@/services/CallService';

const { width, height } = Dimensions.get('window');

export default function CallScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { colors } = useTheme();
  const { 
    callState, 
    localStream, 
    remoteStream, 
    isMuted, 
    isVideoEnabled, 
    isSpeakerEnabled,
    toggleMute, 
    toggleVideo, 
    toggleSpeaker,
    switchCamera,
    endCall 
  } = useCall(id as string);

  const handleEndCall = () => {
    endCall();
    router.back();
  };

  const renderVideoCall = () => (
    <View style={styles.videoContainer}>
      {/* Remote Video */}
      {remoteStream && (
        <RTCView
          streamURL={remoteStream.toURL()}
          style={styles.remoteVideo}
          objectFit="cover"
        />
      )}
      
      {/* Local Video */}
      {localStream && isVideoEnabled && (
        <RTCView
          streamURL={localStream.toURL()}
          style={styles.localVideo}
          objectFit="cover"
          mirror={true}
        />
      )}
      
      {/* Call Info Overlay */}
      <View style={styles.callInfoOverlay}>
        <Text style={styles.callerName}>{callState.remoteUser?.name}</Text>
        <Text style={styles.callDuration}>{callState.duration}</Text>
      </View>
    </View>
  );

  const renderAudioCall = () => (
    <View style={styles.audioContainer}>
      <Image
        source={{ uri: callState.remoteUser?.avatar }}
        style={styles.audioAvatar}
      />
      <Text style={styles.audioCallerName}>{callState.remoteUser?.name}</Text>
      <Text style={styles.audioCallStatus}>{callState.status}</Text>
      <Text style={styles.callDuration}>{callState.duration}</Text>
    </View>
  );

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: '#000' }]}>
      {callState.type === 'video' ? renderVideoCall() : renderAudioCall()}
      
      {/* Call Controls */}
      <View style={styles.controlsContainer}>
        <TouchableOpacity
          style={[styles.controlButton, { backgroundColor: isMuted ? colors.error : 'rgba(255,255,255,0.2)' }]}
          onPress={toggleMute}
        >
          {isMuted ? (
            <MicOff size={24} color="white" />
          ) : (
            <Mic size={24} color="white" />
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.controlButton, { backgroundColor: colors.error }]}
          onPress={handleEndCall}
        >
          <PhoneOff size={28} color="white" />
        </TouchableOpacity>

        {callState.type === 'video' && (
          <>
            <TouchableOpacity
              style={[styles.controlButton, { backgroundColor: isVideoEnabled ? 'rgba(255,255,255,0.2)' : colors.error }]}
              onPress={toggleVideo}
            >
              {isVideoEnabled ? (
                <Video size={24} color="white" />
              ) : (
                <VideoOff size={24} color="white" />
              )}
            </TouchableOpacity>

            <TouchableOpacity
              style={[styles.controlButton, { backgroundColor: 'rgba(255,255,255,0.2)' }]}
              onPress={switchCamera}
            >
              <RotateCcw size={24} color="white" />
            </TouchableOpacity>
          </>
        )}

        <TouchableOpacity
          style={[styles.controlButton, { backgroundColor: isSpeakerEnabled ? colors.primary : 'rgba(255,255,255,0.2)' }]}
          onPress={toggleSpeaker}
        >
          <Speaker size={24} color="white" />
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  videoContainer: {
    flex: 1,
    position: 'relative',
  },
  remoteVideo: {
    width: width,
    height: height,
  },
  localVideo: {
    position: 'absolute',
    top: 60,
    right: 20,
    width: 120,
    height: 160,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: 'white',
  },
  callInfoOverlay: {
    position: 'absolute',
    top: 60,
    left: 20,
    backgroundColor: 'rgba(0,0,0,0.5)',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  callerName: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  callDuration: {
    color: 'white',
    fontSize: 14,
    marginTop: 2,
  },
  audioContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  audioAvatar: {
    width: 150,
    height: 150,
    borderRadius: 75,
    marginBottom: 24,
    borderWidth: 4,
    borderColor: 'white',
  },
  audioCallerName: {
    color: 'white',
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 8,
    textAlign: 'center',
  },
  audioCallStatus: {
    color: 'white',
    fontSize: 18,
    marginBottom: 16,
    textAlign: 'center',
  },
  controlsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
    paddingBottom: 40,
    gap: 20,
  },
  controlButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
  },
});