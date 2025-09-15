import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/display_preferences_widget.dart';
import './widgets/language_selection_widget.dart';
import './widgets/model_management_widget.dart';
import './widgets/voice_recognition_widget.dart';

class KeyboardSettings extends StatefulWidget {
  const KeyboardSettings({Key? key}) : super(key: key);

  @override
  State<KeyboardSettings> createState() => _KeyboardSettingsState();
}

class _KeyboardSettingsState extends State<KeyboardSettings> {
  // Language settings
  String _selectedLanguage = 'bilingual';

  // Voice recognition settings
  double _sensitivity = 0.7;
  int _timeoutSeconds = 10;

  // Display preferences
  bool _autoCapitalization = true;
  bool _autoPunctuation = true;
  bool _showProcessingIndicator = true;

  // Model management
  bool _isHindiModelDownloaded = true;
  bool _isEnglishModelDownloaded = true;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _downloadingModel = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            _buildHeaderSection(context),
            SizedBox(height: 2.h),
            LanguageSelectionWidget(
              selectedLanguage: _selectedLanguage,
              onLanguageChanged: _onLanguageChanged,
            ),
            VoiceRecognitionWidget(
              sensitivity: _sensitivity,
              timeoutSeconds: _timeoutSeconds,
              onSensitivityChanged: _onSensitivityChanged,
              onTimeoutChanged: _onTimeoutChanged,
            ),
            DisplayPreferencesWidget(
              autoCapitalization: _autoCapitalization,
              autoPunctuation: _autoPunctuation,
              showProcessingIndicator: _showProcessingIndicator,
              onAutoCapitalizationChanged: _onAutoCapitalizationChanged,
              onAutoPunctuationChanged: _onAutoPunctuationChanged,
              onShowProcessingIndicatorChanged:
                  _onShowProcessingIndicatorChanged,
            ),
            ModelManagementWidget(
              isHindiModelDownloaded: _isHindiModelDownloaded,
              isEnglishModelDownloaded: _isEnglishModelDownloaded,
              downloadProgress: _downloadProgress,
              isDownloading: _isDownloading,
              downloadingModel: _downloadingModel,
              onDownloadModel: _onDownloadModel,
              onDeleteModel: _onDeleteModel,
            ),
            _buildAdvancedSection(context),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          size: 24,
        ),
      ),
      title: Text(
        'Keyboard Settings',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        IconButton(
          onPressed: _resetToDefaults,
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'keyboard_voice',
              color: AppTheme.lightTheme.primaryColor,
              size: 32,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VoiceType Keyboard',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Configure your offline voice-to-text preferences for seamless typing across all apps.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    final List<Map<String, dynamic>> advancedOptions = [
      {
        'title': 'Keyboard Interface',
        'subtitle': 'Customize keyboard appearance and layout',
        'icon': 'keyboard',
        'route': '/custom-keyboard-interface',
      },
      {
        'title': 'Permissions',
        'subtitle': 'Manage microphone and storage permissions',
        'icon': 'security',
        'route': '/permission-request-screen',
      },
      {
        'title': 'Tutorial',
        'subtitle': 'Learn how to use VoiceType effectively',
        'icon': 'help_outline',
        'route': '/onboarding-flow',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Advanced Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          ...advancedOptions.map((option) => _buildAdvancedOption(
                context,
                option['title'] as String,
                option['subtitle'] as String,
                option['icon'] as String,
                option['route'] as String,
              )),
        ],
      ),
    );
  }

  Widget _buildAdvancedOption(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.6) ??
                  Colors.grey,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.4) ??
                  Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _onLanguageChanged(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    _showSettingsUpdatedSnackBar(
        'Language updated to ${language.toUpperCase()}');
  }

  void _onSensitivityChanged(double sensitivity) {
    setState(() {
      _sensitivity = sensitivity;
    });
  }

  void _onTimeoutChanged(int timeout) {
    setState(() {
      _timeoutSeconds = timeout;
    });
    _showSettingsUpdatedSnackBar('Timeout set to ${timeout}s');
  }

  void _onAutoCapitalizationChanged(bool value) {
    setState(() {
      _autoCapitalization = value;
    });
  }

  void _onAutoPunctuationChanged(bool value) {
    setState(() {
      _autoPunctuation = value;
    });
  }

  void _onShowProcessingIndicatorChanged(bool value) {
    setState(() {
      _showProcessingIndicator = value;
    });
  }

  void _onDownloadModel(String modelKey) {
    setState(() {
      _isDownloading = true;
      _downloadingModel = modelKey;
      _downloadProgress = 0.0;
    });

    // Simulate download progress
    _simulateDownload(modelKey);
  }

  void _onDeleteModel(String modelKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Model'),
        content: Text(
            'Are you sure you want to delete the $modelKey model? You will need to download it again to use $modelKey voice recognition.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (modelKey == 'hindi') {
                  _isHindiModelDownloaded = false;
                } else if (modelKey == 'english') {
                  _isEnglishModelDownloaded = false;
                }
              });
              _showSettingsUpdatedSnackBar(
                  '${modelKey.toUpperCase()} model deleted');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _simulateDownload(String modelKey) {
    const duration = Duration(milliseconds: 100);
    Timer.periodic(duration, (timer) {
      setState(() {
        _downloadProgress += 0.02;
      });

      if (_downloadProgress >= 1.0) {
        timer.cancel();
        setState(() {
          _isDownloading = false;
          _downloadingModel = '';
          _downloadProgress = 0.0;

          if (modelKey == 'hindi') {
            _isHindiModelDownloaded = true;
          } else if (modelKey == 'english') {
            _isEnglishModelDownloaded = true;
          }
        });
        _showSettingsUpdatedSnackBar(
            '${modelKey.toUpperCase()} model downloaded successfully');
      }
    });
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text(
            'Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedLanguage = 'bilingual';
                _sensitivity = 0.7;
                _timeoutSeconds = 10;
                _autoCapitalization = true;
                _autoPunctuation = true;
                _showProcessingIndicator = true;
              });
              _showSettingsUpdatedSnackBar('Settings reset to defaults');
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSettingsUpdatedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Import for Timer
