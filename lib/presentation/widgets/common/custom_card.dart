import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.height,
    this.width,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border:
            border ??
            Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing24),
            child: child,
          ),
        ),
      ),
    );
  }
}
