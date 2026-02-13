import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _competitorPriceController = TextEditingController();
  final _yearlyIncreaseController = TextEditingController();
  final _activationFeeController = TextEditingController();
  final _flatMonthlyController = TextEditingController();

  @override
  void dispose() {
    _competitorPriceController.dispose();
    _yearlyIncreaseController.dispose();
    _activationFeeController.dispose();
    _flatMonthlyController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final state = RentVsOwnState(
      competitorMonthlyPrice: double.parse(_competitorPriceController.text),
      competitorYearlyIncrease: double.parse(_yearlyIncreaseController.text),
      activationFee: double.parse(_activationFeeController.text),
      flatMonthlyFee: double.parse(_flatMonthlyController.text),
    );

    ref.read(rentVsOwnStateProvider.notifier).state = state;
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(rentVsOwnResultProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Rent vs Own Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Competitor Pricing',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacing16),

                      // Competitor Monthly Price
                      TextFormField(
                        controller: _competitorPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Price',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing16),

                      // Yearly Increase
                      TextFormField(
                        controller: _yearlyIncreaseController,
                        decoration: const InputDecoration(
                          labelText: 'Yearly Price Increase (%)',
                          prefixIcon: Icon(Icons.trending_up),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final rate = double.tryParse(value);
                          if (rate == null || rate < 0 || rate > 100) {
                            return 'Invalid percentage';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      Text(
                        'Your Pricing',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacing16),

                      // Activation Fee
                      TextFormField(
                        controller: _activationFeeController,
                        decoration: const InputDecoration(
                          labelText: 'One-time Activation Fee',
                          prefixIcon: Icon(Icons.payment),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final fee = double.tryParse(value);
                          if (fee == null || fee < 0) {
                            return 'Invalid fee';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing16),

                      // Flat Monthly Fee
                      TextFormField(
                        controller: _flatMonthlyController,
                        decoration: const InputDecoration(
                          labelText: 'Flat Monthly Fee',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final fee = double.tryParse(value);
                          if (fee == null || fee < 0) {
                            return 'Invalid fee';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _calculate,
                          child: const Text('Calculate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Results
            if (result['breakEvenMonth'] != null) ...[
              // Break-even Card
              Card(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        'Break-even Month',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Month ${result['breakEvenMonth']}',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Savings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    children: [
                      Text(
                        '3-Year Savings',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        currencyFormat.format(result['threeYearSavings']),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: result['threeYearSavings'] > 0
                                  ? AppTheme.accentColor
                                  : AppTheme.errorColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Competitor',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(
                                  result['competitorTotal'],
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Your Cost',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(result['ownTotal']),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),

              // Comparison Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost Comparison',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      SizedBox(
                        height: 300,
                        child: _ComparisonChart(
                          monthlyData:
                              result['monthlyData']
                                  as Map<int, Map<String, double>>,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonChart extends StatelessWidget {
  final Map<int, Map<String, double>> monthlyData;

  const _ComparisonChart({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final maxY =
        monthlyData.values
            .map(
              (m) =>
                  [m['competitor']!, m['own']!].reduce((a, b) => a > b ? a : b),
            )
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.borderColor.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}k',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 6,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 12 == 0 && value > 0) {
                  final year = value.toInt() ~/ 12;
                  return Text(
                    'Y$year',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 36,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          // Competitor line
          LineChartBarData(
            spots: monthlyData.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value['competitor']!))
                .toList(),
            isCurved: true,
            color: AppTheme.errorColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
          // Own line
          LineChartBarData(
            spots: monthlyData.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value['own']!))
                .toList(),
            isCurved: true,
            color: AppTheme.accentColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
