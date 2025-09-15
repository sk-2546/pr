import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DisplayPreferencesWidget extends StatelessWidget {
  final bool autoCapitalization;
  final bool autoPunctuation;
  final bool showProcessingIndicator;
  final Function(bool) onAutoCapitalizationChanged;
  final Function(bool) onAutoPunctuationChanged;
  final Function(bool) onShowProcessingIndicatorChanged;

  const DisplayPreferencesWidget({
    Key? key,
    required this.autoCapitalization,
    required this.autoPunctuation,
    required this.showProcessingIndicator,
    required this.onAutoCapitalizationChanged,
    required this.onAutoPunctuationChanged,
    required this.onShowProcessingIndicatorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  iconName: 'text_fields',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Display Preferences',
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
          _buildToggleOption(
            context,
            'Auto Capitalization',
            'Automatically capitalize first letter of sentences',
            autoCapitalization,
            onAutoCapitalizationChanged,
            'format_size',
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          _buildToggleOption(
            context,
            'Auto Punctuation',
            'Add punctuation marks automatically',
            autoPunctuation,
            onAutoPunctuationChanged,
            'more_horiz',
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          _buildToggleOption(
            context,
            'Processing Indicator',
            'Show visual indicator during voice processing',
            showProcessingIndicator,
            onShowProcessingIndicatorChanged,
            'hourglass_empty',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context,
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
    String iconName,
  ) {
    return Padding(
      padding: EdgeInsets.all(4.w),
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
                  description,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.primaryColor,
            activeTrackColor:
                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5),
            inactiveThumbColor: Theme.of(context).dividerColor,
            inactiveTrackColor:
                Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
