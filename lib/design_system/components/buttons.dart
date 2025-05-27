import 'package:flutter/material.dart';
import '../spacing.dart';
import '../typography.dart';
import '../../theme/colors.dart';

/// A comprehensive button system following Material Design guidelines
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isDestructive;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme, isDestructive);
    final styles = _getStyles(size);
    final padding = _getPadding(size);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: styles.fontSize,
            height: styles.fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.primary
                    ? colors.onPrimary
                    : colors.primary,
              ),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: styles.fontSize),
            const SizedBox(width: Spacing.xs),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: styles.fontSize,
              color: variant == ButtonVariant.primary
                  ? colors.onPrimary
                  : colors.primary,
            ),
          ),
        ],
      ],
    );

    if (isFullWidth) {
      buttonChild = SizedBox(width: double.infinity, child: buttonChild);
    }

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            elevation: Spacing.elevationNone,
          ),
          child: buttonChild,
        );

      case ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
          ),
          child: buttonChild,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
          ),
          child: buttonChild,
        );
    }
  }

  ButtonStyleData _getStyles(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return ButtonStyleData(
          fontSize: AppTypography.labelSmall.fontSize!,
          height: 32,
        );
      case ButtonSize.medium:
        return ButtonStyleData(
          fontSize: AppTypography.labelMedium.fontSize!,
          height: 40,
        );
      case ButtonSize.large:
        return ButtonStyleData(
          fontSize: AppTypography.labelLarge.fontSize!,
          height: 48,
        );
    }
  }

  EdgeInsets _getPadding(ButtonSize size) {
    final horizontal = size == ButtonSize.small ? Spacing.md : Spacing.lg;
    final vertical = size == ButtonSize.small ? Spacing.xs : Spacing.sm;
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  ButtonColors _getColors(ThemeData theme, bool isDestructive) {
    final colorScheme = theme.colorScheme;
    if (isDestructive) {
      return const ButtonColors(
        primary: AppColors.error,
        onPrimary: AppColors.white,
      );
    }
    return ButtonColors(
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
    );
  }
}

/// Button variants
enum ButtonVariant {
  primary,
  secondary,
  text,
}

/// Button sizes
enum ButtonSize {
  small,
  medium,
  large,
}

/// Helper class for button style data
class ButtonStyleData {
  final double fontSize;
  final double height;

  const ButtonStyleData({
    required this.fontSize,
    required this.height,
  });

  ButtonStyleData copyWith({
    double? fontSize,
    double? height,
  }) {
    return ButtonStyleData(
      fontSize: fontSize ?? this.fontSize,
      height: height ?? this.height,
    );
  }
}

/// Helper class for button colors
class ButtonColors {
  final Color primary;
  final Color onPrimary;

  const ButtonColors({
    required this.primary,
    required this.onPrimary,
  });
}

/// Icon button with consistent styling
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconButtonVariant variant;
  final IconButtonSize size;
  final bool isDestructive;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.variant = IconButtonVariant.primary,
    this.size = IconButtonSize.medium,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme, isDestructive);
    final buttonSize = _getSize(size);

    Widget iconWidget = isLoading
        ? SizedBox(
            width: buttonSize * 0.6,
            height: buttonSize * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == IconButtonVariant.primary
                    ? colors.onPrimary
                    : colors.primary,
              ),
            ),
          )
        : Icon(
            icon,
            size: buttonSize * 0.6,
            color: variant == IconButtonVariant.primary
                ? colors.onPrimary
                : colors.primary,
          );

    switch (variant) {
      case IconButtonVariant.primary:
        return Material(
          color: colors.primary,
          borderRadius: BorderRadius.circular(Spacing.radiusCircular),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(Spacing.radiusCircular),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              padding: const EdgeInsets.all(Spacing.sm),
              child: Center(child: iconWidget),
            ),
          ),
        );

      case IconButtonVariant.secondary:
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Spacing.radiusCircular),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(Spacing.radiusCircular),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: colors.primary),
                borderRadius: BorderRadius.circular(Spacing.radiusCircular),
              ),
              child: Center(child: iconWidget),
            ),
          ),
        );

      case IconButtonVariant.text:
        return IconButton(
          onPressed: isLoading ? null : onPressed,
          icon: iconWidget,
          splashRadius: buttonSize,
        );
    }
  }

  double _getSize(IconButtonSize size) {
    switch (size) {
      case IconButtonSize.small:
        return 32;
      case IconButtonSize.medium:
        return 40;
      case IconButtonSize.large:
        return 48;
    }
  }

  ButtonColors _getColors(ThemeData theme, bool isDestructive) {
    final colorScheme = theme.colorScheme;
    if (isDestructive) {
      return const ButtonColors(
        primary: AppColors.error,
        onPrimary: AppColors.white,
      );
    }
    return ButtonColors(
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
    );
  }
}

/// Icon button variants
enum IconButtonVariant {
  primary,
  secondary,
  text,
}

/// Icon button sizes
enum IconButtonSize {
  small,
  medium,
  large,
}
