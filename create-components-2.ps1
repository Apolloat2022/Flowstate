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
