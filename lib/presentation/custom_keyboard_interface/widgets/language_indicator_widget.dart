import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LanguageIndicatorWidget extends StatelessWidget {
  final String currentLanguage;
  final VoidCallback onTap;

  const LanguageIndicatorWidget({
    Key? key,
    required this.currentLanguage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 10.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            _getLanguageDisplay(),
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _getLanguageDisplay() {
    switch (currentLanguage.toLowerCase()) {
      case 'hindi':
        return 'HI';
      case 'english':
        return 'EN';
      case 'bilingual':
        return 'BI';
      default:
        return 'EN';
    }
  }
}
