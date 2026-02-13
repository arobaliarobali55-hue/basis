/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Basis';
  static const String appTagline = 'SaaS Cost Intelligence';

  // Supabase Configuration
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'https://vzaodhatyziwqqjujyxf.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6YW9kaGF0eXppd3FxanVqeXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5NjA2MzgsImV4cCI6MjA4MzUzNjYzOH0.hdIT1SoeGMJs1XhIKreM0EDfCGR6nxx0dvWnsHX4PVg';

  // Database Tables
  static const String toolsTable = 'tools';
  static const String usersTable = 'users';
  static const String userSettingsTable = 'user_settings';

  // Categories
  static const List<String> toolCategories = [
    'Communication',
    'Project Management',
    'Development',
    'Design',
    'Marketing',
    'Sales',
    'Analytics',
    'HR',
    'Finance',
    'Other',
  ];

  // Billing Types
  static const String billingMonthly = 'monthly';
  static const String billingYearly = 'yearly';

  // Waste Detection Thresholds
  static const double highGrowthThreshold = 20.0; // 20%
  static const int zeroSeatsThreshold = 0;

  // Calculation Constants
  static const int projectionYears = 3;
  static const int monthsPerYear = 12;

  // Settings Constants
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'INR',
    'BDT',
  ];

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'INR': '₹',
    'BDT': '৳',
  };

  static const List<String> supportedThemes = ['dark', 'light'];
  static const String defaultCurrency = 'USD';
  static const String defaultTheme = 'dark';
  static const String defaultDateFormat = 'MM/dd/yyyy';
}
