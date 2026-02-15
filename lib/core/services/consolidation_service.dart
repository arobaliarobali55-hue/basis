import '../../domain/entities/tool_entity.dart';

class ConsolidationService {
  /// Check for consolidation opportunities based on predefined rules
  List<ConsolidationSuggestion> getSuggestions(List<ToolEntity> tools) {
    final suggestions = <ConsolidationSuggestion>[];
    final toolNames = tools.map((t) => t.toolName.toLowerCase()).toSet();

    // Rule 1: Microsoft 365 Consolidation
    if (toolNames.contains('slack') &&
        toolNames.contains('zoom') &&
        (toolNames.contains('trello') || toolNames.contains('asana'))) {
      suggestions.add(
        const ConsolidationSuggestion(
          title: 'Consider Microsoft 365 or Google Workspace',
          description:
              'You are paying separately for Slack, Zoom, and Project Management. '
              'Microsoft 365 (Teams + Planner) or Google Workspace (Meet + Spaces) could replace these for a single subscription.',
          potentialSavings: 'High',
        ),
      );
    }

    // Rule 2: All-in-one CRM
    if (toolNames.contains('mailchimp') &&
        toolNames.contains('salesforce') &&
        toolNames.contains('zendesk')) {
      suggestions.add(
        const ConsolidationSuggestion(
          title: 'Consolidate to HubSpot?',
          description:
              'Using separate tools for Email (Mailchimp), CRM (Salesforce), and Support (Zendesk) increases complexity. '
              'HubSpot offers all these in one suite.',
          potentialSavings: 'Medium',
        ),
      );
    }

    // Rule 3: Design Tools
    if (toolNames.contains('figma') &&
        toolNames.contains('sketch') &&
        toolNames.contains('invision')) {
      suggestions.add(
        const ConsolidationSuggestion(
          title: 'Standardize Design Tools',
          description:
              'You have Figma, Sketch, and InVision. Consolidating to just Figma could save licensing costs and improve collaboration.',
          potentialSavings: 'Medium',
        ),
      );
    }

    // Rule 4: Project Management Overlap
    var pmTools = 0;
    if (toolNames.contains('jira')) pmTools++;
    if (toolNames.contains('asana')) pmTools++;
    if (toolNames.contains('trello')) pmTools++;
    if (toolNames.contains('monday.com')) pmTools++;
    if (toolNames.contains('clickup')) pmTools++;
    if (toolNames.contains('notion')) pmTools++;

    if (pmTools >= 3) {
      suggestions.add(
        const ConsolidationSuggestion(
          title: 'Too Many Project Management Tools',
          description:
              'You have 3+ project management tools. Standardizing on one (e.g., Jira or ClickUp) significantly reduces context switching and cost.',
          potentialSavings: 'High',
        ),
      );
    }

    return suggestions;
  }
}

class ConsolidationSuggestion {
  final String title;
  final String description;
  final String potentialSavings; // Low, Medium, High

  const ConsolidationSuggestion({
    required this.title,
    required this.description,
    required this.potentialSavings,
  });
}
