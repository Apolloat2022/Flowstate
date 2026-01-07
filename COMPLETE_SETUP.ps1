# FlowState Project Setup Script
# Run this in PowerShell to create the complete project structure

# Create main project directory
New-Item -ItemType Directory -Force -Path "C:\Flowstate\app"
Set-Location "C:\Flowstate\app"

# Create folder structure
$folders = @(
    "app",
    "app\api",
    "app\api\auth",
    "components",
    "components\ui",
    "lib",
    "public",
    "store",
    "types",
    "utils"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder
}

# Create package.json
@"
{
  "name": "flowstate",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^15.0.3",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@supabase/supabase-js": "^2.39.3",
    "@supabase/auth-helpers-nextjs": "^0.10.0",
    "zustand": "^4.5.0",
    "framer-motion": "^11.0.3",
    "lucide-react": "^0.344.0",
    "date-fns": "^3.3.1",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.1"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/node": "^20.11.5",
    "@types/react": "^18.2.48",
    "@types/react-dom": "^18.2.18",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.33",
    "tailwindcss": "^3.4.1",
    "eslint": "^8.56.0",
    "eslint-config-next": "^15.0.3"
  }
}
"@ | Out-File -FilePath "package.json" -Encoding utf8

# Create tsconfig.json
@"
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
"@ | Out-File -FilePath "tsconfig.json" -Encoding utf8

# Create next.config.js
@"
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverActions: {
      bodySizeLimit: '2mb',
    },
  },
}

module.exports = nextConfig
"@ | Out-File -FilePath "next.config.js" -Encoding utf8

