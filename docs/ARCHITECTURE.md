# NaloFocus Architecture

**Version**: 1.0.0-alpha
**Last Updated**: 2025-01-13
**Architecture Pattern**: MVVM with Protocol-Oriented Design

## Table of Contents

- [Overview](#overview)
- [Design Principles](#design-principles)
- [System Architecture](#system-architecture)
- [Component Layers](#component-layers)
- [Data Flow](#data-flow)
- [Concurrency Model](#concurrency-model)
- [Dependency Management](#dependency-management)
- [State Management](#state-management)
- [Testing Strategy](#testing-strategy)

---

## Overview

NaloFocus follows a **Model-View-ViewModel (MVVM)** architecture pattern with **Protocol-Oriented Design** principles. The application is built as a **Swift Package Manager executable** using native SwiftUI and EventKit frameworks with zero external dependencies.

### Key Architectural Characteristics

- **Stateless Design**: No persistence layer - each session starts fresh
- **Protocol-Oriented**: All services defined by protocols for testability
- **Dependency Injection**: ServiceContainer provides centralized DI
- **Actor Isolation**: Swift 6 concurrency with main actor enforcement
- **Reactive UI**: SwiftUI with @Published properties and Combine

---

## Design Principles

### SOLID Principles

#### Single Responsibility
Each component has one clear purpose:
- `ReminderManager` → EventKit integration only
- `TimeCalculator` → Time calculations only
- `SprintDialogViewModel` → Sprint dialog business logic only

#### Open/Closed
- Services implement protocols (open for extension)
- Core implementations are final (closed for modification)
- New functionality through new protocols/implementations

#### Liskov Substitution
- Protocol conformance ensures substitutability
- `ReminderManagerProtocol` can be swapped with mocks
- ViewModels work with any protocol-conforming service

#### Interface Segregation
- Focused protocols with minimal required methods
- `ReminderManagerProtocol` has 7 specific methods
- No bloated interfaces with unused methods

#### Dependency Inversion
- ViewModels depend on protocols, not concrete implementations
- ServiceContainer provides abstraction layer
- Easy to swap implementations for testing

---

### Additional Principles

#### DRY (Don't Repeat Yourself)
- Shared time calculations in `TimeCalculator`
- Common constants in `AppConstants`
- Reusable UI components (InsertTaskButton, TaskConfigurationRow)

#### KISS (Keep It Simple, Stupid)
- Straightforward MVVM without over-engineering
- No complex state machines or unnecessary abstractions
- Direct EventKit integration without wrapper frameworks

#### YAGNI (You Aren't Gonna Need It)
- No premature persistence layer
- No analytics or tracking infrastructure
- No complex plugin system or extensibility hooks

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          NaloFocusApp                           │
│                    (Application Entry Point)                    │
│                                                                 │
│  ┌──────────────────┐              ┌──────────────────┐        │
│  │  DEBUG Mode      │              │  RELEASE Mode    │        │
│  │  WindowGroup     │              │  MenuBarExtra    │        │
│  └──────────────────┘              └──────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Views Layer                             │
│                     (SwiftUI Views)                             │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              SprintDialogView (Main Dialog)              │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  InsertTaskButton │ TaskConfigurationRow          │  │  │
│  │  │  TimelineEntryRow │ ReminderSelectionButton       │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         ReminderSelectionModal (Picker Dialog)           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          MenuBarContentView (Menu Bar UI)                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      ViewModels Layer                           │
│                  (Business Logic)                               │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         SprintDialogViewModel (@MainActor)               │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  • loadReminders()                                │  │  │
│  │  │  • addTask() / insertTask() / removeTask()        │  │  │
│  │  │  • generateTimeline()                             │  │  │
│  │  │  • createSprint()                                 │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          AppStateCoordinator (@MainActor)                │  │
│  │  • showSprintDialog: Bool                                │  │
│  │  • activeDialogId: UUID?                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Services Layer                            │
│                  (Business Services)                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           ServiceContainer (@MainActor)                  │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  shared: ServiceContainer (Singleton)             │  │  │
│  │  │  reminderManager: ReminderManagerProtocol         │  │  │
│  │  │  timeCalculator: TimeCalculator                   │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │        ReminderManager: ReminderManagerProtocol          │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  • requestAccess()                                │  │  │
│  │  │  • fetchReminders()                               │  │  │
│  │  │  • updateReminderAlarm()                          │  │  │
│  │  │  • createBreakReminder()                          │  │  │
│  │  │  • updateRemindersForSprint()                     │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              TimeCalculator (Utility)                    │  │
│  │  • calculateEndTime() • formatDuration()                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Models Layer                            │
│                      (Data Models)                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │               SprintSession (Sendable)                   │  │
│  │  • tasks: [SprintTask]                                   │  │
│  │  • startTime: Date                                       │  │
│  │  • endTime: Date (computed)                              │  │
│  │  • totalDuration: TimeInterval (computed)                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          SprintTask (Identifiable, Sendable)             │  │
│  │  • id: UUID                                              │  │
│  │  • reminder: EKReminder?                                 │  │
│  │  • duration: TimeInterval                                │  │
│  │  • hasBreak: Bool                                        │  │
│  │  • breakDuration: TimeInterval                           │  │
│  │  • totalDuration: TimeInterval (computed)                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         TimelineEntry (Identifiable, Sendable)           │  │
│  │  • type: EntryType (.task | .break)                      │  │
│  │  • title: String                                         │  │
│  │  • startTime: Date                                       │  │
│  │  • duration: TimeInterval                                │  │
│  │  • calendarColor: NSColor?                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           ReminderCategory (Static Utility)              │  │
│  │  • categorize(_:) -> Category                            │  │
│  │  • sortReminders(_:) -> [EKReminder]                     │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      External Framework                         │
│                         EventKit                                │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  EKEventStore  │  EKReminder  │  EKCalendar  │  EKAlarm  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Layers

### Layer 1: Application Entry Point

**Component**: `NaloFocusApp.swift`

**Responsibilities**:
- Application lifecycle management
- Compile-time mode switching (DEBUG/RELEASE)
- ServiceContainer initialization
- Root view presentation

**DEBUG Mode Behavior**:
```swift
#if DEBUG
    WindowGroup {
        SprintDialogView()
            .environment(\.serviceContainer, ServiceContainer.shared)
    }
#endif
```
- Opens regular window for easier development
- Faster iteration and debugging
- Standard window controls

**RELEASE Mode Behavior**:
```swift
#if !DEBUG
    MenuBarExtra("NaloFocus", systemImage: "timer") {
        MenuBarContentView()
    }
    .menuBarExtraStyle(.window)
#endif
```
- Menu bar extra with system icon
- Window-style presentation (not popover)
- Production user experience

---

### Layer 2: Views

**Purpose**: SwiftUI declarative UI components
**Actor Isolation**: Implicitly `@MainActor`
**State Management**: `@Published`, `@State`, `@Binding`

#### Primary Views

##### SprintDialogView
**Responsibility**: Sprint configuration interface

**Key Features**:
- Inline task insertion with `InsertTaskButton`
- Task configuration rows with duration sliders
- Timeline preview display
- Reminder selection integration
- Calendar color indicators throughout

**Composition**:
```swift
VStack {
    taskCountSelector           // Task count display
    taskList {                  // Dynamic task rows
        InsertTaskButton        // Before first task
        ForEach(tasks) {
            TaskConfigurationRow
            InsertTaskButton    // After each task
        }
    }
    timelinePreview            // Preview of scheduled sprint
    actionButtons              // Start Sprint / Cancel
}
```

##### ReminderSelectionModal
**Responsibility**: Reminder picker interface

**Categorization**:
- Past Due (red badge)
- Today (orange badge)
- Tomorrow (yellow badge)
- Future (blue badge)
- No Due Date (gray badge)

**Features**:
- Search functionality
- Calendar color indicators
- Multi-account support

##### MenuBarContentView
**Responsibility**: Menu bar popover content

**Minimal UI**:
- "Create Sprint" button
- Quick access to settings
- State reset coordination

---

#### Reusable Components

##### InsertTaskButton
**Purpose**: Inline task insertion UI
**Design**: Dashed border with accent color
**Behavior**: Inserts task at specified index

##### TaskConfigurationRow
**Purpose**: Individual task configuration
**Features**:
- Numbered badge (1-9)
- Duration slider (5-90 min)
- Reminder selection button with calendar color
- Break toggle and duration
- Remove button

##### TimelineEntryRow
**Purpose**: Timeline entry display
**Features**:
- Calendar color bar (3px vertical)
- Time display (HH:mm)
- Duration display
- Title with truncation

---

### Layer 3: ViewModels

**Purpose**: Business logic and state management
**Pattern**: Observable objects with `@Published` properties
**Actor Isolation**: `@MainActor` enforced

#### SprintDialogViewModel

**State Management**:
```swift
@Published var sprintSession: SprintSession
@Published var taskCount: Int
@Published var availableReminders: [EKReminder]
@Published var timelineEntries: [TimelineEntry]
@Published var isLoading: Bool
@Published var errorMessage: String?
@Published var showSuccessMessage: Bool
```

**Business Logic Methods**:
- `loadReminders()` - Async reminder fetching
- `addTask()` - Append task to sprint
- `insertTask(at:)` - Insert task at position
- `removeTask(at:)` - Remove task from sprint
- `generateTimeline()` - Build preview timeline
- `createSprint()` - Execute sprint creation

**Dependency Injection**:
```swift
init(reminderManager: ReminderManagerProtocol = ServiceContainer.shared.reminderManager)
```
- Protocol-based injection for testability
- Default to singleton for production
- Easy mock injection for testing

---

#### AppStateCoordinator

**Purpose**: App-wide state coordination

**State**:
```swift
@Published var showSprintDialog: Bool
@Published var activeDialogId: UUID?
```

**Usage**: Coordinate dialog visibility across views

---

### Layer 4: Services

**Purpose**: Business logic and external integrations
**Pattern**: Protocol-oriented with DI
**Thread Safety**: `@MainActor` where needed

#### ServiceContainer

**Pattern**: Singleton with lazy initialization

**Structure**:
```swift
@MainActor
final class ServiceContainer {
    static let shared = ServiceContainer()

    nonisolated lazy var reminderManager: ReminderManagerProtocol = ReminderManager()
    nonisolated lazy var timeCalculator: TimeCalculator = TimeCalculator()
}
```

**SwiftUI Integration**:
```swift
// Injection
.environment(\.serviceContainer, ServiceContainer.shared)

// Access
@Environment(\.serviceContainer) var services
```

---

#### ReminderManager

**Protocol**: `ReminderManagerProtocol`
**Actor**: `@MainActor`
**External Framework**: EventKit

**Core Responsibilities**:
1. **Permission Management**
   - Request Reminders access
   - Handle macOS 14.0+ API changes

2. **Reminder Operations**
   - Fetch incomplete reminders
   - Categorize by due date
   - Update reminder alarms
   - Set due date components

3. **Sprint Execution**
   - Sequential reminder updates
   - Break reminder creation
   - "Breaks" calendar management

4. **Concurrency Workarounds**
   - `UncheckedSendableBox` for EventKit types
   - Async/await wrappers for completion handlers

**EventKit Integration Pattern**:
```swift
// Async wrapper for completion-based API
func fetchReminders() async throws -> [EKReminder] {
    try await withCheckedThrowingContinuation { continuation in
        eventStore.fetchReminders(matching: predicate) { reminders in
            let boxed = UncheckedSendableBox(value: reminders ?? [])
            continuation.resume(returning: boxed.value)
        }
    }
}
```

---

#### TimeCalculator

**Purpose**: Time calculation utilities
**Pattern**: Stateless utility class

**Methods**:
- `calculateEndTime(start:duration:)` - Date arithmetic
- `formatDuration(_:)` - Human-readable formatting
- `validateDuration(_:)` - Range validation

---

### Layer 5: Models

**Purpose**: Data structures and domain models
**Conformance**: `Sendable` for concurrency safety
**Pattern**: Value types (structs) with computed properties

#### SprintSession

**Purpose**: Sprint configuration container

**Properties**:
- `tasks: [SprintTask]` - Mutable task array
- `startTime: Date` - Sprint start time

**Computed**:
- `endTime: Date` - Calculated from all task durations
- `totalDuration: TimeInterval` - Sum of all task durations

---

#### SprintTask

**Purpose**: Individual task with configuration

**Properties**:
- `id: UUID` - Unique identifier
- `reminder: EKReminder?` - Associated reminder
- `duration: TimeInterval` - Task duration (5-90 min)
- `hasBreak: Bool` - Break inclusion flag
- `breakDuration: TimeInterval` - Break duration

**Computed**:
- `totalDuration: TimeInterval` - Task + break duration

**Validation**:
- Duration: 300-5400 seconds (5-90 minutes)
- Reminder: Must be non-nil for sprint creation

---

#### TimelineEntry

**Purpose**: Timeline visualization data

**Properties**:
- `type: EntryType` - Task or break discriminator
- `title: String` - Display title
- `startTime: Date` - Entry start time
- `duration: TimeInterval` - Entry duration
- `calendarColor: NSColor?` - Calendar color for UI

**Computed**:
- `endTime: Date` - Calculated end time
- `formattedStartTime: String` - Time string (HH:mm)
- `formattedDuration: String` - Duration string (X min)

---

## Data Flow

### Sprint Creation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User Opens Sprint Dialog                                    │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. SprintDialogViewModel.loadReminders()                       │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  await reminderManager.requestAccess()                │  │
│    │  → Request Reminders permission                       │  │
│    │                                                        │  │
│    │  await reminderManager.fetchReminders()               │  │
│    │  → Fetch all incomplete reminders                     │  │
│    │                                                        │  │
│    │  Update availableReminders @Published property        │  │
│    │  → Triggers UI update with reminder list              │  │
│    └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. User Configures Sprint                                      │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  Insert tasks (insertTask(at:))                       │  │
│    │  Select reminders for each task                       │  │
│    │  Adjust durations (slider binding)                    │  │
│    │  Configure breaks (toggle + duration)                 │  │
│    │                                                        │  │
│    │  Each change triggers:                                │  │
│    │  → sprintSession update (@Published)                  │  │
│    │  → generateTimeline() call                            │  │
│    │  → timelineEntries update                             │  │
│    │  → UI preview refresh                                 │  │
│    └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. User Clicks "Start Sprint"                                  │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  SprintDialogViewModel.createSprint()                 │  │
│    │                                                        │  │
│    │  Validation:                                          │  │
│    │  → All tasks have reminders?                          │  │
│    │  → Durations valid (5-90 min)?                        │  │
│    │                                                        │  │
│    │  await reminderManager.updateRemindersForSprint(...)  │  │
│    └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. ReminderManager.updateRemindersForSprint()                  │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  var currentTime = session.startTime                  │  │
│    │                                                        │  │
│    │  For each task:                                       │  │
│    │    1. updateReminderAlarm(task.reminder, at: time)    │  │
│    │       → Set alarm to absolute date                    │  │
│    │       → Set due date components                       │  │
│    │       → Save to EventKit (commit: true)               │  │
│    │                                                        │  │
│    │    2. Advance time by task.duration                   │  │
│    │                                                        │  │
│    │    3. If task.hasBreak:                               │  │
│    │       → createBreakReminder(at: time, duration: X)    │  │
│    │       → Find/create "Breaks" calendar                 │  │
│    │       → Create reminder "Break - X min"               │  │
│    │       → Save to EventKit                              │  │
│    │       → Advance time by breakDuration                 │  │
│    │                                                        │  │
│    │  All operations sequential (not parallel)             │  │
│    └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. Success Handling                                            │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  showSuccessMessage = true (@Published)               │  │
│    │  → UI shows success notification                      │  │
│    │                                                        │  │
│    │  resetForm()                                          │  │
│    │  → Clear all tasks                                    │  │
│    │  → Reset to initial state                             │  │
│    │  → Ready for next sprint                              │  │
│    └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

### State Update Flow

```
User Action (View)
       │
       ▼
State Change (@Published property in ViewModel)
       │
       ├─→ Combine Publisher emits objectWillChange
       │
       ▼
SwiftUI View Re-evaluation
       │
       ├─→ Body recomputed
       ├─→ Diff calculated
       │
       ▼
UI Update (only changed components)
```

**Example**:
```swift
// User adjusts duration slider
Slider(value: $task.duration, in: 300...5400)

// Binding updates task.duration
task.duration = newValue

// Published property triggers
viewModel.sprintSession.objectWillChange.send()

// generateTimeline() called (didSet observer)
viewModel.generateTimeline()

// timelineEntries updated (@Published)
viewModel.timelineEntries = [...]

// SwiftUI re-renders timeline preview
TimelinePreview(entries: viewModel.timelineEntries)
```

---

## Concurrency Model

### Swift 6 Concurrency

**Actor Isolation Strategy**:
```
@MainActor Components:
├── All ViewModels (UI state management)
├── All Services (EventKit requires main thread)
├── ServiceContainer (DI container)
└── Protocol definitions (ReminderManagerProtocol)

Non-isolated:
├── Models (Sendable value types)
├── Utilities (stateless functions)
└── Constants (static values)
```

---

### Main Actor Enforcement

**Example: ReminderManager**
```swift
@MainActor
protocol ReminderManagerProtocol {
    func requestAccess() async throws -> Bool
    func fetchReminders() async throws -> [EKReminder]
    // All methods implicitly @MainActor
}

@MainActor
final class ReminderManager: ReminderManagerProtocol {
    private let eventStore = EKEventStore() // Main thread only

    func fetchReminders() async throws -> [EKReminder] {
        // Automatically runs on main actor
        // EventKit operations safe
    }
}
```

---

### Sendable Conformance

**Models**:
```swift
struct SprintSession: Sendable {
    var tasks: [SprintTask]  // SprintTask is also Sendable
    var startTime: Date      // Date is Sendable
}

struct SprintTask: Identifiable, @unchecked Sendable {
    let id = UUID()          // UUID is Sendable
    var reminder: EKReminder?  // @unchecked needed for EKReminder
    var duration: TimeInterval // Double is Sendable
}
```

**Workaround for EventKit**:
```swift
struct UncheckedSendableBox<T>: @unchecked Sendable {
    let value: T
}

// Usage
let boxed = UncheckedSendableBox(value: reminders ?? [])
continuation.resume(returning: boxed.value)
```

---

### Async/Await Pattern

**Wrapping Completion Handlers**:
```swift
// EventKit completion-based API
eventStore.requestAccess(to: .reminder) { granted, error in
    // Callback on arbitrary queue
}

// Wrapped in async/await
func requestAccess() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
        eventStore.requestAccess(to: .reminder) { granted, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: granted)
            }
        }
    }
}
```

---

## Dependency Management

### Dependency Injection Pattern

```
ServiceContainer (Singleton)
       │
       ├─→ reminderManager: ReminderManagerProtocol
       │   └─→ ReminderManager (concrete implementation)
       │
       ├─→ timeCalculator: TimeCalculator
       │   └─→ TimeCalculator (stateless utility)
       │
       └─→ Injected into SwiftUI Environment
           └─→ Available to all views via @Environment
```

---

### Production Flow

```swift
// 1. App startup
@main
struct NaloFocusApp: App {
    var body: some Scene {
        WindowGroup {
            SprintDialogView()
                .environment(\.serviceContainer, ServiceContainer.shared)
        }
    }
}

// 2. View access
struct SprintDialogView: View {
    @StateObject private var viewModel = SprintDialogViewModel()

    init() {
        // ViewModel uses default ServiceContainer.shared
        _viewModel = StateObject(wrappedValue: SprintDialogViewModel())
    }
}

// 3. ViewModel dependency
@MainActor
final class SprintDialogViewModel: ObservableObject {
    private let reminderManager: ReminderManagerProtocol

    init(reminderManager: ReminderManagerProtocol = ServiceContainer.shared.reminderManager) {
        self.reminderManager = reminderManager
    }
}
```

---

### Testing Flow

```swift
// 1. Create mock
@MainActor
final class MockReminderManager: ReminderManagerProtocol {
    var mockReminders: [EKReminder] = []

    func fetchReminders() async throws -> [EKReminder] {
        return mockReminders
    }
}

// 2. Inject mock
@MainActor
final class ViewModelTests: XCTestCase {
    func testLoadReminders() async {
        let mock = MockReminderManager()
        mock.mockReminders = [reminder1, reminder2]

        let viewModel = SprintDialogViewModel(reminderManager: mock)

        await viewModel.loadReminders()

        XCTAssertEqual(viewModel.availableReminders.count, 2)
    }
}
```

---

## State Management

### State Classification

#### View State (@State)
**Scope**: Single view
**Lifecycle**: View lifetime
**Example**: `@State private var showModal = false`

#### Shared State (@Published)
**Scope**: ViewModel → Multiple views
**Lifecycle**: ViewModel lifetime
**Example**: `@Published var tasks: [SprintTask]`

#### Environment State (@Environment)
**Scope**: App-wide
**Lifecycle**: Application lifetime
**Example**: `@Environment(\.serviceContainer) var services`

---

### State Flow Pattern

```
View Layer
  │
  ├─ @State (local UI state)
  │  └─ Toggle, temporary flags
  │
  ├─ @StateObject (owns ViewModel)
  │  └─ Creates and owns ViewModel
  │
  └─ @ObservedObject/@Published (reacts to ViewModel)
     └─ Updates on @Published changes

ViewModel Layer
  │
  ├─ @Published (observable state)
  │  └─ Triggers view updates
  │
  └─ Private properties (internal state)
     └─ Services, dependencies

Services Layer
  │
  └─ Stateless operations
     └─ EventKit, calculations
```

---

## Testing Strategy

### Unit Testing Architecture

```
Test Target (NaloFocusTests)
  │
  ├─ Protocol Mocks
  │  └─ MockReminderManager: ReminderManagerProtocol
  │
  ├─ ViewModel Tests
  │  ├─ SprintDialogViewModelTests
  │  └─ Inject mocks via constructor
  │
  ├─ Service Tests
  │  └─ TimeCalculatorTests (stateless functions)
  │
  └─ Model Tests
     ├─ SprintSessionTests
     └─ SprintTaskTests
```

---

### Testability Design Patterns

#### Protocol-Oriented Design
```swift
// Protocol allows substitution
protocol ReminderManagerProtocol {
    func fetchReminders() async throws -> [EKReminder]
}

// Production implementation
final class ReminderManager: ReminderManagerProtocol {
    func fetchReminders() async throws -> [EKReminder] {
        // Real EventKit calls
    }
}

// Test mock
final class MockReminderManager: ReminderManagerProtocol {
    var mockReminders: [EKReminder] = []

    func fetchReminders() async throws -> [EKReminder] {
        return mockReminders
    }
}
```

---

#### Dependency Injection
```swift
// ViewModel accepts protocol
init(reminderManager: ReminderManagerProtocol = ServiceContainer.shared.reminderManager)

// Production: uses default
let viewModel = SprintDialogViewModel()

// Testing: inject mock
let mock = MockReminderManager()
let viewModel = SprintDialogViewModel(reminderManager: mock)
```

---

### Test Coverage Strategy

**High Priority** (Must have tests):
- Core business logic (TimeCalculator)
- ViewModel operations (add/remove tasks)
- Model computed properties (totalDuration)
- Service protocol compliance

**Medium Priority** (Should have tests):
- Timeline generation logic
- Reminder categorization
- Validation logic

**Low Priority** (Nice to have):
- UI component logic
- Formatting functions
- Constants validation

---

## Cross-References

- [API Reference](API_REFERENCE.md) - Detailed API documentation
- [Project Index](PROJECT_INDEX.md) - Complete project structure
- [Testing Guide](../TESTING_GUIDE.md) - Testing procedures
- [Decisions](DECISIONS.md) - Architectural decision records

---

**Navigation**: [Top](#nalofocus-architecture) | [Principles](#design-principles) | [Layers](#component-layers) | [Data Flow](#data-flow)
