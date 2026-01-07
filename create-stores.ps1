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
