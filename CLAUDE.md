# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NaloFocus is a lightweight macOS menu bar application that transforms unscheduled Reminders into time-blocked work sprints. Built exclusively with **Swift Package Manager (SPM)**, using SwiftUI and EventKit for native macOS integration.

**Critical**: This is a pure Swift Package executable, not an Xcode project (`.xcodeproj`). Always use `swift` CLI commands, never `xcodebuild`. The project has no external dependencies and runs on macOS 15.0+.

## Quick Start Commands

```bash
# Build and run the app
swift run NaloFocus

# Run tests
swift test

# Build for release
swift build -c release

# Clean and rebuild (fixes most build issues)
swift package clean && swift build
```

## Common Development Tasks

### Fix Build Errors
```bash
# Clean all build artifacts
swift package clean
rm -rf .build/

# Reset package dependencies
swift package reset

# Update dependencies (if any added)
swift package update
```

### Testing Specific Components
```bash
# Test only TimeCalculator
swift test --filter TimeCalculatorTests

# Test with verbose output for debugging
swift test --verbose

# Generate coverage report
swift test --enable-code-coverage
xcrun llvm-cov report .build/debug/NaloFocusPackageTests.xctest/Contents/MacOS/NaloFocusPackageTests -instr-profile .build/debug/codecov/default.profdata
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
   - **DEBUG mode**: Window app for easier development
   - **RELEASE mode**: Menu bar extra with window-style presentation

### Project Structure
```
Sources/
├── main.swift                     # SPM entry point
└── NaloFocus/
    ├── NaloFocusApp.swift        # App with DEBUG/RELEASE modes
    ├── Models/
    │   ├── AppStateCoordinator.swift  # State management
    │   ├── SprintSession.swift        # Sprint container
    │   ├── SprintTask.swift           # Task with duration
    │   ├── SprintDialogViewModel.swift # ViewModel
    │   ├── TimelineEntry.swift        # Timeline visualization
    │   └── ReminderCategory.swift     # Categorization
    ├── Services/
    │   ├── ServiceContainer.swift     # DI container
    │   ├── ReminderManager.swift      # EventKit operations
    │   ├── ReminderManagerProtocol.swift
    │   └── TimeCalculator.swift       # Time calculations
    ├── Views/
    │   ├── MenuBarContentView.swift   # Menu bar UI
    │   ├── SprintDialogView.swift     # Main dialog
    │   └── ReminderSelectionModal.swift
    └── Utilities/
        └── AppConstants.swift
Tests/
└── NaloFocusTests/
    └── TimeCalculatorTests.swift
```

## Critical Implementation Details

### ⚠️ Swift 6 Concurrency Issues & Solutions

**Problem**: Actor isolation errors in ServiceContainer
```swift
// ❌ WRONG - Causes "main actor-isolated default value in nonisolated context"
lazy var reminderManager: ReminderManagerProtocol = ReminderManager()
```

**Solution**: Mark ServiceContainer or its properties with proper actor annotations
```swift
// ✅ CORRECT - Add @MainActor to class or nonisolated to properties
@MainActor
final class ServiceContainer { ... }
// OR
nonisolated lazy var reminderManager: ReminderManagerProtocol = ReminderManager()
```

**Problem**: EventKit callbacks with continuations
```swift
// ❌ WRONG - Can cause "value passed as strongly transferred parameter" error
continuation.resume(returning: reminders ?? [])
```

**Solution**: Ensure proper sendability
```swift
// ✅ CORRECT - Use proper async wrapper
return try await withCheckedThrowingContinuation { continuation in
    eventStore.fetchReminders(matching: predicate) { reminders in
        let safeReminders = reminders ?? []
        continuation.resume(returning: safeReminders)
    }
}
```

### EventKit Integration Patterns

**Permissions**: Always check before operations
```swift
// Required in Info.plist
NSRemindersUsageDescription: "NaloFocus needs access to update your reminders"

