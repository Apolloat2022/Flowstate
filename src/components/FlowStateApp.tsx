'use client';

import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { Plus, Play, Pause, Check, ChevronRight, ChevronDown, Clock, Zap, Command, Search, X, User } from 'lucide-react';

// Types
interface Task {
  id: string;
  title: string;
  completed: boolean;
  parent_id: string | null;
  user_id: string;
  created_at: string;
  time_spent: number;
  children?: Task[];
}

interface TimerState {
  isRunning: boolean;
  timeLeft: number;
  focusMode: boolean;
  currentTaskId: string | null;
  sessions: any[];
}

interface Store<T> {
  getState: () => T;
  setState: (updater: T | ((state: T) => T)) => void;
  subscribe: (listener: (state: T) => void) => () => void;
}

// Zustand-like state management
const createStore = <T,>(initialState: T): Store<T> => {
  let state = initialState;
  const listeners = new Set<(state: T) => void>();
  
  return {
    getState: () => state,
    setState: (updater) => {
      state = typeof updater === 'function' ? (updater as (state: T) => T)(state) : { ...state, ...updater };
      listeners.forEach(listener => listener(state));
    },
    subscribe: (listener) => {
      listeners.add(listener);
      return () => listeners.delete(listener);
    }
  };
};

// Global store for timer and app state
const timerStore = createStore<TimerState>({
  isRunning: false,
  timeLeft: 25 * 60,
  focusMode: false,
  currentTaskId: null,
  sessions: []
});

const useStore = <T,>(store: Store<T>): [T, (updater: T | ((state: T) => T)) => void] => {
  const [state, setState] = useState(store.getState());
  
  useEffect(() => {
    return store.subscribe(setState);
  }, [store]);
  
  return [state, store.setState];
};

// Simulated user
const mockUser = { id: 'user-1', email: 'demo@flowstate.app' };

