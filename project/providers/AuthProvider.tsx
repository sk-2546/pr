import React, { createContext, useEffect } from 'react';
import { router } from 'expo-router';
import { useAuthProvider } from '@/hooks/useAuth';
import { PresenceService } from '@/services/PresenceService';
import { LoadingScreen } from '@/components/LoadingScreen';

const AuthContext = createContext<any>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const authValue = useAuthProvider();

  useEffect(() => {
    if (authValue.user) {
      // Initialize presence service
      PresenceService.initialize(authValue.user.uid);
      
      // Navigate to main app
      router.replace('/(tabs)');
    } else if (!authValue.loading) {
      // Navigate to login
      router.replace('/auth/login');
    }
  }, [authValue.user, authValue.loading]);

  if (authValue.loading) {
    return <LoadingScreen />;
  }

  return (
    <AuthContext.Provider value={authValue}>
      {children}
    </AuthContext.Provider>
  );
}

export { AuthContext };