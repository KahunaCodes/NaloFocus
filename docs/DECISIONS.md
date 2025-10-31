# NaloFocus Architectural Decision Record (ADR)

> This document captures all significant architectural and design decisions made during the development of NaloFocus.

---

## Decision Template

```markdown
### ADR-XXX: [Decision Title]
**Date**: YYYY-MM-DD
**Status**: [Proposed | Accepted | Deprecated | Superseded]
**Context**: What is the issue that we're seeing that is motivating this decision?
**Decision**: What is the change that we're proposing and/or doing?
**Consequences**: What becomes easier or more difficult to do because of this change?
**Alternatives Considered**: What other options were evaluated?
```

---

## Decisions Log

### ADR-001: Use SwiftUI for User Interface
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Need to build a modern macOS menu bar application with a clean, native interface.
**Decision**: Use SwiftUI instead of AppKit for all user interface components.
**Consequences**:
- ✅ Simpler, more declarative UI code
- ✅ Better integration with MenuBarExtra API
- ✅ Automatic dark mode support
- ✅ Built-in animations and transitions
- ❌ Requires macOS 15+ minimum deployment target
- ❌ Less flexibility for complex custom controls
**Alternatives Considered**:
- AppKit: More control but more complex code
- Electron: Cross-platform but not native
- Flutter: Cross-platform but poor menu bar support

---

### ADR-002: Stateless Application Design
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Need to decide whether to store sprint history, preferences, and session data.
**Decision**: Implement a completely stateless design with no persistence layer.
**Consequences**:
- ✅ Dramatically simpler architecture
- ✅ No database or file management needed
- ✅ No data migration concerns
- ✅ Privacy-friendly (no user data stored)
- ✅ Each session starts fresh
- ❌ Cannot show history or analytics
- ❌ Cannot save user preferences
- ❌ Cannot restore previous session
**Alternatives Considered**:
- Core Data: Overkill for simple preferences
- UserDefaults: Would add complexity for minimal benefit
- JSON files: Would require file management

---

### ADR-003: Direct EventKit Integration
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Need to interact with system Reminders to update alarm times and create break reminders.
**Decision**: Use EventKit framework directly without any wrapper libraries or abstractions.
**Consequences**:
- ✅ Native performance and reliability
- ✅ Full access to all EventKit features
- ✅ No external dependencies
- ✅ Direct control over error handling
- ❌ More boilerplate code needed
- ❌ Must handle permissions carefully
- ❌ Need to manage EventStore lifecycle
**Alternatives Considered**:
- EventKit wrapper libraries: Add unnecessary complexity
- Calendar app integration: Would require Calendar permissions too
- Custom notification system: Would duplicate Reminders functionality

---

### ADR-004: MVVM Architecture Pattern
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Need a clean architecture that separates business logic from UI and is testable.
**Decision**: Use MVVM (Model-View-ViewModel) pattern with ObservableObject view models.
**Consequences**:
- ✅ Clear separation of concerns
- ✅ Highly testable business logic
- ✅ Natural fit with SwiftUI's data flow
- ✅ Easy to maintain and extend
- ❌ Some boilerplate for simple views
- ❌ Need to manage @Published properties carefully
**Alternatives Considered**:
- MVC: Too much logic in views with SwiftUI
- Redux/TCA: Overkill for this app's complexity
- No pattern: Would lead to messy, untestable code

---

### ADR-005: Dependency Injection via Service Container
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Need to manage dependencies and make code testable with mock services.
**Decision**: Implement a ServiceContainer singleton with protocol-based services.
**Consequences**:
- ✅ Easy to mock services for testing
- ✅ Centralized dependency management
- ✅ Clear service interfaces
- ✅ Simple to understand and use
- ❌ Singleton pattern has some drawbacks
- ❌ Need to maintain protocols for all services
**Alternatives Considered**:
- Constructor injection: Too verbose in SwiftUI
- Environment injection only: Limited to Views
- No DI: Would make testing very difficult

---

### ADR-006: Modal Dialog for Sprint Planning
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Need to present sprint planning interface from menu bar icon.
**Decision**: Use a modal dialog window instead of a popover or dropdown menu.
**Consequences**:
- ✅ More space for complex UI
- ✅ Better keyboard navigation
- ✅ Can show preview timeline
- ✅ Clearer user focus
- ❌ Requires window management
- ❌ Less lightweight than popover
**Alternatives Considered**:
- Popover: Too cramped for task list
- Dropdown menu: Not suitable for complex interactions
- Separate window: Would feel disconnected from menu bar

