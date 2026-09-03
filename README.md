# NaloFocus

<p align="center">
  <img src="docs/assets/icon.png" width="128" height="128" alt="NaloFocus Icon" />
</p>

<p align="center">
  <strong>Time-block your Reminders into focused work sprints</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#development">Development</a> •
  <a href="#documentation">Documentation</a>
</p>

---

## Overview

NaloFocus is a lightweight macOS menu bar application that transforms your unscheduled Reminders into time-blocked work sprints. Simply select your tasks, assign durations, add breaks, and let NaloFocus schedule them sequentially starting from now. The native Reminders app handles all notifications, keeping you focused and on track.

### Why NaloFocus?

- **🎯 Focus**: Turn overwhelming task lists into manageable time-blocked sprints
- **⏰ Simple**: No complex project management - just pick tasks and go
- **🔔 Native**: Leverages macOS Reminders for notifications
- **🚀 Fast**: Schedule a entire sprint in under 10 seconds
- **🧘 Mindful**: Built-in break reminders to prevent burnout
- **🔒 Private**: No data collection, no accounts, no tracking

## Features

### Core Functionality
- ✅ Menu bar quick access
- ✅ Select 1-9 tasks per sprint
- ✅ Customizable task durations (5-90 minutes)
- ✅ Automatic break scheduling
- ✅ Visual timeline preview
- ✅ Works with all Reminder accounts (iCloud, Exchange, Local)
- ✅ Past due task prioritization
- ✅ Searchable reminder selection
- ✅ Calendar slot picker: create a reminder in a Calendar time slot, swap in an existing one

### Coming Soon
- 🔜 Custom start times
- 🔜 Sprint templates
- 🔜 Productivity analytics
- 🔜 Keyboard shortcuts
- 🔜 Multi-day sprint planning

## Requirements

- macOS 15.0 (Sequoia) or later
- Swift 6.0+ (for development)
- Reminders app access permission

## Installation

### From App Store (Recommended)
*Coming soon*

