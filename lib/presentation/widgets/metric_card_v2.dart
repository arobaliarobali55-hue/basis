import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class MetricCardV2 extends StatelessWidget {
  final String label;
  final double value;
  final String? suffix;
  final double? trend;
  final String? trendLabel;
  final bool isLoading;
  final String? prefix;
  final bool isCompact;

  const MetricCardV2({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.trend,
    this.trendLabel,
    this.isLoading = false,
    this.prefix,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: prefix ?? '\$',
      decimalDigits: 0,
    );

    final compactFormat = NumberFormat.compactCurrency(
      symbol: prefix ?? '\$',
      decimalDigits: 2,
    );

    String formattedValue;
    if (value >= 1000000) {
      formattedValue = compactFormat.format(value);
    } else {
      formattedValue = currencyFormat.format(value);
    }

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: isCompact ? 9 : 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiary,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isCompact ? 8 : 12),
          if (isLoading)
            SizedBox(
              height: isCompact ? 24 : 32,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    formattedValue,
                    style: TextStyle(
                      fontSize: isCompact ? 16 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (suffix != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      suffix!,
                      style: TextStyle(
                        fontSize: isCompact ? 10 : 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          if (trend != null) ...[
            SizedBox(height: isCompact ? 4 : 8),
            Row(
              children: [
                Icon(
                  trend! >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: isCompact ? 12 : 14,
                  color: trend! >= 0 ? AppTheme.accentColor : AppTheme.errorColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trend!.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: trend! >= 0 ? AppTheme.accentColor : AppTheme.errorColor,
                  ),
                ),
                if (trendLabel != null && !isCompact) ...[
                  const SizedBox(width: 4),
                  Text(
                    trendLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
