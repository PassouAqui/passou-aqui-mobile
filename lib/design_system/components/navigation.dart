import 'package:flutter/material.dart';
import '../spacing.dart';

/// A navigation bar component following Material Design guidelines
class AppNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int>? onDestinationSelected;
  final bool isLoading;
  final Color? backgroundColor;
  final double? elevation;
  final NavigationBarVariant variant;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.destinations,
    this.onDestinationSelected,
    this.isLoading = false,
    this.backgroundColor,
    this.elevation,
    this.variant = NavigationBarVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultElevation = elevation ?? _getElevation(variant);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: isLoading ? null : onDestinationSelected,
      backgroundColor: backgroundColor ?? colors.background,
      elevation: defaultElevation,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: destinations,
    );
  }

  NavigationBarColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return NavigationBarColors(
      background: colorScheme.surface,
      icon: colorScheme.onSurfaceVariant,
      selectedIcon: colorScheme.primary,
    );
  }

  double _getElevation(NavigationBarVariant variant) {
    switch (variant) {
      case NavigationBarVariant.standard:
        return Spacing.elevationSm;
      case NavigationBarVariant.elevated:
        return Spacing.elevationMd;
      case NavigationBarVariant.flat:
        return Spacing.elevationNone;
    }
  }
}

/// Navigation bar variants
enum NavigationBarVariant {
  standard,
  elevated,
  flat,
}

/// Helper class for navigation bar colors
class NavigationBarColors {
  final Color background;
  final Color icon;
  final Color selectedIcon;

  const NavigationBarColors({
    required this.background,
    required this.icon,
    required this.selectedIcon,
  });
}

/// A navigation rail destination component
class NavigationRailDestinationData {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const NavigationRailDestinationData({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// A navigation rail component
class AppNavigationRail extends StatelessWidget {
  final int currentIndex;
  final List<NavigationRailDestinationData> destinations;
  final ValueChanged<int>? onDestinationSelected;
  final bool isLoading;
  final Color? backgroundColor;
  final double? elevation;
  final NavigationRailVariant variant;
  final bool extended;
  final double? minWidth;
  final double? minExtendedWidth;
  final Widget? leading;
  final Widget? trailing;

  const AppNavigationRail({
    super.key,
    required this.currentIndex,
    required this.destinations,
    this.onDestinationSelected,
    this.isLoading = false,
    this.backgroundColor,
    this.elevation,
    this.variant = NavigationRailVariant.standard,
    this.extended = false,
    this.minWidth,
    this.minExtendedWidth,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultElevation = elevation ?? _getElevation(variant);

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: isLoading ? null : onDestinationSelected,
      backgroundColor: backgroundColor ?? colors.background,
      elevation: defaultElevation,
      extended: extended,
      minWidth: minWidth ?? 72,
      minExtendedWidth: minExtendedWidth ?? 256,
      leading: leading,
      trailing: trailing,
      destinations: destinations.map((destination) {
        return NavigationRailDestination(
          icon: Icon(destination.icon, color: colors.icon),
          selectedIcon: Icon(destination.selectedIcon ?? destination.icon,
              color: colors.selectedIcon),
          label: Text(destination.label,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.label)),
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.navigationRailPadding,
          ),
        );
      }).toList(),
    );
  }

  NavigationRailColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return NavigationRailColors(
      background: colorScheme.surface,
      icon: colorScheme.onSurfaceVariant,
      selectedIcon: colorScheme.primary,
      label: colorScheme.onSurfaceVariant,
    );
  }

  double _getElevation(NavigationRailVariant variant) {
    switch (variant) {
      case NavigationRailVariant.standard:
        return Spacing.elevationSm;
      case NavigationRailVariant.elevated:
        return Spacing.elevationMd;
      case NavigationRailVariant.flat:
        return Spacing.elevationNone;
    }
  }
}

/// Navigation rail variants
enum NavigationRailVariant {
  standard,
  elevated,
  flat,
}

/// Helper class for navigation rail colors
class NavigationRailColors {
  final Color background;
  final Color icon;
  final Color selectedIcon;
  final Color label;

  const NavigationRailColors({
    required this.background,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// A navigation drawer component
class AppNavigationDrawer extends StatelessWidget {
  final List<Widget> destinations;
  final int? selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final bool isLoading;
  final Color? backgroundColor;
  final double? elevation;
  final NavigationDrawerVariant variant;
  final Widget? header;
  final Widget? footer;

  const AppNavigationDrawer({
    super.key,
    required this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
    this.isLoading = false,
    this.backgroundColor,
    this.elevation,
    this.variant = NavigationDrawerVariant.standard,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultElevation = elevation ?? _getElevation(variant);

    return NavigationDrawer(
      backgroundColor: backgroundColor ?? colors.background,
      elevation: defaultElevation,
      children: [
        if (header != null) ...[
          header!,
          Divider(
            height: 1,
            thickness: 1,
            color: colors.divider,
          ),
        ],
        ...destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final destination = entry.value;
          final isSelected = index == selectedIndex;

          return ListTile(
            leading: Icon(
              (destination as NavigationDrawerDestination).icon,
              color: isSelected ? colors.selectedIcon : colors.icon,
            ),
            title: Text(
              (destination as NavigationDrawerDestination).label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected ? colors.selectedLabel : colors.label,
              ),
            ),
            selected: isSelected,
            onTap: isLoading ? null : () => onDestinationSelected?.call(index),
          );
        }),
        if (footer != null) ...[
          Divider(
            height: 1,
            thickness: 1,
            color: colors.divider,
          ),
          footer!,
        ],
      ],
    );
  }

  NavigationDrawerColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return NavigationDrawerColors(
      background: colorScheme.surface,
      icon: colorScheme.onSurfaceVariant,
      selectedIcon: colorScheme.primary,
      label: colorScheme.onSurfaceVariant,
      selectedLabel: colorScheme.primary,
      divider: colorScheme.outlineVariant,
    );
  }

  double _getElevation(NavigationDrawerVariant variant) {
    switch (variant) {
      case NavigationDrawerVariant.standard:
        return Spacing.elevationSm;
      case NavigationDrawerVariant.elevated:
        return Spacing.elevationMd;
      case NavigationDrawerVariant.flat:
        return Spacing.elevationNone;
    }
  }
}

/// Navigation drawer variants
enum NavigationDrawerVariant {
  standard,
  elevated,
  flat,
}

/// Helper class for navigation drawer colors
class NavigationDrawerColors {
  final Color background;
  final Color icon;
  final Color selectedIcon;
  final Color label;
  final Color selectedLabel;
  final Color divider;

  const NavigationDrawerColors({
    required this.background,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selectedLabel,
    required this.divider,
  });
}

/// A navigation destination component
class NavigationDrawerDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const NavigationDrawerDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Helper class to create navigation destinations
class NavigationDestinationBuilder {
  /// Creates a navigation bar destination
  static NavigationDestination createBarDestination({
    required IconData icon,
    IconData? selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: label,
    );
  }

  /// Creates a navigation rail destination
  static NavigationRailDestinationData createRailDestination({
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    EdgeInsets? padding,
  }) {
    return NavigationRailDestinationData(
      icon: icon,
      selectedIcon: selectedIcon,
      label: label,
    );
  }

  /// Creates a navigation drawer destination
  static NavigationDrawerDestination createDrawerDestination({
    required IconData icon,
    IconData? selectedIcon,
    required String label,
  }) {
    return NavigationDrawerDestination(
      icon: icon,
      selectedIcon: selectedIcon,
      label: label,
    );
  }
}