### Direct Download
1. Download the latest release from [Releases](https://github.com/yourusername/NaloFocus/releases)
2. Open the downloaded `.dmg` file
3. Drag NaloFocus to your Applications folder
4. Launch NaloFocus from Applications
5. Grant Reminders access when prompted

### From Source

**⚠️ Important**: NaloFocus is a **Swift Package** executable, not an Xcode project. Use `swift` CLI commands, **never** `xcodebuild`. And always run it as a `.app` bundle: a bare `swift run` binary can neither get Reminders access nor accept keyboard input in text fields (no bundle identifier for the text input server).

```bash
git clone https://github.com/KahunaCodes/NaloFocus.git
cd NaloFocus

./launch.sh                        # debug build, bundled, signed, launched (relaunches a running copy)
make install                       # lint + test + release bundle -> /Applications/NaloFocus.app
open /Applications/NaloFocus.app   # grant Reminders access when prompted
swift test
```

Launch at login: System Settings > General > Login Items > add NaloFocus.

**Signing:** `scripts/bundle.sh` signs ad-hoc by default, and macOS forgets an ad-hoc app's Reminders grant on every rebuild. Run `scripts/make-signing-cert.sh` once to create a self-signed "NaloFocus Dev" identity; `bundle.sh` uses it automatically from then on (or set `NALOFOCUS_SIGN_IDENTITY` to any identity you prefer).

## Usage

### Quick Start

1. **Click** the NaloFocus icon in your menu bar
2. **Select** how many tasks you want to schedule (1-9)
3. **Choose** reminders from your existing lists
4. **Set** duration for each task (default: 25 minutes)
5. **Add** breaks between tasks if desired
6. **Review** your sprint timeline
7. **Start Sprint** to update all reminder times

### Tips

- **Past due tasks** appear at the top for easy access
- **Search** for reminders by typing in the picker
- **Add breaks** to maintain energy throughout your sprint
- **Preview timeline** shows exact times before committing
- **Automatic reset** after each sprint for quick iteration

### Calendar slot picker

Calendar.app can create a reminder in a time slot but cannot drop an *existing* reminder into one. NaloFocus fills that gap:

1. In Calendar, double-click an empty time slot, switch the popover to **Reminder**, press Return.
2. A floating picker appears next to the cursor within about a second. Calendar keeps focus.
3. Type to filter and press Return to take the first match, or click a reminder.
4. That reminder gets the slot's due time and alarm, the placeholder is deleted, and Calendar redraws.

Escape, Cancel, or the close button keeps the placeholder as a normal new reminder. A title typed in Calendar instead of "New Reminder" prefills the search. The **Calendar slot picker** switch in the menu bar turns the feature off.

It only reacts to reminders that appeared while Calendar was the front app, were created seconds earlier, and carry a time. Reminders synced from your phone or edited in Reminders.app never trigger it.

## Development

### Project Structure
```
NaloFocus/
├── Package.swift              # Swift Package manifest
├── PHASE_PLAN.md              # Development roadmap and progress
├── PRD.md                     # Product requirements document
├── CLAUDE.md                  # AI development guide
├── docs/                      # Documentation
│   ├── DAILY_PROGRESS.md     # Daily development log
│   ├── DECISIONS.md          # Architectural decisions
│   └── RISKS.md              # Risk management
├── Sources/
│   ├── main.swift            # SPM entry point
│   └── NaloFocus/            # Source code
│       ├── NaloFocusApp.swift    # App with DEBUG/RELEASE modes
│       ├── Views/                # SwiftUI views
│       ├── Models/               # Data models & ViewModels
│       ├── Services/             # Business logic
│       └── Utilities/            # Helper functions
└── Tests/
    └── NaloFocusTests/       # Test suite
```

### Architecture

NaloFocus follows **MVVM architecture** with Swift 6 concurrency:
- **SwiftUI** for modern, declarative UI
- **EventKit** for native Reminders integration
- **Dependency Injection** via ServiceContainer
- **Protocol-oriented** design for testability
- **Actor isolation** for thread-safe state management
- **Stateless design** - no persistence layer needed

**Key Design Principles:**
- Menu bar integration using `MenuBarExtra` API
- DEBUG mode: Window app for development
- RELEASE mode: Menu bar extra with modal presentation
- No external dependencies - pure Swift/SwiftUI

### Building

**⚠️ Critical**: This is a **Swift Package Manager** project, not an Xcode project (`.xcodeproj`).

Requirements:
- Swift 6.0+
- macOS 15.0+ SDK

```bash
# Standard build
swift build

# Clean build (fixes most issues)
swift package clean && swift build

# Run in DEBUG mode (window instead of menu bar), as a bundle
./launch.sh

# Release bundle in .build/release, or straight into /Applications
make bundle
make install

# Reset dependencies
swift package reset
swift package update
```

### Testing

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter TimeCalculatorTests

# Run with verbose output
swift test --verbose

# Generate coverage report
swift test --enable-code-coverage
xcrun llvm-cov report .build/debug/NaloFocusPackageTests.xctest/Contents/MacOS/NaloFocusPackageTests \
  -instr-profile .build/debug/codecov/default.profdata
```

### DEBUG vs RELEASE Modes

The app uses compile-time flags for different UIs:

```swift
#if DEBUG
    WindowGroup { SprintDialogView() }  // Regular window for testing
#else
    MenuBarExtra { ... }                // Menu bar for production
#endif
```

Run `./launch.sh` for a DEBUG bundle with a standard window, making UI development easier. Plain `swift run` starts a bundle-less binary whose text fields beep and which cannot get Reminders access.

### Troubleshooting

#### Swift 6 Concurrency Issues

**Problem**: Actor isolation errors in ServiceContainer
```swift
// ❌ WRONG - Causes "main actor-isolated default value in nonisolated context"
lazy var reminderManager: ReminderManagerProtocol = ReminderManager()
```

**Solution**: Mark ServiceContainer or properties with proper actor annotations
```swift
// ✅ CORRECT - Add @MainActor to class
@MainActor
final class ServiceContainer { ... }
```

#### EventKit Callbacks with Continuations

**Problem**: "Value passed as strongly transferred parameter" error
```swift
// ❌ WRONG
continuation.resume(returning: reminders ?? [])
```

**Solution**: Ensure proper sendability
```swift
// ✅ CORRECT
return try await withCheckedThrowingContinuation { continuation in
    eventStore.fetchReminders(matching: predicate) { reminders in
        let safeReminders = reminders ?? []
        continuation.resume(returning: safeReminders)
    }
}
```

#### Calendar slot picker

- **No panel appears**: check the switch in the menu bar, then watch the log while you create the reminder in Calendar:
  ```bash
  log stream --predicate 'subsystem == "com.kahunacodes.NaloFocus"' --level debug
  ```
  Every new reminder logs the gate that rejected it: `Calendar not frontmost`, `not freshly created`, `no timed due date`, `echo of our own save`, `picker already open`.
- **Reminders permission prompt after every rebuild**: the bundle is ad-hoc signed. Run `scripts/make-signing-cert.sh` once (see Installation). If a prompt loops or access reads as denied: `tccutil reset Reminders com.kahunacodes.NaloFocus`, then relaunch.
- **Text fields beep**: you launched the bare binary. Use `./launch.sh` or the installed app.
- **Preview the panel without Calendar**: `./launch.sh --env NALOFOCUS_TEST_PANEL=1` shows it with a fake slot one hour out; picks are logged, nothing is saved.

#### Build Issues

If you encounter build errors:

```bash
# Clean all build artifacts
swift package clean
rm -rf .build/

# Reset package dependencies
swift package reset

# Rebuild
swift build
```

## Documentation

### Getting Started
- [README](README.md) - This file - Project introduction and quick start
- [CLAUDE.md](CLAUDE.md) - Claude Code integration guide for AI-assisted development

### Comprehensive Guides
- **[Project Index](docs/PROJECT_INDEX.md)** - Complete project navigation with cross-references
- **[Architecture Guide](docs/ARCHITECTURE.md)** - System architecture, design principles, and patterns
- **[API Reference](docs/API_REFERENCE.md)** - Detailed API documentation for all components
- **[Testing Guide](TESTING_GUIDE.md)** - Testing strategies and procedures

### Product & Planning
- [Product Requirements](PRD.md) - Detailed product specification
- [Phase Plan](PHASE_PLAN.md) - Development roadmap and progress tracking

### Development Records
- [Architecture Decisions](docs/DECISIONS.md) - Key design choices explained (ADRs)
- [Risk Register](docs/RISKS.md) - Project risks and mitigations
- [Daily Progress](docs/DAILY_PROGRESS.md) - Development diary

### Implementation Details
- [Task Insertion](docs/TASK_INSERTION_IMPLEMENTATION.md) - Inline task insertion UI pattern
- [Calendar Colors](docs/CALENDAR_COLORS_FIX.md) - Calendar color integration
- [Task Symbols](docs/TASK_SYMBOLS_IMPLEMENTATION.md) - Visual symbol system
- [UI Improvements](docs/UI_IMPROVEMENTS.md) - UI enhancement records

## Contributing

NaloFocus is currently in active initial development. We'll open for contributions after the 1.0 release. Stay tuned!

## Support

- 🐛 [Report bugs](https://github.com/yourusername/NaloFocus/issues)
- 💡 [Request features](https://github.com/yourusername/NaloFocus/issues)
- 📧 [Email support](mailto:support@nalofocus.app)

## Privacy

NaloFocus is designed with privacy in mind:
- ✅ No data collection
- ✅ No analytics or tracking
- ✅ No network requests
- ✅ No accounts required
- ✅ All data stays in your Reminders app

## License

Copyright © 2025 NaloFocus. All rights reserved.

*License details to be determined*

## Acknowledgments

- Built with SwiftUI and EventKit
- Inspired by Pomodoro Technique and time-blocking methodologies
- Menu bar implementation using MenuBarExtra API

---

<p align="center">
  Made with ☕️ and 🎯 for focused productivity
</p>