// Check permission before any EventKit operation
guard try await reminderManager.requestAccess() else {
    throw ReminderError.accessDenied
}
```

**Multiple Accounts**: The app handles iCloud, Exchange, and Local reminder accounts automatically via EventKit's default calendar selection.

### UI State Management Patterns

**ViewModel Pattern**: All ViewModels should be `@MainActor` annotated
```swift
@MainActor
final class SprintDialogViewModel: ObservableObject {
    @Published var tasks: [SprintTask] = []
    // ...
}
```

**Form Reset**: After sprint creation, reset all state to defaults
```swift
private func resetForm() {
    tasks = []
    selectedCount = 1
    showSuccessMessage = false
    // Reset all other properties
}
```

## Testing Best Practices

### Creating Mock Services
```swift
// Mock for testing without EventKit
final class MockReminderManager: ReminderManagerProtocol {
    var shouldFailAccess = false
    var mockReminders: [EKReminder] = []

    func requestAccess() async throws -> Bool {
        return !shouldFailAccess
    }

    func fetchReminders() async throws -> [EKReminder] {
        return mockReminders
    }
    // Implement other protocol methods...
}
```

### Testing ViewModels
```swift
@MainActor
final class SprintDialogViewModelTests: XCTestCase {
    func testSprintCreation() async throws {
        let mockManager = MockReminderManager()
        let viewModel = SprintDialogViewModel(reminderManager: mockManager)
        // Test logic...
    }
}
```

## Common Pitfalls to Avoid

1. **Don't use Xcode project commands** - This is a Swift Package, not an .xcodeproj. Use `swift` CLI only.
2. **Don't forget @MainActor** - ViewModels and UI-related code need proper actor annotation
3. **Don't skip permission checks** - Always verify EventKit access before operations
4. **Don't ignore build warnings** - Swift 6 concurrency warnings often become errors
5. **Don't modify EventKit objects directly** - Always use proper save/commit patterns
6. **Don't confuse DEBUG/RELEASE modes** - App behavior differs: window vs menu bar presentation

## Debugging Tips

```bash
# View detailed build errors
swift build -v

# Check Swift version (should be 6.0+)
swift --version

# List all available targets
swift package describe

# Clean everything when builds are acting strange
rm -rf .build/ .swiftpm/ Package.resolved
swift build

# Run in DEBUG mode (shows window, not menu bar)
swift run

# Test with single test case
swift test --filter TimeCalculatorTests/testGenerateTimeline
```

## Development Workflow Patterns

### DEBUG vs RELEASE Mode
The app uses compile-time flags to provide different UIs:
- **DEBUG**: Opens a regular window for easier UI testing and development
- **RELEASE**: Menu bar extra with modal window presentation

```swift
#if DEBUG
    WindowGroup { SprintDialogView() }  // Regular window
#else
    MenuBarExtra { ... }                // Menu bar
#endif
```

### Testing with Mock Services
All services implement protocols for testability:

```swift
// Production
let reminderManager: ReminderManagerProtocol = ReminderManager()

// Testing
let reminderManager: ReminderManagerProtocol = MockReminderManager()
```

## Key Files for Context

- **`PHASE_PLAN.md`**: Current development progress and upcoming tasks
- **`PRD.md`**: Product Requirements Document with full specifications
- **`docs/DECISIONS.md`**: Architectural decisions and rationale (ADRs)
- **`docs/RISKS.md`**: Known risks and mitigation strategies
- **`docs/DAILY_PROGRESS.md`**: Daily development updates and blockers
- **`Package.swift`**: SPM configuration with platform targets and build flags

## Next Steps When Starting Work

1. Check current build status: `swift build`
2. Review `PHASE_PLAN.md` for current sprint goals
3. Run tests to ensure baseline: `swift test`
4. Check for any new decisions in `docs/DECISIONS.md`
5. Look for blockers in latest `docs/DAILY_PROGRESS.md` entry