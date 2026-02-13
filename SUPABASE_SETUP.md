# Supabase Database Setup

## SQL Schema

Copy and paste this entire SQL script into your Supabase SQL Editor:

```sql
-- =====================================================
-- Basis SaaS Cost Intelligence Platform
-- Database Schema
-- =====================================================

-- Create tools table
CREATE TABLE IF NOT EXISTS tools (
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

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own tools" ON tools;
DROP POLICY IF EXISTS "Users can insert their own tools" ON tools;
DROP POLICY IF EXISTS "Users can update their own tools" ON tools;
DROP POLICY IF EXISTS "Users can delete their own tools" ON tools;

-- Create RLS policies
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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_tools_user_id ON tools(user_id);
CREATE INDEX IF NOT EXISTS idx_tools_created_at ON tools(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tools_category ON tools(category);

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check if table was created successfully
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tools'
ORDER BY ordinal_position;

-- Check if RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'tools';

-- Check policies
SELECT policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'tools';
```

## Setup Steps

1. **Go to your Supabase project**
   - Navigate to: SQL Editor

2. **Create a new query**
   - Click "New Query"

3. **Paste the SQL above**
   - Copy the entire SQL script
   - Paste into the editor

4. **Run the script**
   - Click "Run" or press Ctrl+Enter

5. **Verify the setup**
   - Check the results of the verification queries at the bottom
   - You should see:
     - 9 columns in the tools table
     - RLS enabled (rowsecurity = true)
     - 4 policies created

## Table Structure

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key (auto-generated) |
| user_id | UUID | Foreign key to auth.users |
| tool_name | TEXT | Name of the SaaS tool |
| category | TEXT | Tool category |
| monthly_price | NUMERIC(10,2) | Monthly subscription price |
| seats | INTEGER | Number of seats/licenses |
| billing_type | TEXT | 'monthly' or 'yearly' |
| growth_rate | NUMERIC(5,2) | Expected yearly price increase % |
| created_at | TIMESTAMPTZ | Timestamp of creation |

## Security

Row Level Security (RLS) is enabled with the following policies:

- **SELECT**: Users can only view their own tools
- **INSERT**: Users can only create tools for themselves
- **UPDATE**: Users can only update their own tools
- **DELETE**: Users can only delete their own tools

## Next Steps

After running this SQL:

1. Copy your Supabase project URL
2. Copy your Supabase anon key (from Settings > API)
3. Update `lib/core/constants/app_constants.dart` with these values
4. Run `flutter pub get`
5. Run the app!
