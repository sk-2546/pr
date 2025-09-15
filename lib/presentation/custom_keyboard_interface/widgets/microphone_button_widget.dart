import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MicrophoneButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;
  final bool isProcessing;
  final bool hasError;

  const MicrophoneButtonWidget({
    Key? key,
    required this.onPressed,
    this.isListening = false,
    this.isProcessing = false,
    this.hasError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color buttonColor = _getButtonColor();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 12.w,
        height: 6.h,
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.3),
              blurRadius: isListening ? 12 : 4,
              spreadRadius: isListening ? 4 : 0,
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    if (hasError) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (isListening) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (isProcessing) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else {
      return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  Widget _buildButtonContent() {
    if (isProcessing) {
      return Center(
        child: SizedBox(
          width: 4.w,
          height: 4.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }

    return Center(
      child: CustomIconWidget(
        iconName: 'mic',
        color: AppTheme.lightTheme.colorScheme.onPrimary,
        size: 5.w,
      ),
    );
  }
}
