# NaloFocus Project Index

**Version**: 1.0.0-alpha
**Last Updated**: 2025-01-13
**Type**: Swift Package Manager Executable

## Quick Navigation

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Documentation Map](#documentation-map)
- [Development Workflows](#development-workflows)
- [API Reference](#api-reference)

---

## Project Overview

NaloFocus is a macOS menu bar application that transforms unscheduled Reminders into time-blocked work sprints. Built as a **Swift Package Manager executable** (not Xcode project), using SwiftUI for UI and EventKit for native Reminders integration.

### Key Characteristics
- **Platform**: macOS 15.0+ (Sequoia)
- **Language**: Swift 6.0
- **Architecture**: MVVM with Protocol-Oriented Design
- **Build System**: Swift Package Manager
- **Dependencies**: None (pure Swift/SwiftUI/EventKit)
- **State Management**: Stateless (no persistence)

---

## Project Structure

```
NaloFocus/
├── Package.swift                          # SPM package definition
├── Sources/
│   ├── main.swift                         # Entry point
│   └── NaloFocus/
│       ├── NaloFocusApp.swift            # App definition with MenuBarExtra
│       ├── Models/                        # Data models and view models
│       │   ├── AppStateCoordinator.swift  # App-wide state coordination
│       │   ├── ReminderCategory.swift     # Reminder categorization logic
│       │   ├── SprintDialogViewModel.swift # Sprint dialog business logic
│       │   ├── SprintSession.swift        # Sprint container model
│       │   ├── SprintTask.swift           # Individual task model
│       │   └── TimelineEntry.swift        # Timeline visualization data
│       ├── Services/                      # Business logic services
│       │   ├── ReminderManager.swift      # EventKit integration
│       │   ├── ReminderManagerProtocol.swift # Service protocol
│       │   ├── ServiceContainer.swift     # Dependency injection
│       │   └── TimeCalculator.swift       # Time calculation utilities
│       ├── Views/                         # SwiftUI views
│       │   ├── MenuBarContentView.swift   # Main menu bar view
│       │   ├── ReminderSelectionModal.swift # Reminder picker modal
│       │   └── SprintDialogView.swift     # Sprint configuration dialog
│       ├── Utilities/                     # Helper utilities
│       │   └── AppConstants.swift         # App-wide constants
│       └── Resources/                     # Asset catalog, Info.plist
├── Tests/
│   ├── NaloFocusTests/                   # Unit tests
│   │   └── TimeCalculatorTests.swift     # Time calculation tests
│   ├── test-core.swift                   # Core test functionality
│   └── cli-interface.swift               # CLI test interface
├── docs/                                  # Documentation
│   ├── PROJECT_INDEX.md                  # This file
│   ├── API_REFERENCE.md                  # API documentation
│   ├── ARCHITECTURE.md                   # System architecture
│   ├── DECISIONS.md                      # Architectural decisions
│   ├── RISKS.md                          # Risk register
│   ├── DAILY_PROGRESS.md                 # Development log
│   ├── CALENDAR_COLORS_FIX.md           # Calendar color implementation
│   ├── TASK_INSERTION_IMPLEMENTATION.md  # Task insertion UI pattern
│   ├── TASK_SYMBOLS_IMPLEMENTATION.md    # Visual symbol system
│   └── UI_IMPROVEMENTS*.md               # UI enhancement records
├── CLAUDE.md                             # Claude Code guidance
├── PRD.md                                # Product requirements
├── README.md                             # Project introduction
├── PHASE_PLAN.md                         # Development roadmap
└── TESTING_GUIDE.md                      # Testing documentation
```

---

## Core Components

### 1. Application Layer

#### `NaloFocusApp.swift`
- **Role**: Application entry point and lifecycle
- **Key Features**: MenuBarExtra integration, app state management
- **Dependencies**: ServiceContainer, MenuBarContentView
- **Reference**: [Source](../Sources/NaloFocus/NaloFocusApp.swift)

### 2. Models Layer

#### `SprintSession.swift`
**Purpose**: Container for sprint configuration and execution
**Key Properties**:
- `tasks: [SprintTask]` - Collection of sprint tasks
- `startTime: Date` - Sprint start time
- `useBreaks: Bool` - Break inclusion flag

**Key Methods**:
- `totalDuration() -> TimeInterval` - Calculate total sprint duration
- `validate() -> Bool` - Validate sprint configuration

**Reference**: [Source](../Sources/NaloFocus/Models/SprintSession.swift)

---

#### `SprintTask.swift`
**Purpose**: Individual task within a sprint
**Key Properties**:
- `id: UUID` - Unique identifier
- `reminder: EKReminder?` - Associated reminder
- `duration: TimeInterval` - Task duration in seconds
- `hasBreak: Bool` - Break after task flag
- `breakDuration: TimeInterval` - Break duration

**Key Methods**:
- `totalDuration` - Computed property for task + break duration

**Reference**: [Source](../Sources/NaloFocus/Models/SprintTask.swift)

---

#### `SprintDialogViewModel.swift`
**Purpose**: Business logic for sprint dialog UI
**Actor**: `@MainActor` - UI thread isolation
**Key Properties**:
- `sprintSession: SprintSession` - Current sprint configuration
- `taskCount: Int` - Number of tasks (1-9)
- `availableReminders: [EKReminder]` - Fetchable reminders
- `timelineEntries: [TimelineEntry]` - Preview timeline

**Key Methods**:
- `loadReminders() async` - Fetch reminders from EventKit
- `addTask()` - Add task to sprint
- `insertTask(at: Int)` - Insert task at specific index
- `removeTask(at: Int)` - Remove task from sprint
- `createSprint() async` - Execute sprint creation
- `generateTimeline()` - Build preview timeline

**Reference**: [Source](../Sources/NaloFocus/Models/SprintDialogViewModel.swift)

---

#### `TimelineEntry.swift`
**Purpose**: Visualization data for sprint timeline
**Key Properties**:
- `id: UUID` - Unique identifier
- `type: EntryType` - Task or break
- `title: String` - Display title
- `startTime: Date` - Entry start time
- `duration: TimeInterval` - Entry duration
- `calendarColor: NSColor?` - Calendar color for visual indication

**Reference**: [Source](../Sources/NaloFocus/Models/TimelineEntry.swift)

---

#### `ReminderCategory.swift`
**Purpose**: Categorization logic for reminders
**Key Methods**:
- `categorize(_ reminder: EKReminder) -> Category` - Categorize reminder by due date
- `sortReminders(_ reminders: [EKReminder]) -> [EKReminder]` - Sort by category priority

**Reference**: [Source](../Sources/NaloFocus/Models/ReminderCategory.swift)

---

#### `AppStateCoordinator.swift`
**Purpose**: App-wide state coordination
**Key Responsibilities**:
- Dialog visibility management
- Navigation state coordination
- Session lifecycle management

**Reference**: [Source](../Sources/NaloFocus/Models/AppStateCoordinator.swift)

---

### 3. Services Layer

#### `ReminderManager.swift`
**Purpose**: EventKit integration and reminder operations
**Protocol**: Conforms to `ReminderManagerProtocol`
**Key Methods**:
- `requestAccess() async throws -> Bool` - Request Reminders permission
- `fetchReminders() async throws -> [EKReminder]` - Fetch incomplete reminders
- `updateReminder(_ reminder: EKReminder, dueDate: Date) async throws` - Update reminder due date
- `createBreakReminder(title: String, dueDate: Date) async throws -> EKReminder` - Create break reminder
- `findOrCreateBreaksList() async throws -> EKCalendar` - Get/create Breaks calendar

**EventKit Integration**:
- Uses `EKEventStore` for calendar access
- Handles multiple account types (iCloud, Exchange, Local)
- Creates separate "Breaks" calendar to avoid clutter

**Reference**: [Source](../Sources/NaloFocus/Services/ReminderManager.swift)

---

#### `TimeCalculator.swift`
**Purpose**: Time calculation utilities for sprint scheduling
**Key Methods**:
- `calculateEndTime(start: Date, duration: TimeInterval) -> Date` - Calculate end time
- `formatDuration(_ duration: TimeInterval) -> String` - Format duration for display
- `validateDuration(_ duration: TimeInterval) -> Bool` - Validate duration constraints

**Reference**: [Source](../Sources/NaloFocus/Services/TimeCalculator.swift)

---

#### `ServiceContainer.swift`
**Purpose**: Dependency injection container
**Pattern**: Singleton with lazy initialization
**Key Properties**:
- `shared: ServiceContainer` - Singleton instance
- `reminderManager: ReminderManagerProtocol` - Reminder service
- `timeCalculator: TimeCalculator` - Time calculation service

**SwiftUI Integration**: Injected via `.environment()` modifier

**Reference**: [Source](../Sources/NaloFocus/Services/ServiceContainer.swift)

---

### 4. Views Layer

#### `MenuBarContentView.swift`
**Purpose**: Main menu bar popover view
**Key Features**:
- Sprint dialog presentation
- Quick access controls
- State reset after sprint creation

**Reference**: [Source](../Sources/NaloFocus/Views/MenuBarContentView.swift)

---

#### `SprintDialogView.swift`
**Purpose**: Sprint configuration dialog with task management
**Key Features**:
- Inline task insertion with `InsertTaskButton` component
- Task configuration with duration sliders
- Reminder selection integration
- Break configuration
- Timeline preview
- Calendar color indicators throughout UI

**UI Components**:
- `InsertTaskButton` - Dashed-border button for task insertion at any position
- `TaskConfigurationRow` - Individual task configuration with calendar color bar
- `TimelineEntryRow` - Timeline entry display with calendar color
- Reminder selection with calendar color indicators

**Reference**: [Source](../Sources/NaloFocus/Views/SprintDialogView.swift)
**Implementation Docs**: [Task Insertion](TASK_INSERTION_IMPLEMENTATION.md), [Calendar Colors](CALENDAR_COLORS_FIX.md)

---

#### `ReminderSelectionModal.swift`
**Purpose**: Modal dialog for selecting reminders
**Key Features**:
- Categorized reminder display (Past Due, Today, Tomorrow, Future, No Due Date)
- Search functionality
- Calendar color indicators
- Multi-account support

**Reference**: [Source](../Sources/NaloFocus/Views/ReminderSelectionModal.swift)

---

### 5. Utilities Layer

#### `AppConstants.swift`
**Purpose**: App-wide constant definitions
**Key Constants**:
- Duration limits (min: 5 min, max: 90 min)
- Task count limits (1-9)
- Default values (task: 25 min, break: 5 min)
- UI constants

**Reference**: [Source](../Sources/NaloFocus/Utilities/AppConstants.swift)

---

## Documentation Map

### Product & Planning
| Document | Purpose | Audience |
|----------|---------|----------|
| [README.md](../README.md) | Project introduction and setup | All users |
| [PRD.md](../PRD.md) | Product requirements specification | Product/Dev team |
| [PHASE_PLAN.md](../PHASE_PLAN.md) | Development roadmap and progress | Dev team |

### Development & Architecture
| Document | Purpose | Audience |
|----------|---------|----------|
| [CLAUDE.md](../CLAUDE.md) | Claude Code integration guide | AI-assisted development |
| [DECISIONS.md](DECISIONS.md) | Architectural decision records | Dev team |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture overview | Dev team |
| [API_REFERENCE.md](API_REFERENCE.md) | API documentation | Developers |

### Implementation & Features
| Document | Purpose | Audience |
|----------|---------|----------|
| [TASK_INSERTION_IMPLEMENTATION.md](TASK_INSERTION_IMPLEMENTATION.md) | Task insertion UI pattern | Developers |
| [CALENDAR_COLORS_FIX.md](CALENDAR_COLORS_FIX.md) | Calendar color integration | Developers |
| [TASK_SYMBOLS_IMPLEMENTATION.md](TASK_SYMBOLS_IMPLEMENTATION.md) | Visual symbol system | Developers |
| [UI_IMPROVEMENTS*.md](UI_IMPROVEMENTS.md) | UI enhancement records | Dev team |

### Testing & Quality
| Document | Purpose | Audience |
|----------|---------|----------|
| [TESTING_GUIDE.md](../TESTING_GUIDE.md) | Testing strategies and procedures | Dev team |
| [LINT_REPORT.md](LINT_REPORT.md) | Code quality analysis | Dev team |

### Project Management
| Document | Purpose | Audience |
|----------|---------|----------|
| [DAILY_PROGRESS.md](DAILY_PROGRESS.md) | Daily development log | Dev team |
| [RISKS.md](RISKS.md) | Risk register and mitigations | Dev/PM team |

---

## Development Workflows

### Building and Running

```bash
# Build the application
swift build

# Run the application
swift run NaloFocus

# Build for release
swift build -c release

# Clean build artifacts
swift package clean
rm -rf .build/
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
```

### Common Tasks

#### Fix Build Errors
```bash
# Clean all build artifacts
swift package clean
rm -rf .build/

# Reset package dependencies
swift package reset

# Update dependencies
swift package update
```

#### Code Quality
```bash
# Run SwiftLint (if configured)
swiftlint

# Format code
swift-format -i Sources/
```

---

## API Reference

See [API_REFERENCE.md](API_REFERENCE.md) for detailed API documentation including:
- Protocol definitions
- Service interfaces
- Model schemas
- View component APIs

---

## Cross-References

### Related Documents
- Architecture deep-dive → [ARCHITECTURE.md](ARCHITECTURE.md)
- API documentation → [API_REFERENCE.md](API_REFERENCE.md)
- Testing procedures → [TESTING_GUIDE.md](../TESTING_GUIDE.md)
- Development roadmap → [PHASE_PLAN.md](../PHASE_PLAN.md)

### Key Implementation Patterns
- Dependency Injection → [ServiceContainer.swift](../Sources/NaloFocus/Services/ServiceContainer.swift)
- EventKit Integration → [ReminderManager.swift](../Sources/NaloFocus/Services/ReminderManager.swift)
- MVVM Pattern → [SprintDialogViewModel.swift](../Sources/NaloFocus/Models/SprintDialogViewModel.swift)
- UI Component Design → [SprintDialogView.swift](../Sources/NaloFocus/Views/SprintDialogView.swift)

---

## Version History

### v1.0.0-alpha (Current)
- Initial project structure
- Core sprint functionality
- Menu bar integration
- EventKit integration
- Timeline preview
- Task insertion UI
- Calendar color indicators

---

**Navigation**: [Top](#nalofocus-project-index) | [Structure](#project-structure) | [Components](#core-components) | [Documentation](#documentation-map)
