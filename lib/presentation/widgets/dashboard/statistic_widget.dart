import 'package:flutter/material.dart';
import 'package:basis/core/theme/app_theme.dart';
import 'package:basis/presentation/widgets/common/custom_card.dart';

class StatisticWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final double? trend; // Positive for growth, negative for decline
  final bool isCurrency;

  const StatisticWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.iconColor,
    this.trend,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine trend color and icon
    Color trendColor = AppTheme.textSecondary;
    IconData? trendIcon;

    if (trend != null) {
      if (trend! > 0) {
        trendColor = AppTheme.accentColor;
        trendIcon = Icons.arrow_upward;
      } else if (trend! < 0) {
        trendColor = AppTheme.errorColor;
        trendIcon = Icons.arrow_downward;
      } else {
        trendColor = AppTheme.textSecondary;
        trendIcon = Icons.remove;
      }
    }

    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 28),
          ),
          if (subtitle != null || trend != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (trend != null) ...[
                  Icon(trendIcon, size: 14, color: trendColor),
                  const SizedBox(width: 4),
                  Text(
                    '${trend!.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
