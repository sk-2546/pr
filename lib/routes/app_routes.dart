import 'package:flutter/material.dart';
import '../presentation/permission_request_screen/permission_request_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/custom_keyboard_interface/custom_keyboard_interface.dart';
import '../presentation/keyboard_settings/keyboard_settings.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String permissionRequest = '/permission-request-screen';
  static const String splash = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String customKeyboardInterface = '/custom-keyboard-interface';
  static const String keyboardSettings = '/keyboard-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    permissionRequest: (context) => const PermissionRequestScreen(),
    splash: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    customKeyboardInterface: (context) => const CustomKeyboardInterface(),
    keyboardSettings: (context) => const KeyboardSettings(),
    // TODO: Add your other routes here
  };
}
