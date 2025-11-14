# NaloFocus API Reference

**Version**: 1.0.0-alpha
**Last Updated**: 2025-01-13
**Swift Version**: 6.0+

## Table of Contents

- [Services Layer](#services-layer)
  - [ReminderManager](#remindermanager)
  - [TimeCalculator](#timecalculator)
  - [ServiceContainer](#servicecontainer)
- [Models Layer](#models-layer)
  - [SprintSession](#sprintsession)
  - [SprintTask](#sprinttask)
  - [TimelineEntry](#timelineentry)
  - [ReminderCategory](#remindercategory)
- [ViewModels Layer](#viewmodels-layer)
  - [SprintDialogViewModel](#sprintdialogviewmodel)
  - [AppStateCoordinator](#appstatecoordinator)
- [Protocols](#protocols)
  - [ReminderManagerProtocol](#remindermanagerprotocol)
- [Type Definitions](#type-definitions)

---

## Services Layer

### ReminderManager

**File**: `Sources/NaloFocus/Services/ReminderManager.swift`
**Conforms To**: `ReminderManagerProtocol`
**Thread Safety**: `@MainActor` - Must be used on main thread

Implementation of EventKit reminder management for sprint scheduling operations.

#### Properties

##### `eventStore: EKEventStore`
```swift
private let eventStore: EKEventStore
```
**Description**: EventKit event store for calendar operations
**Access**: Private
**Thread Safety**: Main actor isolated

##### `breaksCalendar: EKCalendar?`
```swift
private var breaksCalendar: EKCalendar?
```
**Description**: Cached reference to "Breaks" reminder list
**Access**: Private
**Lifecycle**: Lazy initialized on first break creation

---

#### Methods

##### `requestAccess()`
```swift
func requestAccess() async throws -> Bool
```
**Description**: Request permission to access Reminders app
**Returns**: `Bool` - `true` if access granted, `false` otherwise
**Throws**: EventKit authorization errors
**Thread Safety**: Main actor isolated

**Implementation Notes**:
- Uses `requestFullAccessToReminders()` on macOS 14.0+
- Falls back to `requestAccess(to:)` for older versions
- Wraps completion handler in async/await continuation

**Usage Example**:
```swift
let manager = ReminderManager()
let granted = try await manager.requestAccess()
guard granted else {
    throw ReminderError.accessDenied
}
```

---

##### `fetchReminders()`
```swift
func fetchReminders() async throws -> [EKReminder]
```
**Description**: Fetch all incomplete reminders from all calendar sources
**Returns**: `[EKReminder]` - Array of incomplete reminders
**Throws**: EventKit fetch errors
**Thread Safety**: Main actor isolated

**Implementation Notes**:
- Fetches from all reminder calendars (iCloud, Exchange, Local)
- Filters to incomplete reminders only
- Uses `UncheckedSendableBox` to work around EventKit's lack of Sendable conformance

**Usage Example**:
```swift
let reminders = try await manager.fetchReminders()
print("Found \(reminders.count) incomplete reminders")
```

---

##### `categorizeReminders(_:)`
```swift
func categorizeReminders(_ reminders: [EKReminder]) -> CategorizedReminders
```
**Description**: Categorize reminders by due date status
**Parameters**:
- `reminders`: Array of reminders to categorize

**Returns**: `CategorizedReminders` struct with categorized arrays
**Thread Safety**: Main actor isolated

**Categories**:
- **Past Due**: Due date before current time
- **Scheduled**: Due date in the future
- **No Time Set**: No due date components

**Sorting**:
- Past Due & Scheduled: Sorted by due date (earliest first)
- No Time Set: Sorted alphabetically by title

**Usage Example**:
```swift
let categorized = manager.categorizeReminders(allReminders)
print("Past due: \(categorized.pastDue.count)")
print("Scheduled: \(categorized.scheduled.count)")
print("No time: \(categorized.noTimeSet.count)")
```

---

##### `updateReminderAlarm(_:at:)`
```swift
func updateReminderAlarm(_ reminder: EKReminder, at date: Date) async throws
```
**Description**: Update a reminder's alarm and due date
**Parameters**:
- `reminder`: EKReminder to update
- `date`: New alarm date and time

**Throws**: EventKit save errors
**Thread Safety**: Main actor isolated

**Side Effects**:
- Replaces all existing alarms with single absolute date alarm
- Updates due date components to match alarm time
- Immediately commits change to EventKit store

**Usage Example**:
```swift
let startTime = Date()
try await manager.updateReminderAlarm(reminder, at: startTime)
```

---

##### `createBreakReminder(at:duration:)`
```swift
func createBreakReminder(at date: Date, duration: TimeInterval) async throws -> EKReminder
```
**Description**: Create a new break reminder in the "Breaks" calendar
**Parameters**:
- `date`: Break start time
- `duration`: Break duration in seconds

**Returns**: `EKReminder` - Newly created break reminder
**Throws**: EventKit creation/save errors
**Thread Safety**: Main actor isolated

**Break Reminder Format**:
- **Title**: "Break - X min" (e.g., "Break - 5 min")
- **Calendar**: "Breaks" list (auto-created if needed)
- **Alarm**: Absolute date at break start time
- **Due Date**: Same as alarm time

**Usage Example**:
```swift
let breakTime = Date().addingTimeInterval(25 * 60) // 25 min from now
let breakReminder = try await manager.createBreakReminder(
    at: breakTime,
    duration: 5 * 60
)
```

---

##### `findOrCreateBreaksList()`
```swift
func findOrCreateBreaksList() async throws -> EKCalendar
```
**Description**: Find existing "Breaks" calendar or create new one
**Returns**: `EKCalendar` - The "Breaks" reminder list
**Throws**: EventKit creation/save errors
**Thread Safety**: Main actor isolated

**Behavior**:
1. Return cached calendar if available
2. Search all calendars for "Breaks" list
3. Create new "Breaks" calendar if not found
4. Use default reminder calendar source
5. Cache result for future calls

**Usage Example**:
```swift
let breaksCalendar = try await manager.findOrCreateBreaksList()
print("Using breaks list: \(breaksCalendar.title)")
```

---

##### `updateRemindersForSprint(_:)`
```swift
func updateRemindersForSprint(_ session: SprintSession) async throws
```
**Description**: Update all reminders in a sprint session sequentially
**Parameters**:
- `session`: Sprint session containing tasks and start time

**Throws**: EventKit update/creation errors
**Thread Safety**: Main actor isolated

**Algorithm**:
1. Start at session start time
2. For each task:
   - Update task reminder alarm to current time
   - Advance time by task duration
   - Create break reminder if task has break
   - Advance time by break duration
3. Process tasks sequentially (not parallel)

**Usage Example**:
```swift
var session = SprintSession()
session.startTime = Date()
session.tasks = [task1, task2, task3]

try await manager.updateRemindersForSprint(session)
```

---

### TimeCalculator

**File**: `Sources/NaloFocus/Services/TimeCalculator.swift`

Time calculation utilities for sprint scheduling and formatting.

#### Methods

##### `calculateEndTime(start:duration:)`
```swift
func calculateEndTime(start: Date, duration: TimeInterval) -> Date
```
**Description**: Calculate end time from start time and duration
**Parameters**:
- `start`: Starting date/time
- `duration`: Duration in seconds

**Returns**: `Date` - Calculated end time

**Usage Example**:
```swift
let calculator = TimeCalculator()
let endTime = calculator.calculateEndTime(
    start: Date(),
    duration: 25 * 60 // 25 minutes
)
```

---

##### `formatDuration(_:)`
```swift
func formatDuration(_ duration: TimeInterval) -> String
```
**Description**: Format duration in seconds to human-readable string
**Parameters**:
- `duration`: Time interval in seconds

**Returns**: `String` - Formatted duration (e.g., "25 min", "1h 30m")

**Format Rules**:
- Less than 60 min: "X min"
- 60+ min: "Xh Ym"
- Rounds to nearest minute

**Usage Example**:
```swift
let formatted = calculator.formatDuration(1800) // "30 min"
let formatted2 = calculator.formatDuration(5400) // "1h 30m"
```

---

##### `validateDuration(_:)`
```swift
func validateDuration(_ duration: TimeInterval) -> Bool
```
**Description**: Validate duration is within acceptable bounds
**Parameters**:
- `duration`: Time interval in seconds to validate

**Returns**: `Bool` - `true` if valid, `false` otherwise

**Validation Rules**:
- Minimum: 5 minutes (300 seconds)
- Maximum: 90 minutes (5400 seconds)

**Usage Example**:
```swift
let isValid = calculator.validateDuration(25 * 60) // true
let isTooShort = calculator.validateDuration(2 * 60) // false
```

---

### ServiceContainer

**File**: `Sources/NaloFocus/Services/ServiceContainer.swift`
**Pattern**: Singleton with dependency injection
**Thread Safety**: `@MainActor` - Main thread only

Centralized dependency injection container for application services.

#### Properties

##### `shared: ServiceContainer`
```swift
static let shared = ServiceContainer()
```
**Description**: Singleton instance
**Access**: Public
**Thread Safety**: Thread-safe singleton initialization

##### `reminderManager: ReminderManagerProtocol`
```swift
nonisolated lazy var reminderManager: ReminderManagerProtocol = ReminderManager()
```
**Description**: Reminder management service
**Type**: Protocol-typed for testability
**Lifecycle**: Lazy initialized on first access

##### `timeCalculator: TimeCalculator`
```swift
nonisolated lazy var timeCalculator: TimeCalculator = TimeCalculator()
```
**Description**: Time calculation service
**Lifecycle**: Lazy initialized on first access

---

#### SwiftUI Integration

```swift
// Inject into environment
.environment(\.serviceContainer, ServiceContainer.shared)

// Access in views
@Environment(\.serviceContainer) var services
let reminderManager = services.reminderManager
```

---

## Models Layer

### SprintSession

**File**: `Sources/NaloFocus/Models/SprintSession.swift`
**Conformance**: `Sendable`

Container for complete sprint session configuration.

#### Properties

##### `tasks: [SprintTask]`
```swift
var tasks: [SprintTask] = []
```
**Description**: Array of tasks in sprint sequence
**Default**: Empty array
**Constraints**: 1-9 tasks per sprint

##### `startTime: Date`
```swift
var startTime: Date = Date()
```
**Description**: Sprint start time
**Default**: Current time
**Behavior**: All tasks scheduled sequentially from this time

---

#### Computed Properties

##### `endTime: Date`
```swift
var endTime: Date { get }
```
**Description**: Calculated end time based on all task durations
**Calculation**: `startTime + sum(task.totalDuration for all tasks)`

**Example**:
```swift
var session = SprintSession()
session.tasks = [task1, task2] // 25 min + 30 min
print(session.endTime) // startTime + 55 minutes
```

##### `totalDuration: TimeInterval`
```swift
var totalDuration: TimeInterval { get }
```
**Description**: Total sprint duration in seconds
**Calculation**: Sum of all task `totalDuration` (including breaks)

**Example**:
```swift
let duration = session.totalDuration // seconds
let minutes = Int(duration / 60)
print("Sprint is \(minutes) minutes long")
```

---

### SprintTask

**File**: `Sources/NaloFocus/Models/SprintTask.swift`
**Conformance**: `Identifiable`, `@unchecked Sendable`

Individual task within a sprint with duration and break configuration.

#### Properties

##### `id: UUID`
```swift
let id = UUID()
```
**Description**: Unique identifier
**Access**: Auto-generated, immutable

##### `reminder: EKReminder?`
```swift
var reminder: EKReminder? = nil
```
**Description**: Associated EventKit reminder
**Default**: `nil` (must be set by user)
**Validation**: Must be non-nil before sprint creation

##### `duration: TimeInterval`
```swift
var duration: TimeInterval
```
**Description**: Task duration in seconds
**Default**: 1500 (25 minutes)
**Constraints**: 300-5400 seconds (5-90 minutes)

##### `hasBreak: Bool`
```swift
var hasBreak: Bool = false
```
**Description**: Whether task includes break after completion
**Default**: `false`

##### `breakDuration: TimeInterval`
```swift
var breakDuration: TimeInterval = 5 * 60
```
**Description**: Break duration in seconds
**Default**: 300 (5 minutes)
**Applied**: Only when `hasBreak == true`

---

#### Computed Properties

##### `totalDuration: TimeInterval`
```swift
var totalDuration: TimeInterval { get }
```
**Description**: Task duration + break duration (if applicable)
**Calculation**: `duration + (hasBreak ? breakDuration : 0)`

**Example**:
```swift
var task = SprintTask(duration: 25 * 60)
task.hasBreak = true
task.breakDuration = 5 * 60
print(task.totalDuration) // 1800 (30 minutes)
```

---

### TimelineEntry

**File**: `Sources/NaloFocus/Models/TimelineEntry.swift`
**Conformance**: `Identifiable`, `Sendable`

Visualization data for sprint timeline display.

#### Types

##### `EntryType`
```swift
enum EntryType {
    case task
    case break
}
```
**Description**: Type discriminator for timeline entries

---

#### Properties

##### `id: UUID`
```swift
let id = UUID()
```
**Description**: Unique identifier

##### `type: EntryType`
```swift
let type: EntryType
```
**Description**: Entry type (task or break)

##### `title: String`
```swift
let title: String
```
**Description**: Display title
**Format**:
- Task: Reminder title
- Break: "Break - X min"

##### `startTime: Date`
```swift
let startTime: Date
```
**Description**: Entry start time

##### `duration: TimeInterval`
```swift
let duration: TimeInterval
```
**Description**: Entry duration in seconds

##### `calendarColor: NSColor?`
```swift
let calendarColor: NSColor?
```
**Description**: Calendar color for visual indicators
**Source**: `reminder.calendar.cgColor`
**Usage**: Timeline color bars, task card accents

---

#### Computed Properties

##### `endTime: Date`
```swift
var endTime: Date { get }
```
**Description**: Calculated end time
**Calculation**: `startTime + duration`

##### `formattedStartTime: String`
```swift
var formattedStartTime: String { get }
```
**Description**: Formatted start time (e.g., "2:30 PM")

##### `formattedDuration: String`
```swift
var formattedDuration: String { get }
```
**Description**: Formatted duration (e.g., "25 min")

---

### ReminderCategory

**File**: `Sources/NaloFocus/Models/ReminderCategory.swift`

Categorization logic for reminder organization.

#### Types

##### `Category`
```swift
enum Category {
    case pastDue
    case today
    case tomorrow
    case future
    case noTimeSet
}
```
**Description**: Reminder categories based on due date

##### `CategorizedReminders`
```swift
struct CategorizedReminders {
    var pastDue: [EKReminder] = []
    var scheduled: [EKReminder] = []
    var noTimeSet: [EKReminder] = []
}
```
**Description**: Container for categorized reminder arrays

---

#### Methods

##### `categorize(_:)`
```swift
static func categorize(_ reminder: EKReminder) -> Category
```
**Description**: Categorize single reminder by due date
**Parameters**:
- `reminder`: Reminder to categorize

**Returns**: `Category` enum value

**Logic**:
```
No due date → noTimeSet
Due date < now → pastDue
Due date == today → today
Due date == tomorrow → tomorrow
Due date > tomorrow → future
```

---

##### `sortReminders(_:)`
```swift
static func sortReminders(_ reminders: [EKReminder]) -> [EKReminder]
```
**Description**: Sort reminders by category priority and due date
**Parameters**:
- `reminders`: Unsorted reminder array

**Returns**: Sorted reminder array

**Sort Order**:
1. Past Due (earliest first)
2. Today (earliest first)
3. Tomorrow (earliest first)
4. Future (earliest first)
5. No Time Set (alphabetical by title)

---

## ViewModels Layer

### SprintDialogViewModel

**File**: `Sources/NaloFocus/Models/SprintDialogViewModel.swift`
**Conformance**: `ObservableObject`
**Thread Safety**: `@MainActor` - UI thread only

Business logic for sprint dialog UI.

#### Published Properties

##### `sprintSession: SprintSession`
```swift
@Published var sprintSession = SprintSession()
```
**Description**: Current sprint configuration
**Binding**: Two-way bound to UI controls

##### `taskCount: Int`
```swift
@Published var taskCount = 1
```
**Description**: Number of tasks in sprint
**Range**: 1-9
**Side Effects**: Automatically adds/removes tasks from session

##### `availableReminders: [EKReminder]`
```swift
@Published var availableReminders: [EKReminder] = []
```
**Description**: Fetched reminders available for selection
**Lifecycle**: Loaded on dialog appearance

##### `timelineEntries: [TimelineEntry]`
```swift
@Published var timelineEntries: [TimelineEntry] = []
```
**Description**: Preview timeline for sprint
**Updates**: Regenerated when session changes

##### `isLoading: Bool`
```swift
@Published var isLoading = false
```
**Description**: Loading state indicator

##### `errorMessage: String?`
```swift
@Published var errorMessage: String? = nil
```
**Description**: Error message for display
**Nil**: No error
**Non-nil**: Error message to show user

##### `showSuccessMessage: Bool`
```swift
@Published var showSuccessMessage = false
```
**Description**: Success message display flag

---

#### Dependencies

##### `reminderManager: ReminderManagerProtocol`
```swift
private let reminderManager: ReminderManagerProtocol
```
**Description**: Reminder service dependency
**Injection**: Constructor or default to ServiceContainer

---

#### Methods

##### `init(reminderManager:)`
```swift
init(reminderManager: ReminderManagerProtocol = ServiceContainer.shared.reminderManager)
```
**Description**: Initialize with optional dependency injection
**Parameters**:
- `reminderManager`: Reminder service (defaults to singleton)

**Usage**:
```swift
// Production
let viewModel = SprintDialogViewModel()

// Testing
let mockManager = MockReminderManager()
let viewModel = SprintDialogViewModel(reminderManager: mockManager)
```

---

##### `loadReminders()`
```swift
func loadReminders() async
```
**Description**: Fetch available reminders from EventKit
**Thread Safety**: Main actor isolated
**Side Effects**:
- Sets `isLoading = true`
- Updates `availableReminders` on success
- Sets `errorMessage` on failure
- Sets `isLoading = false` when complete

**Error Handling**: Catches and displays errors gracefully

**Usage**:
```swift
Task {
    await viewModel.loadReminders()
}
```

---

##### `addTask()`
```swift
func addTask()
```
**Description**: Add new task to sprint
**Constraints**: Maximum 9 tasks
**Behavior**:
- Creates new SprintTask with default duration (25 min)
- Appends to `sprintSession.tasks`
- Updates `taskCount`
- Regenerates timeline

---

##### `insertTask(at:)`
```swift
func insertTask(at index: Int)
```
**Description**: Insert new task at specific position
**Parameters**:
- `index`: Insertion position (0-based)

**Constraints**: Maximum 9 tasks
**Behavior**:
- Creates new SprintTask with default duration
- Inserts at specified index (clamped to valid range)
- Updates `taskCount`
- Regenerates timeline

**Usage**:
```swift
viewModel.insertTask(at: 2) // Insert after task 1
```

---

##### `removeTask(at:)`
```swift
func removeTask(at index: Int)
```
**Description**: Remove task from sprint
**Parameters**:
- `index`: Task position (0-based)

**Behavior**:
- Removes task from `sprintSession.tasks`
- Updates `taskCount`
- Regenerates timeline

---

##### `createSprint()`
```swift
func createSprint() async
```
**Description**: Execute sprint creation
**Thread Safety**: Main actor isolated
**Validation**:
- All tasks must have assigned reminders
- Task count must be 1-9
- Durations must be valid

**Side Effects**:
- Updates all task reminders in EventKit
- Creates break reminders if configured
- Shows success message
- Resets form on success

**Error Handling**: Sets `errorMessage` on failure

**Usage**:
```swift
Task {
    await viewModel.createSprint()
}
```

---

##### `generateTimeline()`
```swift
func generateTimeline()
```
**Description**: Build preview timeline from session
**Updates**: `timelineEntries` property
**Called**: Automatically when session changes

**Timeline Format**:
- Task entries with reminder titles and calendar colors
- Break entries between tasks (if configured)
- Sequential timing from start time

---

### AppStateCoordinator

**File**: `Sources/NaloFocus/Models/AppStateCoordinator.swift`
**Conformance**: `ObservableObject`
**Thread Safety**: `@MainActor`

App-wide state coordination for dialog visibility and navigation.

#### Published Properties

##### `showSprintDialog: Bool`
```swift
@Published var showSprintDialog = false
```
**Description**: Sprint dialog visibility flag

##### `activeDialogId: UUID?`
```swift
@Published var activeDialogId: UUID? = nil
```
**Description**: Currently active dialog identifier

---

## Protocols

### ReminderManagerProtocol

**File**: `Sources/NaloFocus/Services/ReminderManagerProtocol.swift`
**Thread Safety**: `@MainActor` required

Protocol definition for EventKit reminder management.

#### Required Methods

```swift
func requestAccess() async throws -> Bool
func fetchReminders() async throws -> [EKReminder]
func categorizeReminders(_ reminders: [EKReminder]) -> CategorizedReminders
func updateReminderAlarm(_ reminder: EKReminder, at date: Date) async throws
func createBreakReminder(at date: Date, duration: TimeInterval) async throws -> EKReminder
func findOrCreateBreaksList() async throws -> EKCalendar
func updateRemindersForSprint(_ session: SprintSession) async throws
```

**Purpose**: Enable dependency injection and testing
**Implementation**: `ReminderManager`
**Testing**: Use custom mock implementations

---

## Type Definitions

### UncheckedSendableBox

```swift
struct UncheckedSendableBox<T>: @unchecked Sendable {
    let value: T
}
```
**Purpose**: Wrap non-Sendable EventKit types for async/await
**Location**: `ReminderManager.swift`
**Usage**: Internal concurrency workaround

---

## Constants

### AppConstants

**File**: `Sources/NaloFocus/Utilities/AppConstants.swift`

```swift
struct AppConstants {
    // Duration limits
    static let minTaskDuration: TimeInterval = 5 * 60    // 5 minutes
    static let maxTaskDuration: TimeInterval = 90 * 60   // 90 minutes
    static let defaultTaskDuration: TimeInterval = 25 * 60  // 25 minutes
    static let defaultBreakDuration: TimeInterval = 5 * 60  // 5 minutes

    // Task count limits
    static let minTaskCount = 1
    static let maxTaskCount = 9

    // UI constants
    static let breaksCalendarName = "Breaks"
}
```

---

## Error Handling

### Common Errors

#### Permission Errors
```swift
// Access denied
ReminderError.accessDenied

// Handle in UI
do {
    let granted = try await reminderManager.requestAccess()
    guard granted else {
        throw ReminderError.accessDenied
    }
} catch {
    viewModel.errorMessage = "Permission denied. Please allow access in Settings."
}
```

#### EventKit Errors
```swift
// EventKit errors bubble up
try await reminderManager.updateReminderAlarm(reminder, at: date)

// Catch and display
catch {
    viewModel.errorMessage = "Failed to update reminder: \(error.localizedDescription)"
}
```

---

## Thread Safety Notes

### Main Actor Requirements
All UI-related code must run on main actor:
- `ReminderManager` - `@MainActor` protocol and implementation
- `SprintDialogViewModel` - `@MainActor` class
- `AppStateCoordinator` - `@MainActor` class

### ServiceContainer
- Marked with `@MainActor`
- Properties are `nonisolated lazy` for flexibility
- Services themselves handle actor isolation

---

## Testing Patterns

### Mock ReminderManager
```swift
@MainActor
final class MockReminderManager: ReminderManagerProtocol {
    var shouldFailAccess = false
    var mockReminders: [EKReminder] = []
    var updateCallCount = 0

    func requestAccess() async throws -> Bool {
        return !shouldFailAccess
    }

    func fetchReminders() async throws -> [EKReminder] {
        return mockReminders
    }

    func updateReminderAlarm(_ reminder: EKReminder, at date: Date) async throws {
        updateCallCount += 1
    }

    // Implement other protocol methods...
}
```

### ViewModel Testing
```swift
@MainActor
final class SprintDialogViewModelTests: XCTestCase {
    var viewModel: SprintDialogViewModel!
    var mockManager: MockReminderManager!

    override func setUp() async throws {
        mockManager = MockReminderManager()
        viewModel = SprintDialogViewModel(reminderManager: mockManager)
    }

    func testAddTask() {
        viewModel.addTask()
        XCTAssertEqual(viewModel.taskCount, 2)
        XCTAssertEqual(viewModel.sprintSession.tasks.count, 2)
    }
}
```

---

## Navigation

- [Top](#nalofocus-api-reference)
- [Services](#services-layer)
- [Models](#models-layer)
- [ViewModels](#viewmodels-layer)
- [Protocols](#protocols)

**See Also**:
- [Project Index](PROJECT_INDEX.md) - Complete project navigation
- [Architecture Guide](ARCHITECTURE.md) - System architecture overview
- [Testing Guide](../TESTING_GUIDE.md) - Testing strategies and procedures
