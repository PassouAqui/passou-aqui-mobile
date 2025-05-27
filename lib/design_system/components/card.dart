import 'package:flutter/material.dart';
import '../spacing.dart';

/// A card component following Material Design guidelines
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final CardVariant variant;
  final bool isLoading;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget? header;
  final Widget? footer;
  final List<Widget>? actions;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.variant = CardVariant.elevated,
    this.isLoading = false,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.header,
    this.footer,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultPadding = padding ?? const EdgeInsets.all(Spacing.cardPadding);
    final defaultBorderRadius =
        borderRadius ?? BorderRadius.circular(Spacing.radiusLg);
    final defaultElevation = elevation ?? _getElevation(variant);

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          header!,
          const SizedBox(height: Spacing.sm),
        ],
        child,
        if (footer != null) ...[
          const SizedBox(height: Spacing.sm),
          footer!,
        ],
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: Spacing.md),
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
      ],
    );

    if (isLoading) {
      cardContent = Stack(
        children: [
          cardContent,
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

    final card = Card(
      elevation: defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: defaultBorderRadius,
        side: variant == CardVariant.outlined
            ? BorderSide(color: colors.outline)
            : BorderSide.none,
      ),
      color: backgroundColor ?? colors.background,
      child: Padding(
        padding: defaultPadding,
        child: cardContent,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: defaultBorderRadius,
        child: card,
      );
    }

    return card;
  }

  CardColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return CardColors(
      background: colorScheme.surface,
      primary: colorScheme.primary,
      outline: colorScheme.outline,
    );
  }

  double _getElevation(CardVariant variant) {
    switch (variant) {
      case CardVariant.elevated:
        return Spacing.elevationMd;
      case CardVariant.outlined:
      case CardVariant.flat:
        return Spacing.elevationNone;
    }
  }
}

/// Card variants
enum CardVariant {
  elevated,
  outlined,
  flat,
}

/// Helper class for card colors
class CardColors {
  final Color background;
  final Color primary;
  final Color outline;

  const CardColors({
    required this.background,
    required this.primary,
    required this.outline,
  });
}

/// A section card that groups related content
class AppSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final bool isLoading;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const AppSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.isLoading = false,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    return AppCard(
      variant: CardVariant.elevated,
      isLoading: isLoading,
      padding: padding,
      backgroundColor: backgroundColor,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!
                      .map((action) => Padding(
                            padding: const EdgeInsets.only(left: Spacing.sm),
                            child: action,
                          ))
                      .toList(),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
        ],
      ),
      child: child,
    );
  }

  SectionCardColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return SectionCardColors(
      primary: colorScheme.primary,
      secondary: colorScheme.onSurfaceVariant,
    );
  }
}

/// Helper class for section card colors
class SectionCardColors {
  final Color primary;
  final Color secondary;

  const SectionCardColors({
    required this.primary,
    required this.secondary,
  });
}
