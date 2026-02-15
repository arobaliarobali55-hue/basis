import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class DataImportScreen extends ConsumerStatefulWidget {
  const DataImportScreen({super.key});

  @override
  ConsumerState<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends ConsumerState<DataImportScreen> {
  List<Map<String, dynamic>> _previewData = [];
  bool _isLoading = false;

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    final importService = ref.read(csvImportServiceProvider);
    try {
      final data = await importService.pickAndParseCsv();
      setState(() {
        _previewData = data;
      });

      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No subscription data found in CSV.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importSelected() async {
    // Logic to save selected items to Supabase
    // Ideally update a provider or call a repository
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported ${_previewData.length} subscriptions!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Subscriptions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload CSV Statement'),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),

            if (_previewData.isNotEmpty) ...[
              Text(
                'Found ${_previewData.length} potential subscriptions:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _previewData.length,
                  itemBuilder: (context, index) {
                    final item = _previewData[index];
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(item['name']),
                      subtitle: Text(item['category']),
                      trailing: Text('\$${item['price']}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _importSelected,
                  child: const Text('Confirm Import'),
                ),
              ),
            ],

            if (!_isLoading && _previewData.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Upload a CSV bank statement to detecting recurring SaaS payments.\n\nWe look for keywords like "Software", "Subscription", "Slack", "Zoom", etc.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
