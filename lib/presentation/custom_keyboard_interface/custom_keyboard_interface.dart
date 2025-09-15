import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/language_indicator_widget.dart';
import './widgets/microphone_button_widget.dart';
import './widgets/settings_button_widget.dart';
import './widgets/text_display_widget.dart';
import './widgets/voice_status_widget.dart';

class CustomKeyboardInterface extends StatefulWidget {
  const CustomKeyboardInterface({Key? key}) : super(key: key);

  @override
  State<CustomKeyboardInterface> createState() =>
      _CustomKeyboardInterfaceState();
}

class _CustomKeyboardInterfaceState extends State<CustomKeyboardInterface>
    with TickerProviderStateMixin {
  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isListening = false;
  bool _isProcessing = false;
  bool _hasError = false;
  String _statusText = '';
  String _displayText = '';
  String _currentLanguage = 'English';
  Timer? _listeningTimer;
  Timer? _processingTimer;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestMicrophonePermission();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _listeningTimer?.cancel();
    _processingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() {
        _hasError = true;
        _statusText = 'Microphone permission required';
      });
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _showError('Microphone permission denied');
        return;
      }

      setState(() {
        _isListening = true;
        _hasError = false;
        _statusText = 'Listening...';
        _displayText = '';
      });

      _pulseController.repeat(reverse: true);

      // Start recording
      await _audioRecorder.start(const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        bitRate: 128000,
      ), path: 'voice_recording.wav');

      // Auto-stop after 10 seconds
      _listeningTimer = Timer(const Duration(seconds: 10), () {
        if (_isListening) {
          _stopListening();
        }
      });

      // Provide haptic feedback
      HapticFeedback.lightImpact();
    } catch (e) {
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopListening() async {
    try {
      _listeningTimer?.cancel();
      _pulseController.stop();

      setState(() {
        _isListening = false;
        _isProcessing = true;
        _statusText = 'Converting...';
      });

      // Stop recording
      final path = await _audioRecorder.stop();

      if (path != null) {
        // Simulate processing time
        _processingTimer = Timer(const Duration(seconds: 2), () {
          _processVoiceInput();
        });
      } else {
        _showError('No audio recorded');
      }
    } catch (e) {
      _showError('Failed to stop recording');
    }
  }

  void _processVoiceInput() {
    // Mock voice-to-text conversion
    final mockTexts = [
      'Hello, how are you today?',
      'नमस्ते, आप कैसे हैं?',
      'This is a test message',
      'यह एक परीक्षण संदेश है',
      'Voice input is working perfectly',
    ];

    final randomText = mockTexts[DateTime.now().millisecond % mockTexts.length];

    setState(() {
      _isProcessing = false;
      _displayText = randomText;
      _statusText = 'Tap to insert text';
    });

    // Auto-hide status after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusText = '';
        });
      }
    });

    HapticFeedback.selectionClick();
  }

  void _showError(String message) {
    setState(() {
      _isListening = false;
      _isProcessing = false;
      _hasError = true;
      _statusText = message;
    });

    _pulseController.stop();
    HapticFeedback.heavyImpact();

    // Auto-hide error after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hasError = false;
          _statusText = '';
        });
      }
    });
  }

  void _switchLanguage() {
    setState(() {
      switch (_currentLanguage) {
        case 'English':
          _currentLanguage = 'Hindi';
          break;
        case 'Hindi':
          _currentLanguage = 'Bilingual';
          break;
        case 'Bilingual':
          _currentLanguage = 'English';
          break;
      }
    });

    HapticFeedback.selectionClick();
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/keyboard-settings');
  }

  void _insertText() {
    if (_displayText.isNotEmpty) {
      // In a real IME implementation, this would insert text into the active input field
      // For now, we'll just clear the display
      setState(() {
        _displayText = '';
        _statusText = 'Text inserted';
      });

      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _statusText = '';
          });
        }
      });

      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Container(
          height: 20.h, // Keyboard height constraint
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              // Text display area
              TextDisplayWidget(
                displayText: _displayText,
                isVisible: _displayText.isNotEmpty,
              ),

              SizedBox(height: 1.h),

              // Status display
              VoiceStatusWidget(
                statusText: _statusText,
                isVisible: _statusText.isNotEmpty,
                showWaveform: _isListening,
              ),

              SizedBox(height: 2.h),

              // Main control row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Language indicator
                  LanguageIndicatorWidget(
                    currentLanguage: _currentLanguage,
                    onTap: _switchLanguage,
                  ),

                  // Microphone button (center)
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isListening ? _pulseAnimation.value : 1.0,
                            child: MicrophoneButtonWidget(
                              onPressed: _displayText.isNotEmpty
                                  ? _insertText
                                  : _toggleVoiceInput,
                              isListening: _isListening,
                              isProcessing: _isProcessing,
                              hasError: _hasError,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Settings button
                  SettingsButtonWidget(
                    onPressed: _openSettings,
                  ),
                ],
              ),

              SizedBox(height: 1.h),

              // Helper text
              Text(
                _displayText.isNotEmpty
                    ? 'Tap microphone to insert text'
                    : 'Tap microphone to start voice input',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}