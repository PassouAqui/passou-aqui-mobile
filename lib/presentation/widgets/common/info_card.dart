import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? titleColor;
  final Color? contentColor;
  final double? iconSize;
  final double? titleFontSize;
  final double? contentFontSize;
  final FontWeight? titleFontWeight;
  final FontWeight? contentFontWeight;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.iconColor,
    this.titleColor,
    this.contentColor,
    this.iconSize,
    this.titleFontSize,
    this.contentFontSize,
    this.titleFontWeight,
    this.contentFontWeight,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize ?? 28,
                  color: iconColor ?? theme.primaryColor,
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize ?? 14,
                        color: titleColor ?? Colors.grey.shade600,
                        fontWeight: titleFontWeight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: contentFontSize ?? 16,
                        fontWeight: contentFontWeight ?? FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
