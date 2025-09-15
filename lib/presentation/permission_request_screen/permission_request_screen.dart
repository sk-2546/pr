import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/expandable_info_widget.dart';
import './widgets/permission_card_widget.dart';
import './widgets/waveform_animation_widget.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({Key? key}) : super(key: key);

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool _microphoneGranted = false;
  bool _keyboardActivated = false;
  bool _microphonePending = false;
  bool _keyboardPending = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final micStatus = await Permission.microphone.status;
    setState(() {
      _microphoneGranted = micStatus.isGranted;
    });
  }

  Future<void> _requestMicrophonePermission() async {
    setState(() {
      _microphonePending = true;
    });

    try {
      final status = await Permission.microphone.request();

      setState(() {
        _microphoneGranted = status.isGranted;
        _microphonePending = false;
      });

      if (status.isGranted) {
        HapticFeedback.lightImpact();
        _showSuccessMessage('Microphone access granted successfully!');
      } else if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      setState(() {
        _microphonePending = false;
      });
      _showErrorMessage('Failed to request microphone permission');
    }
  }

  Future<void> _activateKeyboard() async {
    setState(() {
      _keyboardPending = true;
    });

    try {
      // Simulate keyboard activation process
      await Future.delayed(const Duration(seconds: 1));

      // Open keyboard settings
      await _openKeyboardSettings();

      setState(() {
        _keyboardPending = false;
        _keyboardActivated =
            true; // In real implementation, this would be checked
      });

      HapticFeedback.lightImpact();
      _showSuccessMessage('Please enable VoiceType Keyboard in settings');
    } catch (e) {
      setState(() {
        _keyboardPending = false;
      });
      _showErrorMessage('Failed to open keyboard settings');
    }
  }

  Future<void> _openKeyboardSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      _showErrorMessage(
          'Unable to open settings. Please navigate manually to Settings > System > Languages & input > Virtual keyboard');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Microphone Permission Required',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          content: Text(
            'VoiceType Keyboard needs microphone access to convert your speech to text. Please enable it in app settings.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToKeyboardSettings() {
    Navigator.pushNamed(context, '/keyboard-settings');
  }

  void _navigateBack() {
    Navigator.pushReplacementNamed(context, '/onboarding-flow');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _navigateBack,
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Setup Permissions',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),

              // Header Section
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'security',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 10.w,
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                'Enable Essential Permissions',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              Text(
                'VoiceType Keyboard needs these permissions to provide seamless offline voice-to-text conversion across all your apps.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Microphone Permission Card
              PermissionCardWidget(
                title: 'Microphone Access',
                description:
                    'Required for offline voice recognition. Your voice data stays on your device and is never sent to external servers, ensuring complete privacy.',
                iconName: 'mic',
                isGranted: _microphoneGranted,
                isPending: _microphonePending,
                onTap: _requestMicrophonePermission,
                animationWidget: WaveformAnimationWidget(
                  isAnimating: _microphonePending,
                ),
              ),

              SizedBox(height: 2.h),

              // Keyboard Activation Card
              PermissionCardWidget(
                title: 'Keyboard Service',
                description:
                    'Activate VoiceType as your input method to use voice-to-text across all applications including WhatsApp, Notes, Browser, and more.',
                iconName: 'keyboard',
                isGranted: _keyboardActivated,
                isPending: _keyboardPending,
                onTap: _activateKeyboard,
              ),

              SizedBox(height: 4.h),

              // Continue Button
              if (_microphoneGranted && _keyboardActivated)
                Container(
                  width: 85.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/custom-keyboard-interface');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue to Keyboard',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'arrow_forward',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 5.w,
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 3.h),

              // Settings Button
              Container(
                width: 85.w,
                height: 5.h,
                child: OutlinedButton(
                  onPressed: _navigateToKeyboardSettings,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'settings',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Keyboard Settings',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Expandable Info Section
              ExpandableInfoWidget(
                title: 'Why these permissions?',
                infoPoints: const [
                  'Microphone access enables real-time speech recognition using advanced offline AI models',
                  'All voice processing happens locally on your device - no data is sent to external servers',
                  'Keyboard service activation allows VoiceType to work across all your favorite apps',
                  'Your privacy is protected with end-to-end offline processing',
                  'No internet connection required for voice-to-text conversion',
                  'Supports both Hindi and English languages with bilingual capability',
                ],
              ),

              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
    );
  }
}
