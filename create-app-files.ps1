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
