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

### Coming Soon
- 🔜 Custom start times
- 🔜 Sprint templates
- 🔜 Productivity analytics
- 🔜 Keyboard shortcuts
- 🔜 Multi-day sprint planning

## Requirements

- macOS 15.0 (Sequoia) or later
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
```bash
# Clone the repository
git clone https://github.com/yourusername/NaloFocus.git
cd NaloFocus

# Open in Xcode
open NaloFocus.xcodeproj

# Build and run (⌘R)
```

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

## Development

### Project Structure
```
NaloFocus/
├── PHASE_PLAN.md              # Development roadmap and progress
├── PRD.md                     # Product requirements document
├── docs/                      # Documentation
│   ├── DAILY_PROGRESS.md     # Daily development log
│   ├── DECISIONS.md          # Architectural decisions
│   └── RISKS.md              # Risk management
├── NaloFocus/                 # Source code
│   ├── NaloFocusApp.swift    # App entry point
│   ├── Views/                # SwiftUI views
│   ├── Models/               # Data models
│   ├── Services/             # Business logic
│   └── Utilities/            # Helper functions
└── NaloFocusTests/           # Test suite
```

### Architecture

NaloFocus follows MVVM architecture with:
- **SwiftUI** for modern, declarative UI
- **EventKit** for Reminders integration
- **Dependency Injection** via ServiceContainer
- **Protocol-oriented** design for testability

### Building

Requirements:
- Xcode 15.0+
- macOS 15.0+ SDK
- Swift 5.9+

```bash
# Install dependencies (if any)
# None required - pure Swift/SwiftUI

# Run tests
xcodebuild test -scheme NaloFocus

# Build for release
xcodebuild build -scheme NaloFocus -configuration Release

# Create archive for distribution
xcodebuild archive -scheme NaloFocus
```

### Testing

```bash
# Unit tests
swift test

# UI tests
xcodebuild test -scheme NaloFocusUITests

# Coverage report
xcodebuild test -scheme NaloFocus -enableCodeCoverage YES
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