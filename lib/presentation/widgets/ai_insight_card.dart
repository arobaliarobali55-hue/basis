import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum InsightPriority { high, medium, low }

class AiInsightCard extends StatelessWidget {
  final InsightPriority priority;
  final IconData icon;
  final String title;
  final String description;
  final String savingsLabel;
  final String savingsValue;
  final Color savingsColor;
  final VoidCallback? onAction;

  const AiInsightCard({
    super.key,
    required this.priority,
    required this.icon,
    required this.title,
    required this.description,
    required this.savingsLabel,
    required this.savingsValue,
    required this.savingsColor,
    this.onAction,
  });

  String get priorityText {
    switch (priority) {
      case InsightPriority.high:
        return 'HIGH PRIORITY';
      case InsightPriority.medium:
        return 'MEDIUM PRIORITY';
      case InsightPriority.low:
        return 'UPCOMING RENEWAL';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case InsightPriority.high:
        return AppTheme.errorColor;
      case InsightPriority.medium:
        return AppTheme.warningColor;
      case InsightPriority.low:
        return AppTheme.accentColor;
    }
  }

  Color get priorityBgColor {
    switch (priority) {
      case InsightPriority.high:
        return AppTheme.errorColor.withOpacity(0.1);
      case InsightPriority.medium:
        return AppTheme.warningColor.withOpacity(0.1);
      case InsightPriority.low:
        return AppTheme.accentColor.withOpacity(0.1);
    }
  }

  Color get iconBgColor {
    switch (priority) {
      case InsightPriority.high:
        return const Color(0xFF3d1f1f);
      case InsightPriority.medium:
        return const Color(0xFF3d331f);
      case InsightPriority.low:
        return const Color(0xFF1f3d2f);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and priority badge
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: priorityColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priorityText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(
            color: AppTheme.borderColor.withOpacity(0.5),
            height: 1,
          ),
          const SizedBox(height: 16),

          // Bottom row with savings and action button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savingsLabel.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      savingsValue,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: savingsColor,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Take Action',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
