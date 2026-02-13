# Supabase Settings Migration

## SQL Schema for User Settings

Copy and paste this SQL script into your Supabase SQL Editor:

```sql
-- =====================================================
-- Basis SaaS Cost Intelligence Platform
-- User Settings Table Migration
-- =====================================================

-- Create user_settings table
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  theme TEXT NOT NULL DEFAULT 'dark' CHECK (theme IN ('dark', 'light')),
  currency TEXT NOT NULL DEFAULT 'USD',
  date_format TEXT NOT NULL DEFAULT 'MM/dd/yyyy',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can insert their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can update their own settings" ON user_settings;
DROP POLICY IF EXISTS "Users can delete their own settings" ON user_settings;

-- Create RLS policies
CREATE POLICY "Users can view their own settings"
  ON user_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own settings"
  ON user_settings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own settings"
  ON user_settings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own settings"
  ON user_settings FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_user_settings_updated_at ON user_settings;
CREATE TRIGGER update_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check if table was created successfully
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_settings'
ORDER BY ordinal_position;

-- Check if RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'user_settings';

-- Check policies
SELECT policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'user_settings';
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
   - Check the results of the verification queries
   - You should see:
     - 7 columns in the user_settings table
     - RLS enabled (rowsecurity = true)
     - 4 policies created

## Table Structure

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key (auto-generated) |
| user_id | UUID | Foreign key to auth.users (unique) |
| theme | TEXT | 'dark' or 'light' |
| currency | TEXT | Currency code (USD, EUR, GBP, etc.) |
| date_format | TEXT | Date format preference |
| created_at | TIMESTAMPTZ | Timestamp of creation |
| updated_at | TIMESTAMPTZ | Timestamp of last update |

## Default Values

When a user signs up, their settings will use these defaults:
- **Theme**: dark
- **Currency**: USD
- **Date Format**: MM/dd/yyyy

## Security

Row Level Security (RLS) ensures users can only access their own settings.
