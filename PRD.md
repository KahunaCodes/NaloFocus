# Product Requirements Document: NaloFocus
*Reminder Time Scheduler for macOS*

## Overview
NaloFocus is a lightweight macOS menu bar app that schedules your Reminders into time-blocked sprints with breaks, letting the native Reminders app handle all notifications and tracking.

## Core Function
1. Select reminders that need scheduling
2. Assign time estimates to each
3. Add breaks where desired  
4. Hit "Start Sprint" → All reminders get updated with sequential times starting now
5. App resets, ready for next sprint

## Technical Requirements
- **Platform**: macOS 15+
- **Framework**: SwiftUI
- **API**: EventKit for Reminders
- **Type**: Menu bar app with modal dialog

## User Interface

### Menu Bar
- Icon: Simple bird or tomato icon
- Single click → Opens sprint dialog
- Future: Right-click for settings

### Sprint Dialog (Modal Window)

#### Header Section
```
How many tasks? [3 ▼]
```

#### Task Entry Section
Dynamically generates rows based on number selected:
```
[Reminder Picker]  [25 min ▼]
        [+]
[Reminder Picker]  [25 min ▼]  
        [+]
[Reminder Picker]  [25 min ▼]
```

**Reminder Picker**:
- Searchable dropdown/combobox
- Organized in three sections:
  ```
  === Past Due ===
  • Submit report (due 2 hours ago)
  • Call mom (due yesterday)
  
  === No Time Set ===
  • Fix bike
  • Order groceries
  
  === Scheduled ===  
  • Team meeting (3pm)
  • Dentist (tomorrow 9am)
  ```

**Duration Dropdown**: 
- Options: 5, 10, 15, 20, 25, 30, 45, 60, 90 min
- Default: 25 min

**Break Button (+)**:
- Inserts a break row: `[5 min break ▼] [x]`
- Break options: 5, 10, 15, 20 min
- Can remove with [x]

#### Preview Section
Visual timeline showing:
```
2:15pm - Submit report (25 min)
2:40pm - Break (5 min)  
2:45pm - Fix bike (25 min)
3:10pm - Call mom (15 min)
3:25pm - End of sprint
```

#### Actions
```
[Cancel]  [Start Sprint]
```

## Behavior

### On "Start Sprint"
1. Creates "Breaks" list if doesn't exist
2. Starting from current time:
   - Updates first reminder's alert time to now
   - Each subsequent reminder = previous end time
   - Break reminders created in "Breaks" list
3. Shows success: "✓ Sprint scheduled! First task at 2:15pm"
4. Resets form to default state

### Permissions
- Must request Reminders access on first launch
- Graceful fallback if denied

## Data Handling

### No Persistence Needed
- App doesn't track state
- All data lives in Reminders
- Each session is independent

### Reminder Updates
```swift
// Pseudocode
let startTime = Date.now
var currentTime = startTime

for task in selectedTasks {
    reminder.alarmTime = currentTime
    currentTime.add(task.duration)
    
    if task.hasBreak {
        createBreakReminder(at: currentTime, 
                           duration: task.breakDuration)
        currentTime.add(task.breakDuration)
    }
}
```

## MVP Scope

### Include
- ✅ Menu bar app
- ✅ Sprint dialog with 1-9 tasks
- ✅ Reminder picker with 3 categories
- ✅ Duration selection
- ✅ Break insertion
- ✅ Timeline preview
- ✅ Update reminder times
- ✅ Create break reminders

### Exclude (for now)
- ❌ Custom start times (always "now")
- ❌ Settings/preferences
- ❌ History tracking
- ❌ Timer functionality
- ❌ Notifications (Reminders handles)
- ❌ Calendar integration
- ❌ Reminder creation (only selection)

## Edge Cases
1. **"Breaks" list already exists** → Use it
2. **Reminder already has time today** → Show but mark with ⚠️
3. **No reminders available** → Show empty state
4. **Sprint extends past midnight** → Allow (Reminders handles)
5. **Duplicate reminder selection** → Prevent in UI

## Success Criteria
- < 10 seconds to schedule a sprint
- Zero data loss (all reminder updates succeed)
- Clean reset after each sprint
- Works with all Reminder accounts (iCloud, Exchange, Local)

## Questions Remaining
1. Should we prevent selecting the same reminder twice?
2. Name for break reminders? "Break - 5 min" or just "Break"?
3. Should past due reminders jump to top of picker?
4. Any special handling for recurring reminders?

## Implementation Notes

### Development Environment
- **IDE**: Windsurf or Xcode
- **AI Assistance**: Claude Code / Windsurf AI
- **Version Control**: Git
- **Testing**: XCTest for unit tests

### Key SwiftUI Components Needed
- `MenuBarExtra` - For menu bar presence
- `EventStore` - EventKit for Reminders access
- `Picker` or custom `SearchableComboBox` - For reminder selection
- `Timeline` view - Custom SwiftUI for preview
- `Stepper` or `Picker` - For task count selection

### EventKit Permissions
```swift
// Info.plist entry required
NSRemindersUsageDescription: "NaloFocus needs access to your reminders to schedule them into time blocks"

// Permission request
EventStore().requestAccess(to: .reminder) { granted, error in
    // Handle permission result
}
```

### Project Structure
```
NaloFocus/
├── NaloFocusApp.swift         // App entry point
├── MenuBarController.swift     // Menu bar management
├── Views/
│   ├── SprintDialogView.swift // Main dialog
│   ├── ReminderPicker.swift   // Custom reminder selector
│   ├── TimelinePreview.swift  // Visual timeline
│   └── TaskRowView.swift      // Individual task entry
├── Models/
│   ├── SprintSession.swift    // Sprint data model
│   └── ReminderManager.swift  // EventKit wrapper
└── Utilities/
    └── TimeCalculator.swift    // Time math helpers
```

### Build & Distribution
- **Min Deployment**: macOS 15.0
- **Code Signing**: Required for EventKit
- **Notarization**: Required for distribution
- **App Sandbox**: Yes, with Reminders entitlement