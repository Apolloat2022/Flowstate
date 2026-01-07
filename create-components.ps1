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