# Create tailwind.config.js
@"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Outfit', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      animation: {
        'slide-down': 'slideDown 0.5s cubic-bezier(0.16, 1, 0.3, 1)',
        'slide-right': 'slideRight 0.5s cubic-bezier(0.16, 1, 0.3, 1)',
        'fade-in': 'fadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1)',
        'task-fade-in': 'taskFadeIn 0.3s cubic-bezier(0.16, 1, 0.3, 1)',
      },
      keyframes: {
        slideDown: {
          '0%': { opacity: '0', transform: 'translateY(-20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideRight: {
          '0%': { opacity: '0', transform: 'translateX(-20px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        taskFadeIn: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
}
"@ | Out-File -FilePath "tailwind.config.js" -Encoding utf8

# Create postcss.config.js
@"
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@ | Out-File -FilePath "postcss.config.js" -Encoding utf8

# Create .env.local.example
@"
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Example:
# NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
# NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
"@ | Out-File -FilePath ".env.local.example" -Encoding utf8

# Create .gitignore
@"
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env*.local
.env

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts
"@ | Out-File -FilePath ".gitignore" -Encoding utf8

# Create README.md
@"
# FlowState - Deep Work Task Manager

A high-performance task management app built with Next.js 15, Supabase, and Tailwind CSS. Designed for deep work and focused productivity.

## Features

- ✅ Recursive nested tasks (infinite depth)
- ⏱️ 25-minute Pomodoro timer with persistent state
- 🎯 Focus Mode - immersive full-screen experience
- ⌨️ Command Palette (Cmd+K) for quick actions
- 🔄 Real-time sync with Supabase
- 📱 Fully responsive design
- ⚡ Optimistic UI updates
- 🎨 Beautiful gradient-based design system

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Supabase account

### Installation

1. Install dependencies:
``````bash
npm install
``````

2. Set up environment variables:
``````bash
cp .env.local.example .env.local
``````

3. Add your Supabase credentials to \``.env.local\`\`

4. Set up Supabase database (see Database Schema section)

5. Run the development server:
``````bash
npm run dev
``````

6. Open [http://localhost:3000](http://localhost:3000)

## Database Schema

Run this SQL in your Supabase SQL Editor:

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

-- Create index for parent_id lookups
CREATE INDEX idx_tasks_parent_id ON tasks(parent_id);
CREATE INDEX idx_tasks_user_id ON tasks(user_id);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
\`\`\`

## Keyboard Shortcuts

- \`\`Cmd/Ctrl + K\`\` - Open command palette
- \`\`Space\`\` - Start/pause timer (when task selected)
- \`\`Esc\`\` - Close command palette or exit focus mode
- \`\`Enter\`\` - Save task edit
- \`\`Esc\`\` - Cancel task edit

## Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Database**: Supabase (PostgreSQL)
- **State Management**: Zustand
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion
- **Icons**: Lucide React
- **Authentication**: Supabase Auth

## Deployment

### Vercel (Recommended)

1. Push to GitHub
2. Import project in Vercel
3. Add environment variables
4. Deploy

### Environment Variables for Production

Add these in Vercel dashboard:
- \`\`NEXT_PUBLIC_SUPABASE_URL\`\`
- \`\`NEXT_PUBLIC_SUPABASE_ANON_KEY\`\`

## License

MIT
"@ | Out-File -FilePath "README.md" -Encoding utf8

Write-Host "✅ Project structure created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Project location: C:\Flowstate\app" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd C:\Flowstate\app" -ForegroundColor White
Write-Host "2. npm install" -ForegroundColor White
Write-Host "3. Copy .env.local.example to .env.local and add your Supabase credentials" -ForegroundColor White
Write-Host "4. npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "⚡ Additional files will be created in the next steps..." -ForegroundColor Magenta
# Part 2: Create all application files
# Run this AFTER setup-flowstate.ps1

Set-Location "C:\Flowstate\app"

# ============================================
# 1. APP DIRECTORY FILES
# ============================================

# app/layout.tsx
@"
import type { Metadata } from 'next'
import { Outfit, JetBrains_Mono } from 'next/font/google'
import './globals.css'

const outfit = Outfit({ 
  subsets: ['latin'],
  variable: '--font-outfit',
})

const jetbrainsMono = JetBrains_Mono({ 
  subsets: ['latin'],
  variable: '--font-jetbrains',
})

export const metadata: Metadata = {
  title: 'FlowState - Deep Work Task Manager',
  description: 'Manage tasks and focus with Pomodoro timers',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={`$\{outfit.variable} $\{jetbrainsMono.variable} font-sans`}>
        {children}
      </body>
    </html>
  )
}
"@ | Out-File -FilePath "app/layout.tsx" -Encoding utf8

# app/page.tsx
@"
'use client'

import { useEffect, useState } from 'react'
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { useRouter } from 'next/navigation'
import TaskList from '@/components/TaskList'
import Timer from '@/components/Timer'
import CommandPalette from '@/components/CommandPalette'
import FocusMode from '@/components/FocusMode'
import Header from '@/components/Header'
import { useTimerStore } from '@/store/timerStore'
import { User, Zap } from 'lucide-react'

export default function Home() {
  const supabase = createClientComponentClient()
  const router = useRouter()
  const [user, setUser] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const focusMode = useTimerStore((state) => state.focusMode)

  useEffect(() => {
    const checkUser = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      if (session?.user) {
        setUser(session.user)
      } else {
        router.push('/auth')
      }
      setLoading(false)
    }

    checkUser()

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        setUser(session.user)
      } else {
        router.push('/auth')
      }
    })

    return () => subscription.unsubscribe()
  }, [supabase, router])

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
        <div className="text-center">
          <Zap className="w-16 h-16 mx-auto mb-4 text-purple-600 animate-pulse" />
          <p className="text-lg text-gray-600">Loading FlowState...</p>
        </div>
      </div>
    )
  }

  if (!user) return null

  return (
    <>
      {focusMode && <FocusMode />}
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
        <Header user={user} />
        <div className="grid grid-cols-1 lg:grid-cols-[400px_1fr] h-[calc(100vh-81px)]">
          <TaskList userId={user.id} />
          <Timer />
        </div>
        <CommandPalette />
      </div>
    </>
  )
}
"@ | Out-File -FilePath "app/page.tsx" -Encoding utf8

# app/auth/page.tsx
@"
'use client'

import { useState } from 'react'
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { useRouter } from 'next/navigation'
import { Zap, Mail, ArrowRight } from 'lucide-react'

export default function AuthPage() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const supabase = createClientComponentClient()
  const router = useRouter()

  const handleMagicLink = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setMessage('')

    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: `$\{window.location.origin}/auth/callback`,
      },
    })

    if (error) {
      setMessage(error.message)
    } else {
      setMessage('Check your email for the magic link!')
    }
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-blue-50 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="inline-flex items-center gap-3 mb-4">
            <Zap className="w-12 h-12 text-purple-600" />
            <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-600 to-purple-900 bg-clip-text text-transparent">
              FlowState
            </h1>
          </div>
          <p className="text-gray-600">Enter flow. Accomplish more.</p>
        </div>

        <div className="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
          <h2 className="text-2xl font-bold mb-6 text-gray-900">Sign in with Magic Link</h2>
          
          <form onSubmit={handleMagicLink} className="space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Email address
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                <input
                  id="email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="you@example.com"
                  required
                  className="w-full pl-11 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none transition"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-gradient-to-r from-purple-600 to-purple-800 text-white py-3 rounded-xl font-semibold hover:shadow-lg hover:scale-[1.02] transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {loading ? 'Sending...' : 'Send Magic Link'}
              {!loading && <ArrowRight className="w-5 h-5" />}
            </button>
          </form>

          {message && (
            <div className={`mt-4 p-4 rounded-lg $\{message.includes('Check') ? 'bg-green-50 text-green-800' : 'bg-red-50 text-red-800'}`}>
              {message}
            </div>
          )}
        </div>

        <p className="text-center mt-6 text-sm text-gray-600">
          No password needed. We'll send you a secure link.
        </p>
      </div>
    </div>
  )
}
"@ | Out-File -FilePath "app/auth/page.tsx" -Encoding utf8

# app/auth/callback/route.ts
@"
import { createRouteHandlerClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')

  if (code) {
    const supabase = createRouteHandlerClient({ cookies })
    await supabase.auth.exchangeCodeForSession(code)
  }

  return NextResponse.redirect(new URL('/', requestUrl.origin))
}
"@ | Out-File -FilePath "app/auth/callback/route.ts" -Encoding utf8

# app/globals.css
@"
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --font-outfit: 'Outfit', system-ui, sans-serif;
  --font-jetbrains: 'JetBrains Mono', monospace;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-outfit);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: #a1a1a1;
}

/* Smooth transitions */
@layer utilities {
  .transition-smooth {
    transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  }
}
"@ | Out-File -FilePath "app/globals.css" -Encoding utf8

Write-Host "✅ App directory files created!" -ForegroundColor Green
Write-Host "Creating component files..." -ForegroundColor Cyan
# Part 3: Create component files
Set-Location "C:\Flowstate\app"

# ============================================
# 2. COMPONENTS
# ============================================

# components/Header.tsx
@"
'use client'

import { User, Command, Zap, LogOut } from 'lucide-react'
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { useRouter } from 'next/navigation'
import { useCommandPaletteStore } from '@/store/commandPaletteStore'

interface HeaderProps {
  user: any
}

export default function Header({ user }: HeaderProps) {
  const supabase = createClientComponentClient()
  const router = useRouter()
  const setShowPalette = useCommandPaletteStore((state) => state.setShow)

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    router.push('/auth')
  }

  return (
    <header className="bg-white border-b border-gray-200 px-8 py-5 animate-slide-down">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-6">
          <div className="flex items-center gap-3">
            <Zap className="w-6 h-6 text-purple-600" />
            <h1 className="text-2xl font-extrabold bg-gradient-to-r from-purple-600 to-purple-900 bg-clip-text text-transparent">
              FlowState
            </h1>
          </div>
          <button
            onClick={() => setShowPalette(true)}
            className="flex items-center gap-2 px-4 py-2 bg-gray-50 border border-gray-200 rounded-lg hover:bg-gray-100 transition text-sm font-medium text-gray-700"
          >
            <Command className="w-4 h-4" />
            Quick Actions
          </button>
        </div>

        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg text-sm font-medium text-gray-700">
            <User className="w-4 h-4" />
            {user.email}
          </div>
          <button
            onClick={handleSignOut}
            className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition"
            title="Sign out"
          >
            <LogOut className="w-5 h-5" />
          </button>
        </div>
      </div>
    </header>
  )
}
"@ | Out-File -FilePath "components/Header.tsx" -Encoding utf8

# components/TaskList.tsx
@"
'use client'

import { useEffect, useState } from 'react'
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'
import { Plus, Zap } from 'lucide-react'
import TaskItem from './TaskItem'
import { Task } from '@/types'
import { useSelectedTaskStore } from '@/store/selectedTaskStore'

interface TaskListProps {
  userId: string
}

export default function TaskList({ userId }: TaskListProps) {
  const supabase = createClientComponentClient()
  const [tasks, setTasks] = useState<Task[]>([])
  const [expandedTasks, setExpandedTasks] = useState<Set<string>>(new Set())
  const selectedTaskId = useSelectedTaskStore((state) => state.selectedTaskId)

  useEffect(() => {
    fetchTasks()

    // Subscribe to real-time updates
    const channel = supabase
      .channel('tasks-changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'tasks' }, (payload) => {
        fetchTasks()
      })
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [userId])

  const fetchTasks = async () => {
    const { data, error } = await supabase
      .from('tasks')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: true })

    if (!error && data) {
      setTasks(data)
    }
  }

  const addTask = async (title: string, parentId: string | null = null) => {
    const newTask = {
      title,
      user_id: userId,
      parent_id: parentId,
      completed: false,
      time_spent: 0,
    }

    // Optimistic update
    const tempId = `temp-$\{Date.now()}`
    setTasks((prev) => [...prev, { ...newTask, id: tempId, created_at: new Date().toISOString(), updated_at: new Date().toISOString() }])

    const { data, error } = await supabase.from('tasks').insert(newTask).select().single()

    if (error) {
      console.error('Error creating task:', error)
      setTasks((prev) => prev.filter((t) => t.id !== tempId))
    } else if (data) {
      setTasks((prev) => prev.map((t) => (t.id === tempId ? data : t)))
      if (parentId) {
        setExpandedTasks((prev) => new Set([...prev, parentId]))
      }
    }
  }

  const toggleTask = async (taskId: string) => {
    const task = tasks.find((t) => t.id === taskId)
    if (!task) return

    // Optimistic update
    setTasks((prev) => prev.map((t) => (t.id === taskId ? { ...t, completed: !t.completed } : t)))

    const { error } = await supabase
      .from('tasks')
      .update({ completed: !task.completed })
      .eq('id', taskId)

    if (error) {
      console.error('Error updating task:', error)
      setTasks((prev) => prev.map((t) => (t.id === taskId ? task : t)))
    }
  }

  const updateTaskTitle = async (taskId: string, newTitle: string) => {
    const task = tasks.find((t) => t.id === taskId)
    if (!task) return

    // Optimistic update
    setTasks((prev) => prev.map((t) => (t.id === taskId ? { ...t, title: newTitle } : t)))

    const { error } = await supabase.from('tasks').update({ title: newTitle }).eq('id', taskId)

    if (error) {
      console.error('Error updating task:', error)
      setTasks((prev) => prev.map((t) => (t.id === taskId ? task : t)))
    }
  }

  const deleteTask = async (taskId: string) => {
    // Get all child task IDs recursively
    const getAllChildren = (id: string): string[] => {
      const children = tasks.filter((t) => t.parent_id === id)
      return [id, ...children.flatMap((child) => getAllChildren(child.id))]
    }

    const idsToDelete = getAllChildren(taskId)

    // Optimistic update
    setTasks((prev) => prev.filter((t) => !idsToDelete.includes(t.id)))

    const { error } = await supabase.from('tasks').delete().eq('id', taskId)

    if (error) {
      console.error('Error deleting task:', error)
      fetchTasks()
    }
  }

  const toggleExpanded = (taskId: string) => {
    setExpandedTasks((prev) => {
      const next = new Set(prev)
      if (next.has(taskId)) {
        next.delete(taskId)
      } else {
        next.add(taskId)
      }
      return next
    })
  }

  // Build task tree
  const buildTaskTree = () => {
    const taskMap = new Map<string, Task & { children: Task[] }>()
    tasks.forEach((task) => {
      taskMap.set(task.id, { ...task, children: [] })
    })

    const roots: (Task & { children: Task[] })[] = []
    taskMap.forEach((task) => {
      if (task.parent_id && taskMap.has(task.parent_id)) {
        taskMap.get(task.parent_id)!.children.push(task)
      } else if (!task.parent_id) {
        roots.push(task)
      }
    })

    return roots
  }

  const taskTree = buildTaskTree()

  return (
    <aside className="bg-white border-r border-gray-200 overflow-y-auto animate-slide-right">
      <div className="p-6">
        <button
          onClick={() => addTask('New task')}
          className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-gradient-to-r from-purple-600 to-purple-800 text-white rounded-xl font-semibold hover:shadow-lg hover:scale-[1.02] transition-all"
        >
          <Plus className="w-5 h-5" />
          New Task
        </button>

        <div className="mt-6 space-y-1">
          {taskTree.map((task) => (
            <TaskItem
              key={task.id}
              task={task}
              depth={0}
              expandedTasks={expandedTasks}
              onToggle={toggleTask}
              onToggleExpanded={toggleExpanded}
              onAddSubtask={(id) => addTask('New subtask', id)}
              onUpdateTitle={updateTaskTitle}
              onDelete={deleteTask}
            />
          ))}
        </div>

        {tasks.length === 0 && (
          <div className="text-center py-12">
            <Zap className="w-12 h-12 mx-auto mb-4 text-gray-300" />
            <p className="text-gray-600 font-medium">No tasks yet</p>
            <p className="text-gray-400 text-sm mt-2">Create your first task to get started</p>
          </div>
        )}
      </div>
    </aside>
  )
}
"@ | Out-File -FilePath "components/TaskList.tsx" -Encoding utf8

Write-Host "✅ Header and TaskList components created!" -ForegroundColor Green
Write-Host "Creating more components..." -ForegroundColor Cyan
# Part 4: Create remaining components
Set-Location "C:\Flowstate\app"

# components/TaskItem.tsx
@"
'use client'

import { useState } from 'react'
import { Check, ChevronRight, ChevronDown, Plus, Clock, Pencil, Trash2 } from 'lucide-react'
import { Task } from '@/types'
import { useSelectedTaskStore } from '@/store/selectedTaskStore'
import { useTimerStore } from '@/store/timerStore'

interface TaskItemProps {
  task: Task & { children: Task[] }
  depth: number
  expandedTasks: Set<string>
  onToggle: (id: string) => void
  onToggleExpanded: (id: string) => void
  onAddSubtask: (parentId: string) => void
  onUpdateTitle: (id: string, title: string) => void
  onDelete: (id: string) => void
}

export default function TaskItem({
  task,
  depth,
  expandedTasks,
  onToggle,
  onToggleExpanded,
  onAddSubtask,
  onUpdateTitle,
  onDelete,
}: TaskItemProps) {
  const [editing, setEditing] = useState(false)
  const [editText, setEditText] = useState(task.title)
  const selectedTaskId = useSelectedTaskStore((state) => state.selectedTaskId)
  const setSelectedTaskId = useSelectedTaskStore((state) => state.setSelectedTaskId)
  const currentTaskId = useTimerStore((state) => state.currentTaskId)
  const isRunning = useTimerStore((state) => state.isRunning)
  const timeLeft = useTimerStore((state) => state.timeLeft)

  const hasChildren = task.children && task.children.length > 0
  const isExpanded = expandedTasks.has(task.id)
  const isSelected = selectedTaskId === task.id
  const isCurrentTimer = currentTaskId === task.id

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `$\{mins.toString().padStart(2, '0')}:$\{secs.toString().padStart(2, '0')}`
  }

  const handleSaveEdit = () => {
    if (editText.trim()) {
      onUpdateTitle(task.id, editText.trim())
    }
    setEditing(false)
  }

  return (
    <div style={{ marginLeft: `$\{depth * 24}px` }}>
      <div
        className={`
          group flex items-center justify-between px-3 py-2.5 rounded-lg cursor-pointer
          transition-all animate-task-fade-in hover:bg-gray-50
          $\{isSelected ? 'bg-gradient-to-r from-purple-50 to-purple-100 border-l-2 border-purple-600' : ''}
          $\{isCurrentTimer ? 'bg-purple-50/50' : ''}
        `}
        onClick={() => setSelectedTaskId(task.id)}
      >
        <div className="flex items-center gap-2 flex-1 min-w-0">
          {hasChildren && (
            <button
              onClick={(e) => {
                e.stopPropagation()
                onToggleExpanded(task.id)
              }}
              className="text-gray-400 hover:text-gray-600 transition p-0.5"
            >
              {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
            </button>
          )}

          <button
            onClick={(e) => {
              e.stopPropagation()
              onToggle(task.id)
            }}
            className={`
              w-5 h-5 rounded-md border-2 flex items-center justify-center flex-shrink-0
              transition-all
              $\{task.completed 
                ? 'bg-gradient-to-br from-purple-600 to-purple-800 border-purple-600' 
                : 'border-gray-300 hover:border-purple-600 bg-white'
              }
            `}
          >
            {task.completed && <Check className="w-3.5 h-3.5 text-white" />}
          </button>

          {editing ? (
            <input
              type="text"
              value={editText}
              onChange={(e) => setEditText(e.target.value)}
              onBlur={handleSaveEdit}
              onKeyDown={(e) => {
                if (e.key === 'Enter') handleSaveEdit()
                if (e.key === 'Escape') {
                  setEditing(false)
                  setEditText(task.title)
                }
              }}
              onClick={(e) => e.stopPropagation()}
              className="flex-1 px-2 py-1 border border-purple-600 rounded text-sm font-medium outline-none"
              autoFocus
            />
          ) : (
            <span
              className={`
                text-sm font-medium truncate
                $\{task.completed ? 'line-through text-gray-400' : 'text-gray-700'}
              `}
            >
              {task.title}
            </span>
          )}
        </div>

        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
          {isCurrentTimer && isRunning && (
            <div className="flex items-center gap-1 px-2 py-1 bg-gradient-to-r from-purple-600 to-purple-800 text-white rounded-md text-xs font-semibold font-mono">
              <Clock className="w-3 h-3" />
              {formatTime(timeLeft)}
            </div>
          )}
          <button
            onClick={(e) => {
              e.stopPropagation()
              setEditing(true)
            }}
            className="p-1.5 hover:bg-gray-200 rounded text-gray-600"
            title="Edit"
          >
            <Pencil className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation()
              onAddSubtask(task.id)
            }}
            className="p-1.5 hover:bg-gray-200 rounded text-gray-600"
            title="Add subtask"
          >
            <Plus className="w-3.5 h-3.5" />
          </button>
          <button
            onClick={(e) => {
              e.stopPropagation()
              if (confirm('Delete this task and all subtasks?')) {
                onDelete(task.id)
              }
            }}
            className="p-1.5 hover:bg-red-100 rounded text-red-600"
            title="Delete"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {isExpanded && hasChildren && (
        <div className="mt-1">
          {task.children.map((child) => (
            <TaskItem
              key={child.id}
              task={{ ...child, children: [] }}
              depth={depth + 1}
              expandedTasks={expandedTasks}
              onToggle={onToggle}
              onToggleExpanded={onToggleExpanded}
              onAddSubtask={onAddSubtask}
              onUpdateTitle={onUpdateTitle}
              onDelete={onDelete}
            />
          ))}
        </div>
      )}
    </div>
  )
}
"@ | Out-File -FilePath "components/TaskItem.tsx" -Encoding utf8

# components/Timer.tsx
@"
'use client'

import { Clock, Play, Pause, RotateCcw } from 'lucide-react'
import { useTimerStore } from '@/store/timerStore'
import { useSelectedTaskStore } from '@/store/selectedTaskStore'
import { useEffect, useState } from 'react'
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'

export default function Timer() {
  const supabase = createClientComponentClient()
  const selectedTaskId = useSelectedTaskStore((state) => state.selectedTaskId)
  const [selectedTask, setSelectedTask] = useState<any>(null)
  const {
    isRunning,
    timeLeft,
    currentTaskId,
    toggleTimer,
    resetTimer,
    tick,
  } = useTimerStore()

  useEffect(() => {
    if (selectedTaskId) {
      supabase
        .from('tasks')
        .select('*')
        .eq('id', selectedTaskId)
        .single()
        .then(({ data }) => setSelectedTask(data))
    } else {
      setSelectedTask(null)
    }
  }, [selectedTaskId])

  useEffect(() => {
    let interval: NodeJS.Timeout
    if (isRunning && timeLeft > 0) {
      interval = setInterval(() => {
        tick()
      }, 1000)
    }
    return () => clearInterval(interval)
  }, [isRunning, timeLeft])

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `$\{mins.toString().padStart(2, '0')}:$\{secs.toString().padStart(2, '0')}`
  }

  const progress = ((25 * 60 - timeLeft) / (25 * 60)) * 100

  if (!selectedTaskId) {
    return (
      <main className="flex items-center justify-center animate-fade-in">
        <div className="text-center">
          <Clock className="w-16 h-16 mx-auto mb-4 text-gray-300" />
          <h3 className="text-2xl font-bold text-gray-700 mb-2">Select a task to begin</h3>
          <p className="text-gray-500">Choose a task from the list to start your focus session</p>
        </div>
      </main>
    )
  }

  return (
    <main className="flex flex-col items-center justify-center p-12 animate-fade-in">
      <div className="text-center mb-12">
        <h2 className="text-4xl font-extrabold mb-3 bg-gradient-to-r from-purple-600 to-purple-900 bg-clip-text text-transparent">
          Deep Work Session
        </h2>
        <p className="text-lg text-gray-600 font-medium">{selectedTask?.title || 'Loading...'}</p>
      </div>

      <div className="relative w-80 h-80 mb-12">
        <svg className="w-full h-full transform -rotate-90" viewBox="0 0 200 200">
          <circle
            cx="100"
            cy="100"
            r="85"
            fill="none"
            stroke="#f3f4f6"
            strokeWidth="8"
          />
          <circle
            cx="100"
            cy="100"
            r="85"
            fill="none"
            stroke="url(#gradient)"
            strokeWidth="8"
            strokeLinecap="round"
            strokeDasharray={`$\{534 * (progress / 100)} 534`}
            style={{ transition: 'stroke-dasharray 1s linear' }}
          />
          <defs>
            <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#9333ea" />
              <stop offset="100%" stopColor="#7c3aed" />
            </linearGradient>
          </defs>
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <span className="text-7xl font-extrabold font-mono text-gray-900">
            {formatTime(timeLeft)}
          </span>
        </div>
      </div>

      <div className="flex gap-4 mb-8">
        <button
          onClick={() => toggleTimer(selectedTaskId)}
          className="flex items-center gap-3 px-8 py-4 bg-gradient-to-r from-purple-600 to-purple-800 text-white rounded-2xl font-semibold hover:shadow-xl hover:scale-105 transition-all text-lg"
        >
          {isRunning ? (
            <>
              <Pause className="w-6 h-6" />
              Pause
            </>
          ) : (
            <>
              <Play className="w-6 h-6" />
              Start Focus
            </>
          )}
        </button>
        <button
          onClick={resetTimer}
          className="flex items-center gap-2 px-6 py-4 bg-white border-2 border-gray-200 rounded-2xl font-semibold hover:border-gray-300 hover:shadow-lg transition-all text-gray-700"
        >
          <RotateCcw className="w-5 h-5" />
          Reset
        </button>
      </div>

      <div className="flex gap-4 text-sm text-gray-500">
        <kbd className="px-3 py-1.5 bg-gray-100 border border-gray-300 rounded font-mono">Space</kbd>
        <span>to start/pause</span>
        <kbd className="px-3 py-1.5 bg-gray-100 border border-gray-300 rounded font-mono">⌘K</kbd>
        <span>for commands</span>
        <kbd className="px-3 py-1.5 bg-gray-100 border border-gray-300 rounded font-mono">ESC</kbd>
        <span>to exit focus mode</span>
      </div>
    </main>
  )
}
"@ | Out-File -FilePath "components/Timer.tsx" -Encoding utf8

Write-Host "✅ TaskItem and Timer components created!" -ForegroundColor Green
Write-Host "Creating CommandPalette and FocusMode..." -ForegroundColor Cyan
# Part 5: Create CommandPalette, FocusMode, and Stores
Set-Location "C:\Flowstate\app"

# components/CommandPalette.tsx
@"
'use client'

import { useEffect, useRef, useState } from 'react'
import { Search, Plus, Play, Clock, Zap, X } from 'lucide-react'
import { useCommandPaletteStore } from '@/store/commandPaletteStore'
import { useTimerStore } from '@/store/timerStore'
import { useSelectedTaskStore } from '@/store/selectedTaskStore'

export default function CommandPalette() {
  const show = useCommandPaletteStore((state) => state.show)
  const setShow = useCommandPaletteStore((state) => state.setShow)
  const selectedTaskId = useSelectedTaskStore((state) => state.selectedTaskId)
  const { toggleTimer, resetTimer, setFocusMode, focusMode } = useTimerStore()
  const [query, setQuery] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setShow(true)
      }
      if (e.key === 'Escape' && show) {
        setShow(false)
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [show])

  useEffect(() => {
    if (show && inputRef.current) {
      inputRef.current.focus()
    }
  }, [show])

  const commands = [
    {
      label: 'Start Timer',
      icon: Play,
      action: () => {
        if (selectedTaskId) {
          toggleTimer(selectedTaskId)
          setShow(false)
        }
      },
      disabled: !selectedTaskId,
    },
    {
      label: 'Reset Timer',
      icon: Clock,
      action: () => {
        resetTimer()
        setShow(false)
      },
    },
    {
      label: 'Toggle Focus Mode',
      icon: Zap,
      action: () => {
        setFocusMode(!focusMode)
        setShow(false)
      },
    },
  ]

  const filteredCommands = commands.filter((cmd) =>
    cmd.label.toLowerCase().includes(query.toLowerCase())
  )

  if (!show) return null

  return (
    <div
      className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-start justify-center pt-32 z-50 animate-fade-in"
      onClick={() => setShow(false)}
    >
      <div
        className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden"
        onClick={(e) => e.stopPropagation()}
        style={{
          animation: 'commandSlideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1)',
        }}
      >
        <div className="flex items-center gap-3 px-6 py-5 border-b border-gray-200">
          <Search className="w-5 h-5 text-gray-400" />
          <input
            ref={inputRef}
            type="text"
            placeholder="Type a command or search..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="flex-1 outline-none text-lg"
          />
          <button
            onClick={() => setShow(false)}
            className="p-1 hover:bg-gray-100 rounded transition"
          >
            <X className="w-5 h-5 text-gray-400" />
          </button>
        </div>

        <div className="max-h-96 overflow-y-auto p-2">
          {filteredCommands.map((cmd, idx) => (
            <button
              key={idx}
              onClick={cmd.action}
              disabled={cmd.disabled}
              className={`
                w-full flex items-center gap-3 px-4 py-3 rounded-lg text-left transition
                $\{cmd.disabled 
                  ? 'opacity-50 cursor-not-allowed' 
                  : 'hover:bg-gray-100 cursor-pointer'
                }
              `}
            >
              <cmd.icon className="w-5 h-5 text-gray-600" />
              <span className="font-medium text-gray-900">{cmd.label}</span>
            </button>
          ))}
        </div>

        <div className="px-6 py-4 bg-gray-50 border-t border-gray-200 text-sm text-gray-600 flex gap-4">
          <span>
            <kbd className="px-2 py-1 bg-white border border-gray-300 rounded text-xs font-mono">
              ⌘K
            </kbd>{' '}
            to open
          </span>
          <span>
            <kbd className="px-2 py-1 bg-white border border-gray-300 rounded text-xs font-mono">
              ESC
            </kbd>{' '}
            to close
          </span>
        </div>
      </div>

      <style jsx>{`
        @keyframes commandSlideIn {
          from {
            opacity: 0;
            transform: translateY(-20px) scale(0.95);
          }
          to {
            opacity: 1;
            transform: translateY(0) scale(1);
          }
        }
      `}</style>
    </div>
  )
}
"@ | Out-File -FilePath "components/CommandPalette.tsx" -Encoding utf8

# components/FocusMode.tsx
@"
'use client'

import { X, Play, Pause, RotateCcw } from 'lucide-react'
import { useTimerStore } from '@/store/timerStore'
import { useSelectedTaskStore } from '@/store/selectedTaskStore'
import { useEffect, useState } from 'react'
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'

export default function FocusMode() {
  const supabase = createClientComponentClient()
  const selectedTaskId = useSelectedTaskStore((state) => state.selectedTaskId)
  const [selectedTask, setSelectedTask] = useState<any>(null)
  const {
    isRunning,
    timeLeft,
    focusMode,
    setFocusMode,
    toggleTimer,
    resetTimer,
  } = useTimerStore()

  useEffect(() => {
    if (selectedTaskId) {
      supabase
        .from('tasks')
        .select('*')
        .eq('id', selectedTaskId)
        .single()
        .then(({ data }) => setSelectedTask(data))
    }
  }, [selectedTaskId])

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && focusMode) {
        setFocusMode(false)
      }
      if (e.key === ' ' && focusMode && selectedTaskId) {
        e.preventDefault()
        toggleTimer(selectedTaskId)
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [focusMode, selectedTaskId])

  if (!focusMode) return null

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `$\{mins.toString().padStart(2, '0')}:$\{secs.toString().padStart(2, '0')}`
  }

  const progress = ((25 * 60 - timeLeft) / (25 * 60)) * 100

  return (
    <div
      className="fixed inset-0 bg-gradient-to-br from-purple-900 via-purple-800 to-indigo-900 z-50 flex items-center justify-center"
      style={{
        animation: 'focusFadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1)',
      }}
    >
      <button
        onClick={() => setFocusMode(false)}
        className="absolute top-8 right-8 flex items-center gap-2 px-6 py-3 bg-white/10 backdrop-blur-md border border-white/20 rounded-xl text-white font-semibold hover:bg-white/20 transition"
      >
        <X className="w-5 h-5" />
        Exit Focus
      </button>

      <div
        className="text-center"
        style={{
          animation: 'focusSlideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.1s backwards',
        }}
      >
        <h1 className="text-3xl font-semibold text-white/90 mb-12">
          {selectedTask?.title || 'Focus Session'}
        </h1>

        <div className="text-[160px] font-extrabold text-white font-mono mb-8 leading-none tracking-tight">
          {formatTime(timeLeft)}
        </div>

        <div className="w-[500px] h-1 bg-white/20 rounded-full mx-auto mb-12 overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-purple-400 to-pink-400 rounded-full transition-all duration-1000 ease-linear"
            style={{ width: `$\{progress}%` }}
          />
        </div>

        <div className="flex gap-4 justify-center">
          <button
            onClick={() => selectedTaskId && toggleTimer(selectedTaskId)}
            className="flex items-center gap-3 px-10 py-5 bg-white text-purple-900 rounded-2xl font-bold text-lg hover:scale-105 transition-transform shadow-2xl"
          >
            {isRunning ? (
              <>
                <Pause className="w-7 h-7" />
                Pause
              </>
            ) : (
              <>
                <Play className="w-7 h-7" />
                Start
              </>
            )}
          </button>
          <button
            onClick={resetTimer}
            className="flex items-center gap-3 px-8 py-5 bg-white/10 backdrop-blur-md border border-white/20 text-white rounded-2xl font-semibold hover:bg-white/20 transition"
          >
            <RotateCcw className="w-6 h-6" />
            Reset
          </button>
        </div>
      </div>

      <style jsx>{`
        @keyframes focusFadeIn {
          from {
            opacity: 0;
            transform: scale(0.95);
          }
          to {
            opacity: 1;
            transform: scale(1);
          }
        }
        @keyframes focusSlideUp {
          from {
            opacity: 0;
            transform: translateY(30px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
      `}</style>
    </div>
  )
}
"@ | Out-File -FilePath "components/FocusMode.tsx" -Encoding utf8

# ============================================
# 3. STORES (Zustand)
# ============================================

# store/timerStore.ts
@"
import { create } from 'zustand'

interface TimerState {
  isRunning: boolean
  timeLeft: number
  focusMode: boolean
  currentTaskId: string | null
  toggleTimer: (taskId: string) => void
  resetTimer: () => void
  setFocusMode: (mode: boolean) => void
  tick: () => void
}

export const useTimerStore = create<TimerState>((set, get) => ({
  isRunning: false,
  timeLeft: 25 * 60,
  focusMode: false,
  currentTaskId: null,

  toggleTimer: (taskId: string) => {
    const state = get()
    set({
      isRunning: !state.isRunning,
      currentTaskId: taskId,
      focusMode: !state.isRunning ? true : state.focusMode,
    })
  },

  resetTimer: () => {
    set({
      isRunning: false,
      timeLeft: 25 * 60,
      focusMode: false,
    })
  },

  setFocusMode: (mode: boolean) => {
    set({ focusMode: mode })
  },

  tick: () => {
    const state = get()
    if (state.timeLeft > 0) {
      set({ timeLeft: state.timeLeft - 1 })
    } else {
      set({ isRunning: false })
      // Optional: Play sound or notification
    }
  },
}))
"@ | Out-File -FilePath "store/timerStore.ts" -Encoding utf8

# store/selectedTaskStore.ts
@"
import { create } from 'zustand'

interface SelectedTaskState {
  selectedTaskId: string | null
  setSelectedTaskId: (id: string | null) => void
}

export const useSelectedTaskStore = create<SelectedTaskState>((set) => ({
  selectedTaskId: null,
  setSelectedTaskId: (id) => set({ selectedTaskId: id }),
}))
"@ | Out-File -FilePath "store/selectedTaskStore.ts" -Encoding utf8

# store/commandPaletteStore.ts
@"
import { create } from 'zustand'

interface CommandPaletteState {
  show: boolean
  setShow: (show: boolean) => void
}

export const useCommandPaletteStore = create<CommandPaletteState>((set) => ({
  show: false,
  setShow: (show) => set({ show }),
}))
"@ | Out-File -FilePath "store/commandPaletteStore.ts" -Encoding utf8

# ============================================
# 4. TYPES
# ============================================

# types/index.ts
@"
export interface Task {
  id: string
  user_id: string
  parent_id: string | null
  title: string
  completed: boolean
  time_spent: number
  created_at: string
  updated_at: string
}

export interface User {
  id: string
  email: string
}
"@ | Out-File -FilePath "types/index.ts" -Encoding utf8

Write-Host "✅ All components and stores created!" -ForegroundColor Green
Write-Host "Creating Supabase utilities..." -ForegroundColor Cyan
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
