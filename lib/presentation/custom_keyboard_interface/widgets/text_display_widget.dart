import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TextDisplayWidget extends StatelessWidget {
  final String displayText;
  final bool isVisible;

  const TextDisplayWidget({
    Key? key,
    required this.displayText,
    this.isVisible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? 4.h : 0,
      width: double.infinity,
      padding: isVisible
          ? EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isVisible
            ? AppTheme.lightTheme.colorScheme.surface
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isVisible
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: isVisible
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                displayText.isEmpty
                    ? 'Tap microphone to start...'
                    : displayText,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: displayText.isEmpty
                      ? AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6)
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
