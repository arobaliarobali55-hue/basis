import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/tool_entity.dart';
import '../constants/app_constants.dart';

class CsvImportService {
  Future<List<Map<String, dynamic>>> pickAndParseCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) return [];

      final file = File(result.files.single.path!);
      final input = file.openRead();
      final fields = await input
          .transform(const SystemEncoding().decoder)
          .transform(const CsvToListConverter())
          .toList();

      if (fields.isEmpty) return [];

      // Simple heuristic: Assume headers are in row 0
      final headers = fields[0].map((e) => e.toString().toLowerCase()).toList();

      // Find indices for 'description' and 'amount'
      int descIndex = headers.indexWhere(
        (h) =>
            h.contains('desc') || h.contains('merchant') || h.contains('name'),
      );
      int amountIndex = headers.indexWhere(
        (h) =>
            h.contains('amount') || h.contains('cost') || h.contains('price'),
      );

      if (descIndex == -1 || amountIndex == -1) {
        // Fallback: try column 1 for description, column 2 for amount if headers fail
        descIndex = 1;
        amountIndex = 2;
      }

      final List<Map<String, dynamic>> potentialSubs = [];

      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length <= amountIndex || row.length <= descIndex) continue;

        final description = row[descIndex].toString();
        // Clean up amount (remove currency symbols, handle negatives)
        String amountStr = row[amountIndex].toString().replaceAll(
          RegExp(r'[^0-9.]'),
          '',
        );
        final amount = double.tryParse(amountStr);

        if (amount != null && amount > 0) {
          // Check if it looks like a SaaS tool (very basic heuristic)
          // In a real app, we'd check against a database of known SaaS vendors
          if (_isLikelySaaS(description)) {
            potentialSubs.add({
              'name': _cleanName(description),
              'price': amount,
              'category': _guessCategory(description),
            });
          }
        }
      }

      return potentialSubs;
    } catch (e) {
      print('Error parsing CSV: $e');
      return [];
    }
  }

  bool _isLikelySaaS(String description) {
    final text = description.toLowerCase();
    // Common keywords or known tools
    final keywords = [
      'subscription',
      'software',
      'recurring',
      'monthly',
      'yearly',
      'saas',
      'adobe',
      'google',
      'aws',
      'slack',
      'zoom',
      'notion',
      'figma',
      'github',
      'digitalocean',
      'heroku',
      'vercel',
      'netlify',
      'jetbrains',
      'shopify',
      'mailchimp',
      'hubspot',
      'salesforce',
      'atlassian',
      'trello',
      'asana',
    ];

    return keywords.any((k) => text.contains(k));
  }

  String _cleanName(String description) {
    // Very basic cleaning.
    // "Adobe *Creative Cloud" -> "Adobe Creative Cloud"
    return description.replaceAll(RegExp(r'[*#]'), '').trim();
  }

  String _guessCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('slack') || n.contains('zoom') || n.contains('teams'))
      return 'Communication';
    if (n.contains('jira') ||
        n.contains('trello') ||
        n.contains('asana') ||
        n.contains('notion'))
      return 'Project Management';
    if (n.contains('aws') ||
        n.contains('google') ||
        n.contains('azure') ||
        n.contains('vercel'))
      return 'Hosting/Infrastructure';
    if (n.contains('figma') || n.contains('adobe') || n.contains('canva'))
      return 'Design';
    if (n.contains('hubspot') || n.contains('salesforce')) return 'CRM';

    return 'Other';
  }
}
