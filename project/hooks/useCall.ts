import { useState, useEffect } from 'react';
import { RTCPeerConnection, RTCSessionDescription, RTCIceCandidate, mediaDevices } from 'react-native-webrtc';
import firestore from '@react-native-firebase/firestore';
import { useAuth } from './useAuth';

interface CallState {
  status: 'idle' | 'ringing' | 'connecting' | 'connected' | 'ended';
  type: 'audio' | 'video';
  duration: string;
  remoteUser?: {
    name: string;
    avatar: string;
  };
}

const servers = {
  iceServers: [
    { urls: 'stun:stun1.l.google.com:19302' },
    { urls: 'stun:stun2.l.google.com:19302' },
  ],
};

export function useCall(callId: string) {
  const { user } = useAuth();
  const [callState, setCallState] = useState<CallState>({
    status: 'idle',
    type: 'audio',
    duration: '00:00',
  });
  const [localStream, setLocalStream] = useState<any>(null);
  const [remoteStream, setRemoteStream] = useState<any>(null);
  const [peerConnection, setPeerConnection] = useState<RTCPeerConnection | null>(null);
  const [isMuted, setIsMuted] = useState(false);
  const [isVideoEnabled, setIsVideoEnabled] = useState(true);
  const [isSpeakerEnabled, setIsSpeakerEnabled] = useState(false);
  const [callStartTime, setCallStartTime] = useState<number | null>(null);

  useEffect(() => {
    if (callId) {
      initializeCall();
    }

    return () => {
      cleanup();
    };
  }, [callId]);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    
    if (callState.status === 'connected' && callStartTime) {
      interval = setInterval(() => {
        const elapsed = Math.floor((Date.now() - callStartTime) / 1000);
        const minutes = Math.floor(elapsed / 60);
        const seconds = elapsed % 60;
        setCallState(prev => ({
          ...prev,
          duration: `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`,
        }));
      }, 1000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [callState.status, callStartTime]);

  const initializeCall = async () => {
    try {
      // Load call document
      const callDoc = await firestore().collection('calls').doc(callId).get();
      if (!callDoc.exists) return;

      const callData = callDoc.data()!;
      setCallState(prev => ({
        ...prev,
        type: callData.type,
        status: callData.status,
      }));

      // Load remote user info
      const remoteUserId = callData.callerId === user?.uid ? callData.calleeId : callData.callerId;
      const userDoc = await firestore().collection('users').doc(remoteUserId).get();
      if (userDoc.exists) {
        const userData = userDoc.data()!;
        setCallState(prev => ({
          ...prev,
          remoteUser: {
            name: userData.displayName,
            avatar: userData.photoURL,
          },
        }));
      }

      // Initialize WebRTC
      await initializeWebRTC(callData);
    } catch (error) {
      console.error('Error initializing call:', error);
    }
  };

  const initializeWebRTC = async (callData: any) => {
    try {
      const pc = new RTCPeerConnection(servers);
      setPeerConnection(pc);

      // Get user media
      const constraints = {
        audio: true,
        video: callData.type === 'video' ? {
          width: { ideal: 1280 },
          height: { ideal: 720 },
          facingMode: 'user',
        } : false,
      };

      const stream = await mediaDevices.getUserMedia(constraints);
      setLocalStream(stream);

      // Add tracks to peer connection
      stream.getTracks().forEach(track => {
        pc.addTrack(track, stream);
      });

      // Handle remote stream
      pc.onaddstream = (event) => {
        setRemoteStream(event.stream);
        setCallState(prev => ({ ...prev, status: 'connected' }));
        setCallStartTime(Date.now());
      };

      // Handle ICE candidates
      pc.onicecandidate = (event) => {
        if (event.candidate) {
          const candidateCollection = callData.callerId === user?.uid ? 'offerCandidates' : 'answerCandidates';
          firestore()
            .collection('calls')
            .doc(callId)
            .collection(candidateCollection)
            .add(event.candidate.toJSON());
        }
      };

      // Listen for call updates
      firestore().collection('calls').doc(callId).onSnapshot((doc) => {
        const data = doc.data();
        if (!data || data.status === 'ended') {
          endCall();
        }
      });

    } catch (error) {
      console.error('Error initializing WebRTC:', error);
    }
  };

  const toggleMute = () => {
    if (localStream) {
      localStream.getAudioTracks().forEach((track: any) => {
        track.enabled = isMuted;
      });
      setIsMuted(!isMuted);
    }
  };

  const toggleVideo = () => {
    if (localStream) {
      localStream.getVideoTracks().forEach((track: any) => {
        track.enabled = !isVideoEnabled;
      });
      setIsVideoEnabled(!isVideoEnabled);
    }
  };

  const toggleSpeaker = () => {
    setIsSpeakerEnabled(!isSpeakerEnabled);
    // Implement speaker toggle logic
  };

  const switchCamera = async () => {
    try {
      if (localStream) {
        localStream.getVideoTracks().forEach((track: any) => track.stop());
        
        const newStream = await mediaDevices.getUserMedia({
          audio: true,
          video: {
            facingMode: isVideoEnabled ? 'environment' : 'user',
          },
        });
        
        setLocalStream(newStream);
        
        // Replace video track in peer connection
        if (peerConnection) {
          const videoTrack = newStream.getVideoTracks()[0];
          const sender = peerConnection.getSenders().find(s => s.track?.kind === 'video');
          if (sender) {
            await sender.replaceTrack(videoTrack);
          }
        }
      }
    } catch (error) {
      console.error('Error switching camera:', error);
    }
  };

  const endCall = async () => {
    try {
      setCallState(prev => ({ ...prev, status: 'ended' }));
      
      // Update call document
      await firestore().collection('calls').doc(callId).update({
        status: 'ended',
        endedAt: firestore.FieldValue.serverTimestamp(),
      });

      cleanup();
    } catch (error) {
      console.error('Error ending call:', error);
    }
  };

  const cleanup = () => {
    if (localStream) {
      localStream.getTracks().forEach((track: any) => track.stop());
      setLocalStream(null);
    }
    
    if (remoteStream) {
      setRemoteStream(null);
    }
    
    if (peerConnection) {
      peerConnection.close();
      setPeerConnection(null);
    }
  };

  return {
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
    endCall,
  };
}