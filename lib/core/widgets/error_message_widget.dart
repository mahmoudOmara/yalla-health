import 'package:flutter/material.dart';
import 'package:yalla_health/core/theme/app_theme.dart';

/// A reusable error message widget that provides consistent error styling
/// across the application
class ErrorMessageWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final EdgeInsets? padding;
  final bool showBorder;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.padding,
    this.showBorder = true,
  }) : super(key: key);

  /// Factory constructor for API error messages
  factory ErrorMessageWidget.apiError({
    required String message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessageWidget(
      message: message,
      onRetry: onRetry,
      icon: Icons.cloud_off_outlined,
    );
  }

  /// Factory constructor for validation error messages
  factory ErrorMessageWidget.validation({
    required String message,
  }) {
    return ErrorMessageWidget(
      message: message,
      icon: Icons.warning_outlined,
      showBorder: false,
    );
  }

  /// Factory constructor for network error messages
  factory ErrorMessageWidget.network({
    required String message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessageWidget(
      message: message,
      onRetry: onRetry,
      icon: Icons.wifi_off_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: showBorder 
            ? Border.all(
                color: AppTheme.errorColor.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppTheme.errorColor,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}