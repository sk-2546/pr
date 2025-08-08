import { useState, useEffect, createContext, useContext } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

type Theme = 'light' | 'dark';

interface Colors {
  background: string;
  surface: string;
  primary: string;
  secondary: string;
  text: string;
  textSecondary: string;
  border: string;
  success: string;
  warning: string;
  error: string;
  sentBubble: string;
  receivedBubble: string;
}

interface ThemeContextType {
  theme: Theme;
  colors: Colors;
  toggleTheme: () => void;
}

const lightColors: Colors = {
  background: '#e5ddd5',
  surface: '#ffffff',
  primary: '#005c4b',
  secondary: '#667781',
  text: '#111b21',
  textSecondary: '#667781',
  border: '#e5e7eb',
  success: '#22c55e',
  warning: '#f59e0b',
  error: '#ef4444',
  sentBubble: '#d9fdd3',
  receivedBubble: '#ffffff',
};

const darkColors: Colors = {
  background: '#0f172a',
  surface: '#1e293b',
  primary: '#4f46e5',
  secondary: '#94a3b8',
  text: '#e2e8f0',
  textSecondary: '#94a3b8',
  border: '#334155',
  success: '#22c55e',
  warning: '#f59e0b',
  error: '#ef4444',
  sentBubble: '#2563eb',
  receivedBubble: '#334155',
};

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}

export function useThemeProvider() {
  const [theme, setTheme] = useState<Theme>('dark');

  useEffect(() => {
    loadTheme();
  }, []);

  const loadTheme = async () => {
    try {
      const savedTheme = await AsyncStorage.getItem('chatTheme');
      if (savedTheme === 'light' || savedTheme === 'dark') {
        setTheme(savedTheme);
      }
    } catch (error) {
      console.error('Error loading theme:', error);
    }
  };

  const toggleTheme = async () => {
    const newTheme = theme === 'dark' ? 'light' : 'dark';
    setTheme(newTheme);
    try {
      await AsyncStorage.setItem('chatTheme', newTheme);
    } catch (error) {
      console.error('Error saving theme:', error);
    }
  };

  const colors = theme === 'dark' ? darkColors : lightColors;

  return {
    theme,
    colors,
    toggleTheme,
  };
}