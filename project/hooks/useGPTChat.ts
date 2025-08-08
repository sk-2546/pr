import { useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAuth } from './useAuth';

interface GPTMessage {
  id: string;
  text: string;
  senderId: string;
  timestamp: number;
}

const GEMINI_API_KEY = "AIzaSyAEixXph3ppLOOH2NbObdg3jve4mSj_6yA";
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=${GEMINI_API_KEY}`;

export function useGPTChat() {
  const { user } = useAuth();
  const [messages, setMessages] = useState<GPTMessage[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    loadChatHistory();
  }, []);

  const loadChatHistory = async () => {
    try {
      const savedHistory = await AsyncStorage.getItem('gptChatHistory');
      if (savedHistory) {
        const history = JSON.parse(savedHistory);
        setMessages(history);
      } else {
        // Add initial greeting
        const initialMessage: GPTMessage = {
          id: 'initial',
          text: "Hello! I'm ShubhamGPT. How can I help you today?",
          senderId: 'gpt',
          timestamp: Date.now(),
        };
        setMessages([initialMessage]);
      }
    } catch (error) {
      console.error('Error loading GPT chat history:', error);
    }
  };

  const saveChatHistory = async (newMessages: GPTMessage[]) => {
    try {
      await AsyncStorage.setItem('gptChatHistory', JSON.stringify(newMessages));
    } catch (error) {
      console.error('Error saving GPT chat history:', error);
    }
  };

  const sendMessage = async (text: string) => {
    if (!user) return;

    const userMessage: GPTMessage = {
      id: `user-${Date.now()}`,
      text,
      senderId: user.uid,
      timestamp: Date.now(),
    };

    const updatedMessages = [...messages, userMessage];
    setMessages(updatedMessages);
    setIsLoading(true);

    try {
      // Prepare conversation history for Gemini
      const conversationHistory = updatedMessages.map((msg) => ({
        role: msg.senderId === 'gpt' ? 'model' : 'user',
        parts: [{ text: msg.text }],
      }));

      const response = await fetch(GEMINI_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: conversationHistory,
        }),
      });

      if (!response.ok) {
        throw new Error('API request failed');
      }

      const result = await response.json();
      const gptResponseText = result.candidates[0].content.parts[0].text;

      const gptMessage: GPTMessage = {
        id: `gpt-${Date.now()}`,
        text: gptResponseText,
        senderId: 'gpt',
        timestamp: Date.now(),
      };

      const finalMessages = [...updatedMessages, gptMessage];
      setMessages(finalMessages);
      await saveChatHistory(finalMessages);
    } catch (error) {
      console.error('Gemini API Error:', error);
      const errorMessage: GPTMessage = {
        id: `error-${Date.now()}`,
        text: "Sorry, I'm having trouble connecting. Please try again.",
        senderId: 'gpt',
        timestamp: Date.now(),
      };
      const finalMessages = [...updatedMessages, errorMessage];
      setMessages(finalMessages);
    } finally {
      setIsLoading(false);
    }
  };

  return {
    messages,
    sendMessage,
    isLoading,
  };
}