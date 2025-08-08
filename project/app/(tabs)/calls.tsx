import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Phone, Video, PhoneIncoming, PhoneOutgoing, PhoneMissed } from 'lucide-react-native';
import { useTheme } from '@/hooks/useTheme';
import { useCallHistory } from '@/hooks/useCallHistory';

export default function CallsScreen() {
  const { colors } = useTheme();
  const { callHistory } = useCallHistory();

  const renderCallItem = ({ item }: { item: any }) => {
    const getCallIcon = () => {
      if (item.type === 'video') {
        return <Video size={20} color={colors.primary} />;
      }
      
      switch (item.status) {
        case 'incoming':
          return <PhoneIncoming size={20} color={colors.success} />;
        case 'outgoing':
          return <PhoneOutgoing size={20} color={colors.primary} />;
        case 'missed':
          return <PhoneMissed size={20} color={colors.error} />;
        default:
          return <Phone size={20} color={colors.text} />;
      }
    };

    return (
      <TouchableOpacity style={[styles.callItem, { borderBottomColor: colors.border }]}>
        <Image source={{ uri: item.avatar }} style={styles.avatar} />
        <View style={styles.callInfo}>
          <Text style={[styles.callerName, { color: colors.text }]}>{item.name}</Text>
          <View style={styles.callDetails}>
            {getCallIcon()}
            <Text style={[styles.callTime, { color: colors.textSecondary }]}>
              {item.time}
            </Text>
          </View>
        </View>
        <TouchableOpacity style={styles.callBackButton}>
          <Phone size={20} color={colors.primary} />
        </TouchableOpacity>
      </TouchableOpacity>
    );
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <View style={[styles.header, { backgroundColor: colors.surface }]}>
        <Text style={[styles.title, { color: colors.text }]}>Calls</Text>
      </View>

      {callHistory.length === 0 ? (
        <View style={styles.emptyState}>
          <Phone size={64} color={colors.textSecondary} />
          <Text style={[styles.emptyText, { color: colors.textSecondary }]}>
            No calls yet
          </Text>
          <Text style={[styles.emptySubtext, { color: colors.textSecondary }]}>
            Start a conversation to make your first call
          </Text>
        </View>
      ) : (
        <FlatList
          data={callHistory}
          keyExtractor={(item) => item.id}
          renderItem={renderCallItem}
          showsVerticalScrollIndicator={false}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#334155',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    marginTop: 16,
  },
  emptySubtext: {
    fontSize: 14,
    textAlign: 'center',
    marginTop: 8,
  },
  callItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    marginRight: 12,
  },
  callInfo: {
    flex: 1,
  },
  callerName: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  callDetails: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  callTime: {
    fontSize: 14,
  },
  callBackButton: {
    padding: 8,
  },
});