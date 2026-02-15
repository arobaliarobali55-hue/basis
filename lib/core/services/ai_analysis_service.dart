import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/tool_entity.dart';
import '../constants/app_constants.dart';

class AiAnalysisService {
  final GenerativeModel _model;

  // IMPORTANT: For this demo, we assume the API key is provided via constructor or environment.
  // In a real app, this should be securely managed.
  AiAnalysisService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  Future<String> analyzeToolStack(List<ToolEntity> tools) async {
    if (tools.isEmpty) return "No tools to analyze.";

    final toolListString = tools
        .map(
          (t) =>
              "- ${t.toolName} (\$${t.monthlyPrice}/mo, ${t.seats} seats, ${t.category})",
        )
        .join('\n');

    final prompt =
        '''
    You are a SaaS efficiency expert. Analyze the following tech stack for a company:

    $toolListString

    Please provide a concise analysis covering:
    1. **Redundancies**: Are there overlapping tools? (e.g., multiple project management or communication tools).
    2. **Cost Optimization**: specific suggestions to save money (e.g., "Switching from X to Y could save \$Z/mo").
    3. **Missing Critical Tools**: Are there any obvious gaps for a modern tech company?
    4. **3-Year Outlook**: Briefly predict if costs will likely explode based on this mix (e.g. usage-based pricing risks).

    Format the output as a Markdown report. Keep it professional and direct.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Unable to generate analysis.";
    } catch (e) {
      return "Error generating analysis: $e";
    }
  }

  // Future expansion: Predict revenue or risk score based on business inputs
  Future<String> predictBusinessRisk({
    required String type,
    required String location,
    required double budget,
  }) async {
    final prompt =
        '''
      Analyze the risk for a new business:
      Type: $type
      Location: $location
      Initial Budget: \$$budget

      Provide:
      1. Success Probability Score (0-100)
      2. Key Risk Factors
      3. Competition Density (Estimated)
      ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Unable to generate prediction.";
    } catch (e) {
      return "Error: $e";
    }
  }
}
