import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../spacing.dart';

/// A text input component following Material Design guidelines
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool isDisabled;
  final bool isReadOnly;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final InputVariant variant;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final EdgeInsets? contentPadding;
  final bool showCounter;
  final bool autofocus;
  final bool enableInteractiveSelection;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.variant = InputVariant.outlined,
    this.focusNode,
    this.autovalidateMode,
    this.validator,
    this.contentPadding,
    this.showCounter = false,
    this.autofocus = false,
    this.enableInteractiveSelection = true,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.fillColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultBorderRadius =
        borderRadius ?? BorderRadius.circular(Spacing.radiusMd);
    final defaultContentPadding = contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: Spacing.inputPaddingHorizontal,
          vertical: Spacing.inputPaddingVertical,
        );

    final effectiveLabel = label != null
        ? isRequired
            ? '$label *'
            : label
        : null;

    final decoration = InputDecoration(
      labelText: effectiveLabel,
      hintText: hint,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefix,
      suffixIcon: suffix,
      counterText: showCounter ? null : '',
      contentPadding: defaultContentPadding,
      filled: variant == InputVariant.filled,
      fillColor: isDisabled
          ? colors.disabledBackground
          : fillColor ?? colors.background,
      border: _getBorder(colors, defaultBorderRadius),
      enabledBorder: _getBorder(colors, defaultBorderRadius),
      focusedBorder: _getFocusedBorder(colors, defaultBorderRadius),
      errorBorder: _getErrorBorder(colors, defaultBorderRadius),
      focusedErrorBorder: _getErrorBorder(colors, defaultBorderRadius),
      disabledBorder: _getDisabledBorder(colors, defaultBorderRadius),
      labelStyle: labelStyle?.copyWith(
            color: isDisabled
                ? colors.disabledForeground
                : errorText != null
                    ? colors.error
                    : colors.foreground,
          ) ??
          theme.textTheme.bodyLarge?.copyWith(
            color: isDisabled
                ? colors.disabledForeground
                : errorText != null
                    ? colors.error
                    : colors.foreground,
          ),
      hintStyle: hintStyle?.copyWith(
            color: colors.hint,
          ) ??
          theme.textTheme.bodyLarge?.copyWith(
            color: colors.hint,
          ),
      errorStyle: errorStyle?.copyWith(
            color: colors.error,
          ) ??
          theme.textTheme.bodySmall?.copyWith(
            color: colors.error,
          ),
      helperStyle: helperStyle?.copyWith(
            color: colors.helper,
          ) ??
          theme.textTheme.bodySmall?.copyWith(
            color: colors.helper,
          ),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onTap: isDisabled ? null : onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      obscureText: obscureText,
      readOnly: isReadOnly || isDisabled,
      autovalidateMode: autovalidateMode,
      validator: validator,
      autofocus: autofocus,
      enableInteractiveSelection: enableInteractiveSelection,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      style: style?.copyWith(
            color: isDisabled ? colors.disabledForeground : colors.foreground,
          ) ??
          theme.textTheme.bodyLarge?.copyWith(
            color: isDisabled ? colors.disabledForeground : colors.foreground,
          ),
    );
  }

  InputBorder _getBorder(InputColors colors, BorderRadius borderRadius) {
    switch (variant) {
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.border),
        );
      case InputVariant.filled:
        return UnderlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.border),
        );
    }
  }

  InputBorder _getFocusedBorder(InputColors colors, BorderRadius borderRadius) {
    switch (variant) {
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.focused, width: 2),
        );
      case InputVariant.filled:
        return UnderlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.focused, width: 2),
        );
    }
  }

  InputBorder _getErrorBorder(InputColors colors, BorderRadius borderRadius) {
    switch (variant) {
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.error),
        );
      case InputVariant.filled:
        return UnderlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.error),
        );
    }
  }

  InputBorder _getDisabledBorder(
      InputColors colors, BorderRadius borderRadius) {
    switch (variant) {
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.disabledBorder),
        );
      case InputVariant.filled:
        return UnderlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.disabledBorder),
        );
    }
  }

  InputColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return InputColors(
      background: colorScheme.surface,
      foreground: colorScheme.onSurface,
      border: colorScheme.outline,
      focused: colorScheme.primary,
      error: colorScheme.error,
      hint: colorScheme.onSurfaceVariant,
      helper: colorScheme.onSurfaceVariant,
      disabledBackground: colorScheme.surfaceContainerHighest,
      disabledForeground: colorScheme.onSurfaceVariant,
      disabledBorder: colorScheme.outlineVariant,
    );
  }
}

/// Input variants
enum InputVariant {
  outlined,
  filled,
}

/// Helper class for input colors
class InputColors {
  final Color background;
  final Color foreground;
  final Color border;
  final Color focused;
  final Color error;
  final Color hint;
  final Color helper;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color disabledBorder;

  const InputColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.focused,
    required this.error,
    required this.hint,
    required this.helper,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.disabledBorder,
  });
}

/// A search input component
class AppSearchField extends StatelessWidget {
  final String? hint;
  final String? errorText;
  final bool isDisabled;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const AppSearchField({
    super.key,
    this.hint,
    this.errorText,
    this.isDisabled = false,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onSearch,
    this.focusNode,
    this.textInputAction,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final defaultBorderRadius =
        borderRadius ?? BorderRadius.circular(Spacing.radiusFull);
    final defaultContentPadding = contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: Spacing.inputPaddingHorizontal,
          vertical: Spacing.inputPaddingVertical,
        );

    return AppTextField(
      hint: hint ?? 'Search',
      errorText: errorText,
      isDisabled: isDisabled,
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.search,
      onSubmitted: (_) => onSearch?.call(),
      contentPadding: defaultContentPadding,
      fillColor: fillColor ?? colors.searchBackground,
      borderRadius: defaultBorderRadius,
      prefix: Icon(
        Icons.search,
        size: 20,
        color: colors.searchIcon,
      ),
      suffix: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: Icon(
                Icons.clear,
                size: 20,
                color: colors.searchIcon,
              ),
              onPressed: isDisabled ? null : onClear,
            )
          : null,
      variant: InputVariant.filled,
    );
  }

  SearchColors _getColors(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return SearchColors(
      searchBackground: colorScheme.surfaceContainerHighest,
      searchIcon: colorScheme.onSurfaceVariant,
    );
  }
}

/// Helper class for search colors
class SearchColors {
  final Color searchBackground;
  final Color searchIcon;

  const SearchColors({
    required this.searchBackground,
    required this.searchIcon,
  });
}
