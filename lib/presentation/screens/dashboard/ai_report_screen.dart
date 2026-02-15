import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:basis/presentation/widgets/common/entry_animation.dart';
import '../../providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class AiReportScreen extends ConsumerStatefulWidget {
  const AiReportScreen({super.key});

  @override
  ConsumerState<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends ConsumerState<AiReportScreen> {
  String? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    final tools = ref.read(toolsProvider).valueOrNull ?? [];
    final aiService = ref.read(aiAnalysisServiceProvider);

    try {
      final report = await aiService.analyzeToolStack(tools);
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _report =
              "Error generating report: $e\n\nPlease check your API Key configuration.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Optimization Report')),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  Text(
                    'Analyzing your tech stack with AI...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: EntryAnimation(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: MarkdownBody(
                      data: _report ?? 'No data.',
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        h1: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 2.0,
                            ),
                        h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                          height: 1.8,
                        ),
                        p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                        listBullet: const TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                        blockquote: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: AppTheme.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                        blockquoteDecoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                          border: const Border(
                            left: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
