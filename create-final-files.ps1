# Part 6: Create utilities and Supabase configuration
Set-Location "C:\Flowstate\app"

# ============================================
# 5. LIB (Supabase Client)
# ============================================

# lib/supabase.ts
@"
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export const createClient = () => createClientComponentClient()

export const createServerClient = () => createServerComponentClient({ cookies })
"@ | Out-File -FilePath "lib/supabase.ts" -Encoding utf8

# ============================================
# 6. UTILS
# ============================================

# utils/cn.ts
@"
import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
"@ | Out-File -FilePath "utils/cn.ts" -Encoding utf8

# ============================================
# 7. DATABASE SCHEMA DOCUMENTATION
# ============================================

# SUPABASE_SETUP.md
@"
# Supabase Database Setup for FlowState

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Save your project URL and anon key

## Step 2: Run SQL Schema

Go to your Supabase project → SQL Editor → New Query

Paste and run this SQL:

\`\`\`sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tasks table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  time_spent INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS \$\$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
\$\$ language 'plpgsql';

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own tasks" 
  ON tasks FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tasks" 
  ON tasks FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tasks" 
  ON tasks FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tasks" 
  ON tasks FOR DELETE 
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX idx_tasks_parent_id ON tasks(parent_id);
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);

-- Enable Realtime for live updates
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
\`\`\`

## Step 3: Configure Environment Variables

1. Copy \`.env.local.example\` to \`.env.local\`
2. Add your Supabase credentials:

\`\`\`env
NEXT_PUBLIC_SUPABASE_URL=your_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
\`\`\`

## Step 4: Enable Email Authentication

1. Go to Authentication → Providers
2. Enable Email provider
3. Configure email templates (optional)

## Step 5: Test Connection

Run your app and try to sign up with an email address.

## Optional: Add Sample Data

\`\`\`sql
-- After signing up, you can add sample tasks
-- Replace 'your-user-id' with your actual user ID from auth.users

INSERT INTO tasks (user_id, title, completed, parent_id) VALUES
  ('your-user-id', 'Launch FlowState MVP', false, null),
  ('your-user-id', 'Setup Backend', true, (SELECT id FROM tasks WHERE title = 'Launch FlowState MVP')),
  ('your-user-id', 'Build Frontend', false, (SELECT id FROM tasks WHERE title = 'Launch FlowState MVP'));
\`\`\`

## Troubleshooting

**Issue**: Tasks not showing up
- Check RLS policies are enabled
- Verify user is authenticated
- Check browser console for errors

**Issue**: Real-time not working
- Ensure Realtime is enabled for tasks table
- Check Supabase project limits
- Verify WebSocket connection in browser DevTools

**Issue**: Authentication failing
- Verify environment variables are set
- Check email provider is enabled
- Look for CORS issues in console
"@ | Out-File -FilePath "SUPABASE_SETUP.md" -Encoding utf8

# ============================================
# 8. PUBLIC ASSETS
# ============================================

# public/.gitkeep
@"
# Public assets directory
"@ | Out-File -FilePath "public/.gitkeep" -Encoding utf8

Write-Host ""
Write-Host "✅ ✅ ✅ ALL FILES CREATED SUCCESSFULLY! ✅ ✅ ✅" -ForegroundColor Green
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  FlowState Project Setup Complete!" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Project Location: " -NoNewline -ForegroundColor White
Write-Host "C:\Flowstate\app" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Install dependencies:" -ForegroundColor White
Write-Host "   cd C:\Flowstate\app" -ForegroundColor Cyan
Write-Host "   npm install" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Set up Supabase:" -ForegroundColor White
Write-Host "   - Create account at https://supabase.com" -ForegroundColor Cyan
Write-Host "   - Create new project" -ForegroundColor Cyan
Write-Host "   - Run SQL from SUPABASE_SETUP.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Configure environment:" -ForegroundColor White
Write-Host "   cp .env.local.example .env.local" -ForegroundColor Cyan
Write-Host "   # Add your Supabase URL and anon key" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Run development server:" -ForegroundColor White
Write-Host "   npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Open in browser:" -ForegroundColor White
Write-Host "   http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Yellow
Write-Host "   - README.md - General project info" -ForegroundColor White
Write-Host "   - SUPABASE_SETUP.md - Database setup guide" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Features Included:" -ForegroundColor Yellow
Write-Host "   ✓ Nested tasks (infinite depth)" -ForegroundColor Green
Write-Host "   ✓ 25-minute Pomodoro timer" -ForegroundColor Green
Write-Host "   ✓ Focus mode" -ForegroundColor Green
Write-Host "   ✓ Command palette (Cmd+K)" -ForegroundColor Green
Write-Host "   ✓ Real-time sync" -ForegroundColor Green
Write-Host "   ✓ Magic link authentication" -ForegroundColor Green
Write-Host "   ✓ Fully responsive" -ForegroundColor Green
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Magenta
Write-Host ""
