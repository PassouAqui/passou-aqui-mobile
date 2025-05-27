import 'package:flutter/material.dart';
import '../spacing.dart';
import 'buttons.dart';

/// A bottom sheet component following Material Design guidelines
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? content;
  final List<Widget>? actions;
  final bool isLoading;
  final bool isDismissible;
  final bool showDragHandle;
  final VoidCallback? onClose;
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BottomSheetVariant variant;
  final Widget? icon;
  final Widget? footer;
  final double? maxHeight;
  final bool isScrollable;

  const AppBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.actions,
    this.isLoading = false,
    this.isDismissible = true,
    this.showDragHandle = true,
    this.onClose,
    this.contentPadding,
    this.backgroundColor,
    this.borderRadius,
    this.variant = BottomSheetVariant.standard,
    this.icon,
    this.footer,
    this.maxHeight,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultContentPadding =
        contentPadding ?? const EdgeInsets.all(Spacing.bottomSheetPadding);
    final defaultBorderRadius = borderRadius ??
        const BorderRadius.vertical(
          top: Radius.circular(Spacing.radiusLg),
        );

    Widget sheetContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDragHandle) ...[
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
              decoration: BoxDecoration(
                color: colors.dragHandle,
                borderRadius: BorderRadius.circular(Spacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
        if (icon != null) ...[
          Center(child: icon!),
          const SizedBox(height: Spacing.lg),
        ],
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.title,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subtitle,
              ),
            ),
          ],
          const SizedBox(height: Spacing.lg),
        ],
        if (content != null) ...[
          if (isScrollable)
            Flexible(
              child: SingleChildScrollView(
                child: content!,
              ),
            )
          else
            content!,
          const SizedBox(height: Spacing.lg),
        ],
        if (actions != null && actions!.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!
                .map((action) => Padding(
                      padding: const EdgeInsets.only(left: Spacing.sm),
                      child: action,
                    ))
                .toList(),
          ),
        ],
        if (footer != null) ...[
          const SizedBox(height: Spacing.lg),
          footer!,
        ],
      ],
    );

    if (isLoading) {
      sheetContent = Stack(
        children: [
          sheetContent,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colors.background.withAlpha(179),
                borderRadius: defaultBorderRadius,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.background,
        borderRadius: defaultBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle)
            GestureDetector(
              onTap: isDismissible ? onClose : null,
              child: Container(
                width: double.infinity,
                height: 32,
                color: Colors.transparent,
              ),
            ),
          Flexible(
            child: Padding(
              padding: defaultContentPadding,
              child: sheetContent,
            ),
          ),
        ],
      ),
    );
  }

  BottomSheetColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return BottomSheetColors(
      background: colorScheme.surface,
      title: colorScheme.onSurface,
      subtitle: colorScheme.onSurfaceVariant,
      primary: colorScheme.primary,
      dragHandle: colorScheme.outlineVariant,
    );
  }
}

/// Bottom sheet variants
enum BottomSheetVariant {
  standard,
  modal,
  persistent,
}

/// Helper class for bottom sheet colors
class BottomSheetColors {
  final Color background;
  final Color title;
  final Color subtitle;
  final Color primary;
  final Color dragHandle;

  const BottomSheetColors({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.dragHandle,
  });
}

/// A confirmation bottom sheet component
class AppConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool isDestructive;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppConfirmationBottomSheet({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
    this.isDestructive = false,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    return AppBottomSheet(
      title: title,
      subtitle: message,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      variant: BottomSheetVariant.modal,
      icon: Icon(
        isDestructive ? Icons.warning_amber_rounded : Icons.help_outline,
        size: 48,
        color: isDestructive ? colors.error : colors.icon,
      ),
      actions: [
        AppButton(
          text: cancelLabel,
          onPressed: isLoading ? null : onCancel,
          variant: ButtonVariant.text,
        ),
        AppButton(
          text: confirmLabel,
          onPressed: isLoading ? null : onConfirm,
          variant: ButtonVariant.primary,
          isDestructive: isDestructive,
        ),
      ],
    );
  }

  ConfirmationBottomSheetColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return ConfirmationBottomSheetColors(
      error: colorScheme.error,
      icon: colorScheme.primary,
    );
  }
}

/// Helper class for confirmation bottom sheet colors
class ConfirmationBottomSheetColors {
  final Color error;
  final Color icon;

  const ConfirmationBottomSheetColors({
    required this.error,
    required this.icon,
  });
}

/// A form bottom sheet component
class AppFormBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget form;
  final String submitLabel;
  final String cancelLabel;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool isDismissible;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? maxHeight;
  final bool isScrollable;

  const AppFormBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.form,
    this.submitLabel = 'Submit',
    this.cancelLabel = 'Cancel',
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.isDismissible = true,
    this.backgroundColor,
    this.borderRadius,
    this.maxHeight,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: title,
      subtitle: subtitle,
      content: form,
      isLoading: isLoading,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      variant: BottomSheetVariant.standard,
      maxHeight: maxHeight,
      isScrollable: isScrollable,
      actions: [
        AppButton(
          text: cancelLabel,
          onPressed: isLoading ? null : onCancel,
          variant: ButtonVariant.text,
        ),
        AppButton(
          text: submitLabel,
          onPressed: isLoading ? null : onSubmit,
          variant: ButtonVariant.primary,
        ),
      ],
    );
  }
}
