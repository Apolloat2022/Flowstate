# FlowState - Deep Work Task Manager

A focus-driven task management app with nested tasks, Pomodoro timer, and immersive focus mode.

## Features

- ✅ **Nested Tasks**: Unlimited task hierarchy with parent-child relationships
- ⏱️ **25-Minute Timer**: Pomodoro-style deep work sessions
- 🎯 **Focus Mode**: Full-screen immersive environment
- ⚡ **Command Palette**: Quick actions with `Cmd/Ctrl + K`
- ⌨️ **Keyboard Shortcuts**: Efficient navigation and control
- 💾 **Auto-Save**: Persistent storage with localStorage
- 📱 **Responsive**: Works on desktop and mobile

## Getting Started

### Prerequisites

- Node.js 18+ installed
- npm or yarn

### Installation

1. **Install dependencies:**
```bash
npm install
```

2. **Run the development server:**
```bash
npm run dev
```

3. **Open your browser:**
Navigate to [http://localhost:3000](http://localhost:3000)

## Usage

### Keyboard Shortcuts

- **`Cmd/Ctrl + K`** - Open command palette
- **`Space`** - Start/pause timer (when task selected)
- **`ESC`** - Close command palette or exit focus mode
- **`Enter`** - Save task edit
- **`ESC`** (while editing) - Cancel edit

### Creating Tasks

1. Click "New Task" button or use command palette
2. Add subtasks by clicking the "+" button on any task
3. Click task to select it
4. Start timer to enter focus mode

### Timer Features

- **25-minute sessions** with circular progress indicator
- **Focus Mode**: Click "Start Focus" or let it activate automatically
- **Persistent**: Timer continues even when navigating

## Tech Stack

- **Next.js 15** - React framework
- **TypeScript** - Type safety
- **Lucide React** - Icon library
- **LocalStorage** - Data persistence

## Project Structure

```
flowstate/
├── app/
│   ├── layout.tsx       # Root layout
│   ├── page.tsx         # Home page
│   └── globals.css      # Global styles
├── src/
│   └── components/
│       └── FlowStateApp.tsx  # Main app component
├── package.json
├── tsconfig.json
└── next.config.mjs
```

## Future Enhancements

- [ ] Supabase integration for real-time sync
- [ ] User authentication
- [ ] Analytics dashboard
- [ ] Custom timer durations
- [ ] Task tags and filters
- [ ] Export/import functionality

## License

MIT

## Support

For issues or questions, please open an issue on GitHub.
