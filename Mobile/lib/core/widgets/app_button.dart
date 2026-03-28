import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final IconData? prefixIcon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.height,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.height,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.height,
  }) : variant = AppButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary
                    ? AppColors.textOnPrimary
                    : AppColors.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: AppSpacing.iconSm + 4),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: AppTextStyles.buttonText),
            ],
          );

    final double btnHeight = height ?? AppSpacing.buttonHeight;
    final shape = RoundedRectangleBorder(borderRadius: AppSpacing.rounded);

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: btnHeight,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? AppColors.grey200
                  : (variant == AppButtonVariant.secondary
                      ? AppColors.secondary
                      : AppColors.primary),
              foregroundColor: isDisabled
                  ? AppColors.textDisabled
                  : (variant == AppButtonVariant.secondary
                      ? AppColors.textOnSecondary
                      : AppColors.textOnPrimary),
              elevation: 0,
              minimumSize: Size(isFullWidth ? double.infinity : 0, btnHeight),
              shape: shape,
            ),
            child: child,
          ),
        );

      case AppButtonVariant.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: btnHeight,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isDisabled ? AppColors.textDisabled : AppColors.primary,
              side: BorderSide(
                color: isDisabled ? AppColors.border : AppColors.primary,
              ),
              minimumSize: Size(isFullWidth ? double.infinity : 0, btnHeight),
              shape: shape,
            ),
            child: child,
          ),
        );

      case AppButtonVariant.ghost:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: btnHeight,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor:
                  isDisabled ? AppColors.textDisabled : AppColors.primary,
              minimumSize: Size(isFullWidth ? double.infinity : 0, btnHeight),
              shape: shape,
            ),
            child: child,
          ),
        );
    }
  }
}