export default function FlowStateApp() {
  const [user] = useState(mockUser);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [expandedTasks, setExpandedTasks] = useState(new Set<string>());
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null);
  const [showCommandPalette, setShowCommandPalette] = useState(false);
  const [timerState, setTimerState] = useStore(timerStore);
  const [editingTaskId, setEditingTaskId] = useState<string | null>(null);
  const [editingText, setEditingText] = useState('');

  // Load tasks from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('flowstate-tasks');
    if (saved) {
      setTasks(JSON.parse(saved));
    } else {
      // Demo data
      const demoTasks: Task[] = [
        {
          id: '1',
          title: 'Launch FlowState MVP',
          completed: false,
          parent_id: null,
          user_id: 'user-1',
          created_at: new Date().toISOString(),
          time_spent: 0
        },
        {
          id: '2',
          title: 'Backend Setup',
          completed: true,
          parent_id: '1',
          user_id: 'user-1',
          created_at: new Date().toISOString(),
          time_spent: 1500
        },
        {
          id: '3',
          title: 'Configure Supabase',
          completed: true,
          parent_id: '2',
          user_id: 'user-1',
          created_at: new Date().toISOString(),
          time_spent: 900
        },
        {
          id: '4',
          title: 'Frontend Implementation',
          completed: false,
          parent_id: '1',
          user_id: 'user-1',
          created_at: new Date().toISOString(),
          time_spent: 3000
        },
        {
          id: '5',
          title: 'Build command palette',
          completed: false,
          parent_id: '4',
          user_id: 'user-1',
          created_at: new Date().toISOString(),
          time_spent: 0
        }
      ];
      setTasks(demoTasks);
      setExpandedTasks(new Set(['1', '2', '4']));
    }
  }, []);

  // Save tasks to localStorage
  useEffect(() => {
    if (tasks.length > 0) {
      localStorage.setItem('flowstate-tasks', JSON.stringify(tasks));
    }
  }, [tasks]);

  // Timer logic
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (timerState.isRunning && timerState.timeLeft > 0) {
      interval = setInterval(() => {
        setTimerState(state => {
          if (state.timeLeft <= 1) {
            return { ...state, isRunning: false, timeLeft: 0 };
          }
          return { ...state, timeLeft: state.timeLeft - 1 };
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [timerState.isRunning, timerState.timeLeft, setTimerState]);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setShowCommandPalette(true);
      }
      if (e.key === 'Escape') {
        setShowCommandPalette(false);
        if (timerState.focusMode) {
          setTimerState({ ...timerState, focusMode: false });
        }
      }
      if (e.key === ' ' && selectedTaskId && !editingTaskId && !showCommandPalette) {
        e.preventDefault();
        toggleTimer();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedTaskId, timerState.focusMode, editingTaskId, showCommandPalette]);

  // Task operations
  const addTask = useCallback((title: string, parentId: string | null = null) => {
    const newTask: Task = {
      id: Date.now().toString(),
      title,
      completed: false,
      parent_id: parentId,
      user_id: user.id,
      created_at: new Date().toISOString(),
      time_spent: 0
    };
    
    setTasks(prev => [...prev, newTask]);
    
    if (parentId) {
      setExpandedTasks(prev => new Set([...prev, parentId]));
    }
  }, [user]);

  const toggleTask = useCallback((taskId: string) => {
    setTasks(prev => prev.map(task => 
      task.id === taskId ? { ...task, completed: !task.completed } : task
    ));
  }, []);

  const updateTaskTitle = useCallback((taskId: string, newTitle: string) => {
    setTasks(prev => prev.map(task =>
      task.id === taskId ? { ...task, title: newTitle } : task
    ));
    setEditingTaskId(null);
    setEditingText('');
  }, []);

  const toggleExpanded = useCallback((taskId: string) => {
    setExpandedTasks(prev => {
      const next = new Set(prev);
      if (next.has(taskId)) {
        next.delete(taskId);
      } else {
        next.add(taskId);
      }
      return next;
    });
  }, []);

  const toggleTimer = useCallback(() => {
    if (!selectedTaskId) return;
    
    setTimerState(state => ({
      ...state,
      isRunning: !state.isRunning,
      currentTaskId: selectedTaskId,
      focusMode: !state.isRunning ? true : state.focusMode
    }));
  }, [selectedTaskId, setTimerState]);

  const resetTimer = useCallback(() => {
    setTimerState(state => ({
      ...state,
      isRunning: false,
      timeLeft: 25 * 60,
      focusMode: false
    }));
  }, [setTimerState]);

  // Build task tree
  const taskTree = useMemo(() => {
    const map = new Map<string, Task>();
    tasks.forEach(task => {
      map.set(task.id, { ...task, children: [] });
    });
    
    const roots: Task[] = [];
    map.forEach(task => {
      if (task.parent_id && map.has(task.parent_id)) {
        map.get(task.parent_id)!.children!.push(task);
      } else if (!task.parent_id) {
        roots.push(task);
      }
    });
    
    return roots;
  }, [tasks]);

  // Format timer display
  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  // Render task recursively
  const TaskItem = ({ task, depth = 0 }: { task: Task; depth?: number }) => {
    const hasChildren = task.children && task.children.length > 0;
    const isExpanded = expandedTasks.has(task.id);
    const isSelected = selectedTaskId === task.id;
    const isCurrentTimer = timerState.currentTaskId === task.id;
    const isEditing = editingTaskId === task.id;

    return (
      <div style={{ marginLeft: `${depth * 24}px` }}>
        <div
          className={`task-item ${isSelected ? 'selected' : ''} ${isCurrentTimer ? 'timer-active' : ''}`}
          onClick={() => setSelectedTaskId(task.id)}
        >
          <div className="task-left">
            {hasChildren && (
              <button
                className="expand-btn"
                onClick={(e) => {
                  e.stopPropagation();
                  toggleExpanded(task.id);
                }}
              >
                {isExpanded ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
              </button>
            )}
            <button
              className="checkbox"
              onClick={(e) => {
                e.stopPropagation();
                toggleTask(task.id);
              }}
            >
              {task.completed && <Check size={14} />}
            </button>
            {isEditing ? (
              <input
                type="text"
                className="task-edit-input"
                value={editingText}
                onChange={(e) => setEditingText(e.target.value)}
                onBlur={() => updateTaskTitle(task.id, editingText)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    updateTaskTitle(task.id, editingText);
                  } else if (e.key === 'Escape') {
                    setEditingTaskId(null);
                    setEditingText('');
                  }
                }}
                autoFocus
                onClick={(e) => e.stopPropagation()}
              />
            ) : (
              <span className={`task-title ${task.completed ? 'completed' : ''}`}>
                {task.title}
              </span>
            )}
          </div>
          <div className="task-actions">
            {isCurrentTimer && timerState.isRunning && (
              <div className="timer-badge">
                <Clock size={12} />
                {formatTime(timerState.timeLeft)}
              </div>
            )}
            <button
              className="action-btn"
              onClick={(e) => {
                e.stopPropagation();
                setEditingTaskId(task.id);
                setEditingText(task.title);
              }}
            >
              Edit
            </button>
            <button
              className="action-btn"
              onClick={(e) => {
                e.stopPropagation();
                addTask('New subtask', task.id);
              }}
            >
              <Plus size={14} />
            </button>
          </div>
        </div>
        {isExpanded && hasChildren && (
          <div className="task-children">
            {task.children!.map(child => (
              <TaskItem key={child.id} task={child} depth={depth + 1} />
            ))}
          </div>
        )}
      </div>
    );
  };

  // Command Palette
  const CommandPalette = () => {
    const [query, setQuery] = useState('');
    const inputRef = useRef<HTMLInputElement>(null);

    useEffect(() => {
      if (showCommandPalette && inputRef.current) {
        inputRef.current.focus();
      }
    }, []);

    interface CommandItem {
      label: string;
      icon: React.ElementType;
      action: () => void;
      disabled?: boolean;
    }

    const commands: CommandItem[] = [
      { label: 'New Task', icon: Plus, action: () => {
        addTask('New task');
        setShowCommandPalette(false);
      }},
      { label: 'Start Timer', icon: Play, action: () => {
        if (selectedTaskId) toggleTimer();
        setShowCommandPalette(false);
      }, disabled: !selectedTaskId },
      { label: 'Reset Timer', icon: Clock, action: () => {
        resetTimer();
        setShowCommandPalette(false);
      }},
      { label: 'Toggle Focus Mode', icon: Zap, action: () => {
        setTimerState(s => ({ ...s, focusMode: !s.focusMode }));
        setShowCommandPalette(false);
      }},
    ];

    const filteredCommands = commands.filter(cmd =>
      cmd.label.toLowerCase().includes(query.toLowerCase())
    );

    return (
      <div className="command-overlay" onClick={() => setShowCommandPalette(false)}>
        <div className="command-palette" onClick={(e) => e.stopPropagation()}>
          <div className="command-search">
            <Search size={18} />
            <input
              ref={inputRef}
              type="text"
              placeholder="Type a command or search..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Escape') {
                  setShowCommandPalette(false);
                }
              }}
            />
          </div>
          <div className="command-results">
            {filteredCommands.map((cmd, idx) => (
              <button
                key={idx}
                className={`command-item ${cmd.disabled ? 'disabled' : ''}`}
                onClick={cmd.action}
                disabled={cmd.disabled}
              >
                <cmd.icon size={16} />
                <span>{cmd.label}</span>
              </button>
            ))}
          </div>
          <div className="command-footer">
            <kbd>⌘K</kbd> to open • <kbd>ESC</kbd> to close
          </div>
        </div>
      </div>
    );
  };

  // Focus Mode Overlay
  if (timerState.focusMode) {
    const currentTask = tasks.find(t => t.id === timerState.currentTaskId);
    
    return (
      <div className="focus-mode">
        <button 
          className="exit-focus"
          onClick={() => setTimerState(s => ({ ...s, focusMode: false }))}
        >
          <X size={20} />
          Exit Focus
        </button>
        
        <div className="focus-content">
          <div className="focus-task-title">
            {currentTask?.title || 'No task selected'}
          </div>
          
          <div className="focus-timer">
            {formatTime(timerState.timeLeft)}
          </div>
          
          <div className="focus-progress">
            <div 
              className="focus-progress-bar"
              style={{ 
                width: `${((25 * 60 - timerState.timeLeft) / (25 * 60)) * 100}%` 
              }}
            />
          </div>
          
          <div className="focus-controls">
            <button
              className="focus-btn"
              onClick={toggleTimer}
            >
              {timerState.isRunning ? <Pause size={24} /> : <Play size={24} />}
              {timerState.isRunning ? 'Pause' : 'Start'}
            </button>
            <button
              className="focus-btn secondary"
              onClick={resetTimer}
            >
              Reset
            </button>
          </div>
        </div>
        
        <style jsx>{`
          .focus-mode {
            position: fixed;
            inset: 0;
            background: linear-gradient(135deg, #0f0f23 0%, #1a1a3e 50%, #16213e 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            animation: focusFadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1);
          }
          
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
          
          .exit-focus {
            position: absolute;
            top: 32px;
            right: 32px;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            color: white;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            backdrop-filter: blur(10px);
          }
          
          .exit-focus:hover {
            background: rgba(255, 255, 255, 0.15);
            transform: translateY(-1px);
          }
          
          .focus-content {
            text-align: center;
            max-width: 600px;
            animation: focusSlideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.1s backwards;
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
          
          .focus-task-title {
            font-size: 24px;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 48px;
            letter-spacing: -0.02em;
          }
          
          .focus-timer {
            font-size: 120px;
            font-weight: 700;
            color: white;
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.03em;
            margin-bottom: 32px;
            text-shadow: 0 0 60px rgba(100, 100, 255, 0.3);
          }
          
          .focus-progress {
            width: 400px;
            height: 4px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 2px;
            margin: 0 auto 48px;
            overflow: hidden;
          }
          
          .focus-progress-bar {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transition: width 1s linear;
            border-radius: 2px;
          }
          
          .focus-controls {
            display: flex;
            gap: 16px;
            justify-content: center;
          }
          
          .focus-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 32px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            border-radius: 16px;
            color: white;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: 0 8px 32px rgba(102, 126, 234, 0.4);
          }
          
          .focus-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 40px rgba(102, 126, 234, 0.5);
          }
          
          .focus-btn:active {
            transform: translateY(0);
          }
          
          .focus-btn.secondary {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: none;
          }
          
          .focus-btn.secondary:hover {
            background: rgba(255, 255, 255, 0.15);
            box-shadow: none;
          }
        `}</style>
      </div>
    );
  }

  return (
    <div className="app">
      {showCommandPalette && <CommandPalette />}
      
      <header className="header">
        <div className="header-left">
          <div className="logo">
            <Zap size={24} />
            <span>FlowState</span>
          </div>
          <button 
            className="cmd-btn"
            onClick={() => setShowCommandPalette(true)}
          >
            <Command size={14} />
            <span>Quick Actions</span>
          </button>
        </div>
        
        <div className="header-right">
          <div className="user-badge">
            <User size={16} />
            {user.email}
          </div>
        </div>
      </header>

      <div className="main-layout">
        <aside className="sidebar">
          <button 
            className="new-task-btn"
            onClick={() => addTask('New task')}
          >
            <Plus size={18} />
            New Task
          </button>
          
          <div className="task-list">
            {taskTree.map(task => (
              <TaskItem key={task.id} task={task} />
            ))}
          </div>
          
          {tasks.length === 0 && (
            <div className="empty-state">
              <Zap size={48} opacity={0.3} />
              <p>No tasks yet</p>
              <p className="hint">Create your first task to get started</p>
            </div>
          )}
        </aside>

        <main className="timer-panel">
          {selectedTaskId ? (
            <>
              <div className="timer-header">
                <h2>Deep Work Session</h2>
                <p className="timer-subtitle">
                  {tasks.find(t => t.id === selectedTaskId)?.title}
                </p>
              </div>
              
              <div className="timer-display">
                <div className="timer-circle">
                  <svg viewBox="0 0 200 200" className="timer-svg">
                    <circle
                      cx="100"
                      cy="100"
                      r="85"
                      fill="none"
                      stroke="rgba(255, 255, 255, 0.1)"
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
                      strokeDasharray={`${534 * ((25 * 60 - timerState.timeLeft) / (25 * 60))} 534`}
                      transform="rotate(-90 100 100)"
                      style={{ transition: 'stroke-dasharray 1s linear' }}
                    />
                    <defs>
                      <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" stopColor="#667eea" />
                        <stop offset="100%" stopColor="#764ba2" />
                      </linearGradient>
                    </defs>
                  </svg>
                  <div className="timer-time">
                    {formatTime(timerState.timeLeft)}
                  </div>
                </div>
              </div>
              
              <div className="timer-controls">
                <button
                  className="timer-btn primary"
                  onClick={toggleTimer}
                >
                  {timerState.isRunning ? (
                    <>
                      <Pause size={20} />
                      Pause
                    </>
                  ) : (
                    <>
                      <Play size={20} />
                      Start Focus
                    </>
                  )}
                </button>
                <button
                  className="timer-btn"
                  onClick={resetTimer}
                >
                  Reset
                </button>
              </div>
              
              <div className="keyboard-hints">
                <kbd>Space</kbd> to start/pause
                <kbd>⌘K</kbd> for commands
                <kbd>ESC</kbd> to exit focus mode
              </div>
            </>
          ) : (
            <div className="timer-empty">
              <Clock size={64} opacity={0.2} />
              <h3>Select a task to begin</h3>
              <p>Choose a task from the list to start your focus session</p>
            </div>
          )}
        </main>
      </div>

      <style jsx>{`
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap');
        
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        
        .app {
          font-family: 'Outfit', -apple-system, BlinkMacSystemFont, sans-serif;
          background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
          min-height: 100vh;
          color: #1a1a2e;
        }
        
        .header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 20px 32px;
          background: white;
          border-bottom: 1px solid #e5e7eb;
          animation: slideDown 0.5s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        @keyframes slideDown {
          from {
            opacity: 0;
            transform: translateY(-20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        
        .header-left {
          display: flex;
          align-items: center;
          gap: 24px;
        }
        
        .logo {
          display: flex;
          align-items: center;
          gap: 12px;
          font-size: 24px;
          font-weight: 800;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
        }
        
        .logo :global(svg) {
          color: #667eea;
          filter: drop-shadow(0 2px 8px rgba(102, 126, 234, 0.3));
        }
        
        .cmd-btn {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 8px 16px;
          background: #f9fafb;
          border: 1px solid #e5e7eb;
          border-radius: 8px;
          font-size: 14px;
          font-weight: 500;
          color: #6b7280;
          cursor: pointer;
          transition: all 0.2s;
        }
        
        .cmd-btn:hover {
          background: #f3f4f6;
          border-color: #d1d5db;
        }
        
        .user-badge {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 8px 16px;
          background: #f9fafb;
          border-radius: 8px;
          font-size: 14px;
          font-weight: 500;
          color: #374151;
        }
        
        .main-layout {
          display: grid;
          grid-template-columns: 400px 1fr;
          height: calc(100vh - 81px);
        }
        
        .sidebar {
          background: white;
          border-right: 1px solid #e5e7eb;
          padding: 24px;
          overflow-y: auto;
          animation: slideRight 0.5s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        @keyframes slideRight {
          from {
            opacity: 0;
            transform: translateX(-20px);
          }
          to {
            opacity: 1;
            transform: translateX(0);
          }
        }
        
        .new-task-btn {
          width: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          padding: 12px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border: none;
          border-radius: 12px;
          color: white;
          font-size: 15px;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
          box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
          margin-bottom: 24px;
        }
        
        .new-task-btn:hover {
          transform: translateY(-2px);
          box-shadow: 0 6px 24px rgba(102, 126, 234, 0.4);
        }
        
        .new-task-btn:active {
          transform: translateY(0);
        }
        
        .task-list {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }
        
        .task-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 12px;
          border-radius: 8px;
          cursor: pointer;
          transition: all 0.2s;
          animation: taskFadeIn 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        @keyframes taskFadeIn {
          from {
            opacity: 0;
            transform: translateY(10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        
        .task-item:hover {
          background: #f9fafb;
        }
        
        .task-item.selected {
          background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
          border-left: 3px solid #667eea;
        }
        
        .task-item.timer-active {
          background: linear-gradient(135deg, rgba(102, 126, 234, 0.15) 0%, rgba(118, 75, 162, 0.15) 100%);
        }
        
        .task-left {
          display: flex;
          align-items: center;
          gap: 8px;
          flex: 1;
          min-width: 0;
        }
        
        .expand-btn {
          background: none;
          border: none;
          color: #9ca3af;
          cursor: pointer;
          padding: 4px;
          display: flex;
          align-items: center;
          transition: color 0.2s;
        }
        
        .expand-btn:hover {
          color: #6b7280;
        }
        
        .checkbox {
          width: 20px;
          height: 20px;
          border: 2px solid #d1d5db;
          border-radius: 6px;
          background: white;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: all 0.2s;
          flex-shrink: 0;
        }
        
        .checkbox:hover {
          border-color: #667eea;
        }
        
        .checkbox :global(svg) {
          color: white;
          opacity: 0;
          transform: scale(0);
          transition: all 0.2s;
        }
        
        .task-item .checkbox:has(svg) {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border-color: #667eea;
        }
        
        .task-item .checkbox :global(svg) {
          opacity: 1;
          transform: scale(1);
        }
        
        .task-title {
          font-size: 14px;
          font-weight: 500;
          color: #374151;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        
        .task-title.completed {
          text-decoration: line-through;
          color: #9ca3af;
        }
        
        .task-edit-input {
          flex: 1;
          padding: 4px 8px;
          border: 1px solid #667eea;
          border-radius: 4px;
          font-size: 14px;
          font-weight: 500;
          font-family: inherit;
          outline: none;
        }
        
        .task-actions {
          display: flex;
          align-items: center;
          gap: 4px;
          opacity: 0;
          transition: opacity 0.2s;
        }
        
        .task-item:hover .task-actions {
          opacity: 1;
        }
        
        .timer-badge {
          display: flex;
          align-items: center;
          gap: 4px;
          padding: 4px 8px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border-radius: 6px;
          font-size: 12px;
          font-weight: 600;
          color: white;
          font-family: 'JetBrains Mono', monospace;
        }
        
        .action-btn {
          padding: 6px 12px;
          background: none;
          border: 1px solid transparent;
          border-radius: 6px;
          font-size: 12px;
          font-weight: 500;
          color: #6b7280;
          cursor: pointer;
          transition: all 0.2s;
        }
        
        .action-btn:hover {
          background: #f3f4f6;
          border-color: #e5e7eb;
          color: #374151;
        }
        
        .task-children {
          margin-left: 24px;
        }
        
        .empty-state {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 48px 24px;
          text-align: center;
          color: #9ca3af;
        }
        
        .empty-state p {
          margin-top: 16px;
          font-size: 16px;
          font-weight: 600;
        }
        
        .empty-state .hint {
          margin-top: 8px;
          font-size: 14px;
          font-weight: 400;
        }
        
        .timer-panel {
          padding: 48px;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          animation: fadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        @keyframes fadeIn {
          from {
            opacity: 0;
          }
          to {
            opacity: 1;
          }
        }
        
        .timer-header {
          text-align: center;
          margin-bottom: 48px;
        }
        
        .timer-header h2 {
          font-size: 32px;
          font-weight: 800;
          margin-bottom: 12px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
        }
        
        .timer-subtitle {
          font-size: 18px;
          color: #6b7280;
          font-weight: 500;
        }
        
        .timer-display {
          margin-bottom: 48px;
        }
        
        .timer-circle {
          position: relative;
          width: 300px;
          height: 300px;
        }
        
        .timer-svg {
          width: 100%;
          height: 100%;
          filter: drop-shadow(0 8px 32px rgba(102, 126, 234, 0.2));
        }
        
        .timer-time {
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          font-size: 64px;
          font-weight: 800;
          font-family: 'JetBrains Mono', monospace;
          color: #1a1a2e;
          font-variant-numeric: tabular-nums;
        }
        
        .timer-controls {
          display: flex;
          gap: 16px;
          margin-bottom: 32px;
        }
        
        .timer-btn {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 16px 32px;
          background: white;
          border: 2px solid #e5e7eb;
          border-radius: 16px;
          font-size: 16px;
          font-weight: 600;
          color: #374151;
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
          font-family: inherit;
        }
        
        .timer-btn:hover {
          border-color: #d1d5db;
          transform: translateY(-2px);
          box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
        }
        
        .timer-btn:active {
          transform: translateY(0);
        }
        
        .timer-btn.primary {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border: none;
          color: white;
          box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
        }
        
        .timer-btn.primary:hover {
          box-shadow: 0 12px 32px rgba(102, 126, 234, 0.4);
        }
        
        .keyboard-hints {
          display: flex;
          gap: 16px;
          font-size: 13px;
          color: #9ca3af;
        }
        
        .keyboard-hints kbd {
          padding: 4px 8px;
          background: #f9fafb;
          border: 1px solid #e5e7eb;
          border-radius: 4px;
          font-family: 'JetBrains Mono', monospace;
          font-size: 12px;
        }
        
        .timer-empty {
          text-align: center;
          color: #9ca3af;
        }
        
        .timer-empty h3 {
          margin-top: 24px;
          font-size: 24px;
          font-weight: 700;
          color: #6b7280;
        }
        
        .timer-empty p {
          margin-top: 12px;
          font-size: 16px;
        }
        
        .command-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, 0.5);
          display: flex;
          align-items: flex-start;
          justify-content: center;
          padding-top: 120px;
          z-index: 1000;
          backdrop-filter: blur(4px);
          animation: overlayFadeIn 0.2s ease-out;
        }
        
        @keyframes overlayFadeIn {
          from {
            opacity: 0;
          }
          to {
            opacity: 1;
          }
        }
        
        .command-palette {
          width: 100%;
          max-width: 600px;
          background: white;
          border-radius: 16px;
          box-shadow: 0 24px 48px rgba(0, 0, 0, 0.2);
          overflow: hidden;
          animation: commandSlideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
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
        
        .command-search {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 20px 24px;
          border-bottom: 1px solid #e5e7eb;
        }
        
        .command-search :global(svg) {
          color: #9ca3af;
        }
        
        .command-search input {
          flex: 1;
          border: none;
          outline: none;
          font-size: 16px;
          font-family: inherit;
          color: #1a1a2e;
        }
        
        .command-search input::placeholder {
          color: #9ca3af;
        }
        
        .command-results {
          max-height: 400px;
          overflow-y: auto;
          padding: 8px;
        }
        
        .command-item {
          width: 100%;
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 12px 16px;
          background: none;
          border: none;
          border-radius: 8px;
          font-size: 15px;
          font-weight: 500;
          color: #374151;
          cursor: pointer;
          transition: all 0.2s;
          text-align: left;
          font-family: inherit;
        }
        
        .command-item:hover:not(.disabled) {
          background: #f9fafb;
        }
        
        .command-item.disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        
        .command-footer {
          padding: 12px 24px;
          background: #f9fafb;
          border-top: 1px solid #e5e7eb;
          font-size: 13px;
          color: #6b7280;
          display: flex;
          gap: 16px;
        }
        
        .command-footer kbd {
          padding: 2px 6px;
          background: white;
          border: 1px solid #e5e7eb;
          border-radius: 4px;
          font-family: 'JetBrains Mono', monospace;
          font-size: 12px;
        }
        
        @media (max-width: 768px) {
          .main-layout {
            grid-template-columns: 1fr;
          }
          
          .sidebar {
            border-right: none;
            border-bottom: 1px solid #e5e7eb;
            max-height: 50vh;
          }
          
          .timer-panel {
            padding: 24px;
          }
          
          .timer-circle {
            width: 240px;
            height: 240px;
          }
          
          .timer-time {
            font-size: 48px;
          }
        }
      `}</style>
    </div>
  );
}
