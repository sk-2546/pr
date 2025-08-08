import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import { Volume2, Check, CheckCheck } from 'lucide-react-native';

interface MessageBubbleProps {
  message: {
    id: string;
    text: string;
    senderId: string;
    timestamp: any;
    status?: 'sending' | 'sent' | 'delivered' | 'read';
  };
  isOwn: boolean;
  colors: any;
  showAvatar?: boolean;
  isGPT?: boolean;
}

export function MessageBubble({ message, isOwn, colors, showAvatar = true, isGPT = false }: MessageBubbleProps) {
  const formatTime = (timestamp: any) => {
    if (!timestamp) return '';
    
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const getStatusIcon = () => {
    if (!isOwn) return null;
    
    switch (message.status) {
      case 'sending':
        return <View style={[styles.statusIcon, { backgroundColor: colors.textSecondary }]} />;
      case 'sent':
        return <Check size={16} color={colors.textSecondary} />;
      case 'delivered':
        return <CheckCheck size={16} color={colors.textSecondary} />;
      case 'read':
        return <CheckCheck size={16} color={colors.primary} />;
      default:
        return null;
    }
  };

  const handleSpeak = () => {
    // Implement text-to-speech functionality
    console.log('Speaking:', message.text);
  };

  return (
    <View style={[styles.container, isOwn ? styles.ownMessage : styles.otherMessage]}>
      <View
        style={[
          styles.bubble,
          {
            backgroundColor: isOwn ? colors.sentBubble : colors.receivedBubble,
          },
          isOwn ? styles.ownBubble : styles.otherBubble,
        ]}
      >
        <Text style={[styles.messageText, { color: isOwn ? 'white' : colors.text }]}>
          {message.text}
        </Text>
        
        <View style={styles.messageFooter}>
          <Text style={[styles.timestamp, { color: isOwn ? 'rgba(255,255,255,0.7)' : colors.textSecondary }]}>
            {formatTime(message.timestamp)}
          </Text>
          
          {isGPT && (
            <TouchableOpacity onPress={handleSpeak} style={styles.speakButton}>
              <Volume2 size={14} color={colors.textSecondary} />
            </TouchableOpacity>
          )}
          
          {getStatusIcon()}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginVertical: 2,
    paddingHorizontal: 4,
  },
  ownMessage: {
    alignItems: 'flex-end',
  },
  otherMessage: {
    alignItems: 'flex-start',
  },
  bubble: {
    maxWidth: '85%',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 18,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.1,
    shadowRadius: 1,
    elevation: 1,
  },
  ownBubble: {
    borderBottomRightRadius: 4,
  },
  otherBubble: {
    borderBottomLeftRadius: 4,
  },
  messageText: {
    fontSize: 16,
    lineHeight: 20,
  },
  messageFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    marginTop: 4,
    gap: 4,
  },
  timestamp: {
    fontSize: 12,
  },
  speakButton: {
    padding: 2,
  },
  statusIcon: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
});