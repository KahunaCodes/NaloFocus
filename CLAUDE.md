# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NaloFocus is a lightweight macOS menu bar application that transforms unscheduled Reminders into time-blocked work sprints. It's built with Swift Package Manager (not Xcode project), using SwiftUI and EventKit for native macOS integration.

## Build and Development Commands

### Building
```bash
# Build the project
swift build

# Build for release
swift build -c release

# Clean build
swift build --clean
```

### Testing
```bash
# Run all tests
swift test

# Run tests with coverage
swift test --enable-code-coverage

# Run specific test
swift test --filter NaloFocusTests.TestClassName
```

### Running
```bash
# Run the application
swift run NaloFocus

# Run with specific configuration
swift run NaloFocus -c debug
```

## Architecture Overview

### Core Design Principles
- **Stateless Design**: No persistence layer - each session starts fresh
- **MVVM Pattern**: Clear separation between UI (Views), business logic (ViewModels), and data (Models)
- **Protocol-Oriented**: All services have protocol definitions for testability
- **Dependency Injection**: ServiceContainer provides centralized dependency management

### Key Architectural Components

1. **ServiceContainer** (`Sources/NaloFocus/Services/ServiceContainer.swift`)
   - Singleton pattern for dependency injection
   - Provides ReminderManager and TimeCalculator services
   - Integrated with SwiftUI Environment for view access

2. **EventKit Integration** (`ReminderManager`)
   - Direct EventKit framework usage for Reminder operations
   - Handles permissions, fetching, updating, and creating reminders
   - Creates separate "Breaks" reminder list to avoid clutter

3. **Sprint Session Flow**
   - User selects 1-9 tasks → Sets duration for each → Adds optional breaks
   - Timeline preview shows exact scheduling before commit
   - All reminders updated sequentially from current time

4. **Menu Bar Integration**
   - Uses MenuBarExtra API (requires macOS 15+)
   - Modal dialog for sprint planning (not popover)
   - Resets to clean state after each sprint creation

### Project Structure
```
Sources/NaloFocus/
├── NaloFocusApp.swift        # Entry point with MenuBarExtra
├── Models/
│   ├── SprintSession.swift   # Sprint container with timing
│   ├── SprintTask.swift      # Individual task with duration
│   ├── TimelineEntry.swift   # Timeline visualization data
│   └── ReminderCategory.swift # Categorization logic
├── Services/
│   ├── ReminderManager.swift # EventKit operations
│   └── TimeCalculator.swift  # Time calculation logic
└── Views/
    └── MenuBarContentView.swift # Main UI
```

## Important Implementation Notes

### Swift Concurrency
- The codebase uses Swift 6 concurrency with `@MainActor` and `async/await`
- EventKit operations are wrapped with `withCheckedThrowingContinuation`
- Be mindful of actor isolation when modifying services

### EventKit Permissions
- App requires Reminders access permission (handled via Info.plist)
- Permission flow is triggered on first launch
- Handles multiple reminder accounts (iCloud, Exchange, Local)

### UI State Management
- ViewModels use `@Published` properties for UI updates
- AppStateCoordinator manages global app state
- Form resets completely after successful sprint creation

### Known Compilation Issues
- Swift 6 strict concurrency checking may flag actor isolation issues
- ServiceContainer lazy initialization needs proper actor annotation
- EventKit callbacks require careful handling with continuations

## Testing Strategy

- Unit tests focus on TimeCalculator and business logic
- Mock protocols exist for ReminderManagerProtocol and TimeCalculatorProtocol
- UI testing not yet implemented but planned for sprint creation flow
- Target coverage: >80% for business logic

## Current Development Status

The project is in active development (Day 1-2 of 16-day sprint):
- Foundation phase completed with basic infrastructure
- EventKit integration implemented
- Core models and services in place
- UI implementation in progress

Refer to `PHASE_PLAN.md` for detailed progress tracking and `docs/DECISIONS.md` for architectural rationale.