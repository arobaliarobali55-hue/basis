import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:basis/core/theme/app_theme.dart';
import 'package:basis/presentation/providers/app_providers.dart';
import 'package:basis/presentation/widgets/common/custom_card.dart';
import 'package:basis/presentation/widgets/dashboard/statistic_widget.dart';

class RentVsOwnScreen extends ConsumerStatefulWidget {
  const RentVsOwnScreen({super.key});

  @override
  ConsumerState<RentVsOwnScreen> createState() => _RentVsOwnScreenState();
}

class _RentVsOwnScreenState extends ConsumerState<RentVsOwnScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Results
  double _breakEvenYears = 0;
  List<Map<String, dynamic>> _chartData = [];
  bool _hasCalculated = false;

  void _calculate() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final saasCost = double.parse(values['saas_cost'].toString());
      final buildCost = double.parse(values['build_cost'].toString());
      final maintenanceCost = double.parse(
        values['maintenance_cost'].toString(),
      );

      final service = ref.read(breakEvenServiceProvider);

      setState(() {
        _hasCalculated = true;
        _breakEvenYears = service.calculateBreakEvenYears(
          yearlySaasCost: saasCost,
          customBuildCost: buildCost,
          yearlyMaintenanceCost: maintenanceCost,
        );

        final rawData = service.generateComparisonData(
          yearlySaasCost: saasCost,
          customBuildCost: buildCost,
          yearlyMaintenanceCost: maintenanceCost,
          years: 5,
        );

        _chartData = rawData
            .map(
              (d) => {
                'year': d.year,
                'saas': d.saasCumulativeCost,
                'own': d.ownCumulativeCost,
              },
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent vs. Own Strategy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Strategic Comparison',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Evaluate the long-term financial impact of building internal tools vs subscribing to SaaS.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing24),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: _buildInputForm()),
                        const SizedBox(width: AppTheme.spacing24),
                        Expanded(flex: 2, child: _buildResultsSection()),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      _buildInputForm(),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildResultsSection(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return CustomCard(
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Parameters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacing24),

            _buildInputField(
              'saas_cost',
              'Yearly SaaS Cost',
              Icons.cloud_outlined,
              'e.g. 12000',
            ),
            const SizedBox(height: AppTheme.spacing16),

            _buildInputField(
              'build_cost',
              'Initial Build Cost',
              Icons.code,
              'e.g. 50000',
            ),
            const SizedBox(height: AppTheme.spacing16),

            _buildInputField(
              'maintenance_cost',
              'Yearly Maintenance',
              Icons.build_circle_outlined,
              'e.g. 5000',
            ),

            const SizedBox(height: AppTheme.spacing32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Compare Strategies'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String name,
    String label,
    IconData icon,
    String hint,
  ) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixText: 'USD',
      ),
      keyboardType: TextInputType.number,
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildResultsSection() {
    if (!_hasCalculated) {
      return CustomCard(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 64,
                color: AppTheme.textTertiary.withOpacity(0.5),
              ),
              const SizedBox(height: AppTheme.spacing16),
              const Text(
                'Enter cost parameters to generate strategic analysis',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Key Metrics
        Row(
          children: [
            Expanded(
              child: StatisticWidget(
                title: 'Break-Even Point',
                value: _breakEvenYears > 0
                    ? '${_breakEvenYears.toStringAsFixed(1)} Years'
                    : 'Never',
                icon: Icons.timer_outlined,
                iconColor: _breakEvenYears > 0 && _breakEvenYears < 3
                    ? AppTheme.accentColor
                    : AppTheme.warningColor,
                subtitle: _breakEvenYears > 0
                    ? 'ROI realized after this period'
                    : 'SaaS is always cheaper',
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: StatisticWidget(
                title: '5-Year Savings',
                value: _calculateSavings(),
                icon: Icons.savings_outlined,
                iconColor: AppTheme.secondaryColor,
                subtitle: 'Projected difference',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Chart
        CustomCard(
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cumulative Cost Trajectory',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildLegend(),
                ],
              ),
              const SizedBox(height: AppTheme.spacing24),
              Expanded(child: _buildChart()),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacing16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _formKey.currentState?.save();
              final values = _formKey.currentState?.value ?? {};
              final buildCost = values['build_cost'] ?? '0';
              showDialog(
                context: context,
                builder: (context) =>
                    _RiskAnalysisDialog(buildCost: buildCost.toString()),
              );
            },
            icon: const Icon(Icons.psychology),
            label: const Text('Analyze Implementation Risk (AI)'),
          ),
        ),
      ],
    );
  }

  String _calculateSavings() {
    if (_chartData.isEmpty) return '\$0';
    final lastYear = _chartData.last;
    final diff = (lastYear['saas'] as double) - (lastYear['own'] as double);
    return diff > 0
        ? '\$${diff.toStringAsFixed(0)}'
        : '-\$${diff.abs().toStringAsFixed(0)}';
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem('SaaS', AppTheme.primaryColor),
        const SizedBox(width: 16),
        _legendItem('Own (Build)', AppTheme.accentColor),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderColor.withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, meta) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Year ${val.toInt()}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, meta) => Text(
                '${val ~/ 1000}k',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _chartData
                .map((d) => FlSpot(d['year'].toDouble(), d['saas']))
                .toList(),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: _chartData
                .map((d) => FlSpot(d['year'].toDouble(), d['own']))
                .toList(),
            isCurved: true,
            color: AppTheme.accentColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _RiskAnalysisDialog extends ConsumerStatefulWidget {
  final String buildCost;
  const _RiskAnalysisDialog({required this.buildCost});

  @override
  ConsumerState<_RiskAnalysisDialog> createState() =>
      _RiskAnalysisDialogState();
}

class _RiskAnalysisDialogState extends ConsumerState<_RiskAnalysisDialog> {
  String _result = "Analyzing project complexity and risk factors...";

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    final aiService = ref.read(aiAnalysisServiceProvider);
    try {
      final result = await aiService.predictBusinessRisk(
        type: "Custom Software Build",
        location: "Internal Tool",
        budget: double.tryParse(widget.buildCost) ?? 0,
      );

      if (mounted) {
        setState(() => _result = result);
      }
    } catch (e) {
      if (mounted) setState(() => _result = "Analysis failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: const Text('AI Risk Analysis'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_result.startsWith("Analyzing"))
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: LinearProgressIndicator(),
              ),
            Text(_result),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
