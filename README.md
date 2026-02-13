# Basis - SaaS Cost Intelligence & Optimization Platform

A production-ready Flutter Web + Mobile application for tracking SaaS subscriptions, analyzing cost growth, detecting waste, and calculating long-term financial impact.

## Features

✅ **Authentication**
- Email/password login and signup
- Company name registration
- Supabase Auth integration

✅ **SaaS Tool Management**
- Add tools with detailed pricing information
- Track monthly price, seats, billing type
- Set expected yearly growth rates

✅ **Financial Intelligence**
- Real-time cost calculations
- 3-year cost projections with compound growth
- Monthly breakdown visualization (36 months)
- Interactive charts using fl_chart

✅ **Waste Detection**
- Zero seats warnings
- High growth rate alerts (>20%)
- Duplicate category detection

✅ **Rent vs Own Calculator**
- Compare competitor pricing vs your pricing
- Break-even month calculation
- 3-year savings projection
- Visual cost comparison

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: Riverpod
- **Backend**: Supabase (Auth + Database)
- **Charts**: fl_chart
- **Architecture**: Clean Architecture
- **Design**: Premium dark theme with Google Fonts (Inter)

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   └── tool_model.dart
│   └── repositories/
│       └── supabase_repository.dart
├── domain/
│   ├── entities/
│   │   └── tool_entity.dart
│   └── usecases/
│       └── finance_engine.dart
└── presentation/
    ├── providers/
    │   └── app_providers.dart
    ├── screens/
    │   ├── auth/
    │   │   └── auth_screen.dart
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── tools/
    │   │   └── add_tool_screen.dart
    │   └── calculator/
    │       └── calculator_screen.dart
    └── widgets/
        └── metric_card.dart
```

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (latest stable)
- Supabase account

### 2. Supabase Setup

#### Create a new Supabase project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Copy your project URL and anon key

#### Create the database schema

Run this SQL in your Supabase SQL Editor:

```sql
-- Create tools table
CREATE TABLE tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tool_name TEXT NOT NULL,
  category TEXT NOT NULL,
  monthly_price NUMERIC(10, 2) NOT NULL,
  seats INTEGER NOT NULL,
  billing_type TEXT NOT NULL CHECK (billing_type IN ('monthly', 'yearly')),
  growth_rate NUMERIC(5, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE tools ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own tools"
  ON tools FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tools"
  ON tools FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tools"
  ON tools FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tools"
  ON tools FOR DELETE
  USING (auth.uid() = user_id);

-- Create index for performance
CREATE INDEX idx_tools_user_id ON tools(user_id);
CREATE INDEX idx_tools_created_at ON tools(created_at DESC);
```

### 3. Configure the App

1. Open `lib/core/constants/app_constants.dart`
2. Replace the placeholder values:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

**For Web:**
```bash
flutter run -d chrome
```

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

## Financial Calculation Logic

### 3-Year Projection Formula

For each tool, the yearly cost is calculated with compound growth:

```
Year 1: price × 12
Year 2: (price × (1 + growth_rate/100)) × 12
Year 3: (price × (1 + growth_rate/100)²) × 12
```

Total 3-year cost = Sum of all years across all tools

### Rent vs Own Calculation

Compares two pricing models over 36 months:

**Competitor Cost:**
- One-time activation fee
- Monthly price with yearly increases (compound)

**Your Cost:**
- One-time activation fee
- Flat monthly fee (no increases)

**Break-even:** First month where your total cost becomes lower than competitor

## Design Philosophy

- **Premium**: High-quality, polished UI with attention to detail
- **Minimal**: Clean, uncluttered interface focused on data
- **Financial Sophistication**: Professional B2B dashboard aesthetic
- **Dark Theme**: Easy on the eyes for extended use
- **Typography**: Inter font for modern, professional look

## Architecture Decisions

### Clean Architecture

- **Domain Layer**: Pure business logic (entities, use cases)
- **Data Layer**: External data sources (Supabase, models)
- **Presentation Layer**: UI and state management (Riverpod)

### Why Riverpod?

- Type-safe state management
- Compile-time safety
- Easy testing
- Reactive updates

### Why Supabase?

- Real-time database
- Built-in authentication
- Row-level security
- PostgreSQL power

## Future Enhancements (Not in MVP)

- Team collaboration
- Export reports (PDF, CSV)
- Budget alerts
- Integration with accounting software
- Mobile push notifications
- Advanced analytics with AI insights

## License

Private - All rights reserved

## Support

For issues or questions, please contact the development team.
