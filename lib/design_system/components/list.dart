import 'package:flutter/material.dart';
import '../spacing.dart';

/// A list component following Material Design guidelines
class AppList extends StatelessWidget {
  final List<Widget> children;
  final bool isLoading;
  final bool isScrollable;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final ListVariant variant;
  final Widget? emptyState;
  final Widget? loadingState;
  final Widget? errorState;
  final String? errorMessage;

  const AppList({
    super.key,
    required this.children,
    this.isLoading = false,
    this.isScrollable = true,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.variant = ListVariant.elevated,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultPadding =
        padding ?? const EdgeInsets.all(Spacing.listItemPadding);
    final defaultBorderRadius =
        borderRadius ?? BorderRadius.circular(Spacing.radiusLg);

    if (isLoading) {
      return loadingState ??
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          );
    }

    if (errorMessage != null) {
      return errorState ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colors.error,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  errorMessage!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }

    if (children.isEmpty) {
      return emptyState ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: colors.empty,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'No items found',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.empty,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }

    final listContent = ListView.separated(
      padding: defaultPadding,
      itemCount: children.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: colors.divider,
      ),
      itemBuilder: (context, index) => children[index],
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !isScrollable,
    );

    if (variant == ListVariant.elevated) {
      return Card(
        elevation: Spacing.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: defaultBorderRadius,
        ),
        color: backgroundColor ?? colors.background,
        child: ClipRRect(
          borderRadius: defaultBorderRadius,
          child: listContent,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.background,
        borderRadius: defaultBorderRadius,
        border: variant == ListVariant.outlined
            ? Border.all(color: colors.border)
            : null,
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: listContent,
      ),
    );
  }

  ListColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return ListColors(
      background: colorScheme.surface,
      border: colorScheme.outline,
      divider: colorScheme.outlineVariant,
      primary: colorScheme.primary,
      error: colorScheme.error,
      empty: colorScheme.onSurfaceVariant,
    );
  }
}

/// List variants
enum ListVariant {
  elevated,
  outlined,
  flat,
}

/// Helper class for list colors
class ListColors {
  final Color background;
  final Color border;
  final Color divider;
  final Color primary;
  final Color error;
  final Color empty;

  const ListColors({
    required this.background,
    required this.border,
    required this.divider,
    required this.primary,
    required this.error,
    required this.empty,
  });
}

/// A list item component
class AppListItem extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDisabled;
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppListItem({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
    this.contentPadding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultContentPadding = contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: Spacing.listItemPadding,
          vertical: Spacing.sm,
        );
    final defaultBorderRadius =
        borderRadius ?? BorderRadius.circular(Spacing.radiusMd);

    Widget content = Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: Spacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) title!,
              if (subtitle != null) ...[
                const SizedBox(height: Spacing.xs),
                subtitle!,
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: Spacing.md),
          trailing!,
        ],
      ],
    );

    if (backgroundColor != null || isSelected) {
      content = Container(
        decoration: BoxDecoration(
          color: isSelected
              ? colors.selectedBackground
              : backgroundColor ?? colors.background,
          borderRadius: defaultBorderRadius,
        ),
        padding: defaultContentPadding,
        child: content,
      );
    } else {
      content = Padding(
        padding: defaultContentPadding,
        child: content,
      );
    }

    if (onTap != null && !isDisabled) {
      return InkWell(
        onTap: onTap,
        borderRadius: defaultBorderRadius,
        child: content,
      );
    }

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: content,
    );
  }

  ListItemColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return ListItemColors(
      background: colorScheme.surface,
      selectedBackground: colorScheme.primaryContainer,
    );
  }
}

/// Helper class for list item colors
class ListItemColors {
  final Color background;
  final Color selectedBackground;

  const ListItemColors({
    required this.background,
    required this.selectedBackground,
  });
}

/// A list item with a checkbox
class AppCheckboxListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppCheckboxListItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.contentPadding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    return AppListItem(
      leading: Checkbox(
        value: value,
        onChanged: isDisabled ? null : (v) => onChanged?.call(v ?? false),
        activeColor: colors.checkbox,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDisabled ? colors.disabled : colors.foreground,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDisabled ? colors.disabled : colors.secondary,
              ),
            )
          : null,
      onTap: isDisabled ? null : () => onChanged?.call(!value),
      isDisabled: isDisabled,
      contentPadding: contentPadding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
    );
  }

  CheckboxListItemColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return CheckboxListItemColors(
      checkbox: colorScheme.primary,
      foreground: colorScheme.onSurface,
      secondary: colorScheme.onSurfaceVariant,
      disabled: colorScheme.onSurfaceVariant,
    );
  }
}

/// Helper class for checkbox list item colors
class CheckboxListItemColors {
  final Color checkbox;
  final Color foreground;
  final Color secondary;
  final Color disabled;

  const CheckboxListItemColors({
    required this.checkbox,
    required this.foreground,
    required this.secondary,
    required this.disabled,
  });
}