---

### ADR-007: Dynamic Task Row Generation
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Users need to create sprints with varying numbers of tasks (1-9).
**Decision**: Dynamically generate task rows based on user selection rather than fixed slots.
**Consequences**:
- ✅ Cleaner UI with only needed rows
- ✅ Better performance with fewer views
- ✅ More intuitive user experience
- ❌ Slightly more complex state management
- ❌ Need to handle row addition/removal animations
**Alternatives Considered**:
- Fixed 9 rows with enable/disable: Cluttered UI
- Unlimited rows: Could overwhelm the interface
- Fixed 3 rows: Too limiting for users

---

### ADR-008: Searchable Reminder Picker
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Users may have many reminders and need to quickly find specific ones.
**Decision**: Implement a searchable dropdown with categorization instead of a simple picker.
**Consequences**:
- ✅ Better UX for users with many reminders
- ✅ Clear organization by status
- ✅ Faster reminder selection
- ❌ More complex component to build
- ❌ Need to handle search and filtering logic
**Alternatives Considered**:
- Simple picker: Poor UX with many items
- Table view: Too much space needed
- Type-ahead only: No overview of available reminders

---

### ADR-009: Break Reminders in Separate List
**Date**: 2025-10-30
**Status**: Accepted
**Context**: Need to create break reminders that don't clutter user's main reminder lists.
**Decision**: Create and maintain a separate "Breaks" reminder list/calendar.
**Consequences**:
- ✅ Keeps main lists clean
- ✅ Easy to identify and manage breaks
- ✅ Can be hidden/shown in Reminders app
- ✅ Clear separation of concerns
- ❌ Need to manage list creation
- ❌ Must handle list already exists case
**Alternatives Considered**:
- Add to default list: Would clutter user's tasks
- Don't create breaks: Users lose break functionality
- Use notifications instead: Would bypass Reminders app

---

### ADR-010: Reset After Sprint Creation
**Date**: 2025-10-30
**Status**: Accepted
**Context**: After creating a sprint, need to decide whether to maintain or reset the form.
**Decision**: Completely reset the form to default state after successful sprint creation.
**Consequences**:
- ✅ Clean slate for next sprint
- ✅ No accidental re-submission
- ✅ Matches stateless design philosophy
- ✅ Predictable user experience
- ❌ Cannot easily create similar sprint
- ❌ Need to re-enter if making multiple sprints
**Alternatives Considered**:
- Keep form filled: Risk of confusion/double submission
- Save as template: Adds complexity and state
- Ask user: Adds unnecessary decision point

---

## Future Decisions to Make

### Pending: Recurring Reminder Handling
**Context**: Need to decide how to handle recurring reminders in the picker and scheduling.
**Options**:
1. Treat as single instance (simplest)
2. Show warning about recurrence
3. Prevent selection entirely
**Recommendation**: Start with option 1 for MVP

### Pending: Duplicate Selection Prevention
**Context**: Should we prevent users from selecting the same reminder multiple times?
**Options**:
1. Prevent at UI level (disable selected items)
2. Allow but show warning
3. Allow without restriction
**Recommendation**: Prevent at UI level for better UX

### Pending: Past Due Sorting
**Context**: Should past due reminders appear at top of picker automatically?
**Options**:
1. Always at top (most urgent first)
2. Keep in chronological order
3. User preference
**Recommendation**: Always at top for MVP

### Pending: Break Reminder Naming
**Context**: How should break reminders be named?
**Options**:
1. "Break - 5 min" (duration included)
2. "Break" (simple)
3. "Sprint Break #1" (numbered)
**Recommendation**: "Break - X min" for clarity

---

## Deprecated Decisions

*None yet*

---

## Decision Impact Matrix

| Decision | Complexity Impact | Performance Impact | UX Impact | Testability Impact |
|----------|------------------|-------------------|-----------|-------------------|
| SwiftUI | -2 (simpler) | 0 (neutral) | +2 (better) | +1 (better) |
| Stateless | -3 (much simpler) | +1 (better) | -1 (limited) | +2 (better) |
| EventKit Direct | +1 (complex) | +2 (better) | 0 (neutral) | 0 (neutral) |
| MVVM | +1 (complex) | 0 (neutral) | 0 (neutral) | +3 (much better) |
| Service Container | +1 (complex) | 0 (neutral) | 0 (neutral) | +2 (better) |

*Scale: -3 (much worse) to +3 (much better)*

---

*This document is updated whenever a significant architectural decision is made.*