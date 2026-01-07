# FlowState - Complete Next.js 15 Project Setup

## 🚀 Quick Start (Easiest Method)

### Option 1: Run Complete Setup Script (Recommended)

1. Open PowerShell as Administrator
2. Navigate to where you downloaded these files
3. Run:
   ```powershell
   .\COMPLETE_SETUP.ps1
   ```

This single script creates the entire project at `C:\Flowstate\app` with all files!

---

### Option 2: Run Scripts Step-by-Step

If you prefer to see each step, run the scripts in this order:

```powershell
.\setup-flowstate.ps1       # Creates project structure & config files
.\create-app-files.ps1      # Creates app directory files
.\create-components.ps1     # Creates Header & TaskList components
.\create-components-2.ps1   # Creates TaskItem & Timer components
.\create-stores.ps1         # Creates CommandPalette, FocusMode & stores
.\create-final-files.ps1    # Creates utilities & final setup
```

---

## 📋 After Running the Scripts

### 1. Install Dependencies
```powershell
cd C:\Flowstate\app
npm install
```

### 2. Set Up Supabase

**A. Create Supabase Project:**
- Go to https://supabase.com
- Sign up / Log in
- Click "New Project"
- Fill in project details
- Wait for database to be ready

**B. Get Your Credentials:**
- Go to Project Settings → API
- Copy `Project URL` and `anon public` key

**C. Run Database Schema:**
- Go to SQL Editor in Supabase dashboard
- Click "New Query"
- Open `SUPABASE_SETUP.md` (in your project folder)
- Copy the SQL code and paste it
- Click "Run"

### 3. Configure Environment Variables

```powershell
cd C:\Flowstate\app
cp .env.local.example .env.local
```

Then edit `.env.local` and add your Supabase credentials:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
```

### 4. Run Development Server

```powershell
npm run dev
```

Open http://localhost:3000 in your browser!

---

## ✨ Features Included

- ✅ **Nested Tasks** - Create tasks with unlimited subtasks
- ✅ **Pomodoro Timer** - 25-minute focus sessions
- ✅ **Focus Mode** - Full-screen immersive experience
- ✅ **Command Palette** - Quick actions with `Cmd+K`
- ✅ **Real-time Sync** - Changes sync across devices
- ✅ **Magic Link Auth** - No password needed
- ✅ **Responsive Design** - Works on desktop & mobile

---

## 🎯 Tech Stack

- **Framework:** Next.js 15 (App Router)
- **Database:** Supabase (PostgreSQL)
- **State:** Zustand
- **Styling:** Tailwind CSS
- **Icons:** Lucide React
- **Language:** TypeScript

---

## ⌨️ Keyboard Shortcuts

- `Cmd/Ctrl + K` - Open command palette
- `Space` - Start/pause timer
- `Esc` - Exit focus mode
- `Enter` - Save task edit

---

## 📁 Project Structure

```
C:\Flowstate\app\
├── app/
│   ├── layout.tsx          # Root layout with fonts
│   ├── page.tsx            # Main app page
│   ├── globals.css         # Global styles
│   └── auth/
│       ├── page.tsx        # Auth page (magic link)
│       └── callback/
│           └── route.ts    # Auth callback handler
├── components/
│   ├── Header.tsx          # Top navigation bar
│   ├── TaskList.tsx        # Sidebar with tasks
│   ├── TaskItem.tsx        # Individual task component
│   ├── Timer.tsx           # Pomodoro timer UI
│   ├── CommandPalette.tsx  # Quick action menu
│   └── FocusMode.tsx       # Full-screen focus overlay
├── store/
│   ├── timerStore.ts       # Timer state (Zustand)
│   ├── selectedTaskStore.ts # Selected task state
│   └── commandPaletteStore.ts # Command palette state
├── lib/
│   └── supabase.ts         # Supabase client config
├── types/
│   └── index.ts            # TypeScript type definitions
└── utils/
    └── cn.ts               # Utility for merging classNames
```

---

## 🔧 Troubleshooting

### PowerShell Execution Policy Error

If you get an error about execution policy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### npm install fails

Make sure you have Node.js 18+ installed:
- Download from https://nodejs.org

### Supabase connection issues

1. Double-check your `.env.local` credentials
2. Make sure you ran the SQL schema
3. Verify RLS (Row Level Security) is enabled

### Tasks not showing up

1. Check browser console for errors
2. Verify you're signed in
3. Make sure Supabase RLS policies are correct

---

## 🚀 Deploying to Production

### Vercel (Recommended)

1. Push your code to GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/flowstate.git
   git push -u origin main
   ```

2. Go to https://vercel.com
3. Click "New Project"
4. Import your GitHub repository
5. Add environment variables:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
6. Click "Deploy"

Your app will be live in minutes!

---

## 📖 Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Zustand Documentation](https://docs.pmnd.rs/zustand)

---

## 💡 Tips

- Use `Cmd+K` frequently for quick task creation
- Press Space on any task to start the timer immediately
- Enable Focus Mode for distraction-free work sessions
- Tasks are automatically synced - open on multiple devices!

---

## 🎉 You're All Set!

Your FlowState app is ready to help you achieve deep work and flow state.

**Need help?** Check the documentation files in your project folder.

Happy focusing! 🚀
