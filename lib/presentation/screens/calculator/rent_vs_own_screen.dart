import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class RentVsOwnScreen extends ConsumerStatefulWidget {
  const RentVsOwnScreen({super.key});

  @override
  ConsumerState<RentVsOwnScreen> createState() => _RentVsOwnScreenState();
}

class _RentVsOwnScreenState extends ConsumerState<RentVsOwnScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  double _breakEvenYears = 0;
  List<Map<String, dynamic>> _chartData = [];

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
        _breakEvenYears = service.calculateBreakEvenYears(
          yearlySaasCost: saasCost,
          customBuildCost: buildCost,
          yearlyMaintenanceCost: maintenanceCost,
        );

        // Generate data for 5 years
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
      appBar: AppBar(title: const Text('Rent vs. Own Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'saas_cost',
                        decoration: const InputDecoration(
                          labelText: 'Yearly SaaS Cost (\$)',
                          prefixIcon: Icon(Icons.cloud),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      FormBuilderTextField(
                        name: 'build_cost',
                        decoration: const InputDecoration(
                          labelText: 'Custom Build Cost (\$)',
                          prefixIcon: Icon(Icons.build),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      FormBuilderTextField(
                        name: 'maintenance_cost',
                        decoration: const InputDecoration(
                          labelText: 'Yearly Maintenance Cost (\$)',
                          prefixIcon: Icon(Icons.build_circle),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _calculate,
                          child: const Text('Calculate Break-Even'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            if (_chartData.isNotEmpty) ...[
              Text(
                _breakEvenYears > 0
                    ? 'Break-even in ${_breakEvenYears.toStringAsFixed(1)} years'
                    : 'SaaS is always cheaper (or equal)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              AspectRatio(
                aspectRatio: 1.5,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (val, meta) =>
                              Text('Year ${val.toInt()}'),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // SaaS Line
                      LineChartBarData(
                        spots: _chartData
                            .map((d) => FlSpot(d['year'].toDouble(), d['saas']))
                            .toList(),
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                      ),
                      // Own Line
                      LineChartBarData(
                        spots: _chartData
                            .map((d) => FlSpot(d['year'].toDouble(), d['own']))
                            .toList(),
                        isCurved: true,
                        color: AppTheme.accentColor,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.circle,
                    color: AppTheme.primaryColor,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  const Text('SaaS (Rent)'),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.circle,
                    color: AppTheme.accentColor,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  const Text('Custom (Own)'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
