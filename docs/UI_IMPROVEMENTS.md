# UI Improvements for Sprint Planning Dialog

## Priority 1: Immediate Launch-Ready Improvements

### 1. Visual Hierarchy & Spacing

**Problem**: Tasks blend together with insufficient visual separation
**Solution**: Add clear card boundaries and increased spacing

```swift
// In TaskConfigurationRow
.padding(16)  // Increase from 12
.background(Color(NSColor.controlBackgroundColor))
.overlay(
    RoundedRectangle(cornerRadius: 8)
        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
)
.cornerRadius(8)  // Increase from 6
.shadow(color: .black.opacity(0.05), radius: 2, y: 1)  // Add subtle shadow
```

### 2. Task Header Enhancement

**Problem**: "Task 1" headers lack visual weight
**Solution**: Add task status indicators and better typography

```swift
HStack {
    // Add colored task number badge
    Circle()
        .fill(taskStatusColor)
        .frame(width: 24, height: 24)
        .overlay(
            Text("\(index + 1)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        )

    Text("Task")
        .font(.system(.subheadline, design: .rounded))
        .fontWeight(.semibold)

    if task.reminder != nil {
        Label("Ready", systemImage: "checkmark.circle.fill")
            .font(.caption)
            .foregroundColor(.green)
    }

    Spacer()

    // Remove action with confirmation
    Button(action: onRemove) {
        Image(systemName: "xmark.circle.fill")
            .foregroundColor(.secondary)
            .imageScale(.medium)
    }
    .buttonStyle(.plain)
    .help("Remove this task")
}
```

### 3. Duration Controls Clarity

**Problem**: Preset buttons and slider relationship unclear
**Solution**: Visual grouping and better labeling

```swift
VStack(alignment: .leading, spacing: 8) {
    // Label with duration display
    HStack {
        Text("Duration")
            .font(.caption)
            .fontWeight(.medium)
        Spacer()
        Text("\(Int(task.duration / 60)) minutes")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)
    }

    // Quick presets in a visual group
    VStack(alignment: .leading, spacing: 6) {
        Text("Quick select:")
            .font(.caption2)
            .foregroundColor(.secondary)

        HStack(spacing: 6) {
            ForEach([15, 25, 30, 45], id: \.self) { minutes in
                Button(action: { task.duration = Double(minutes) * 60 }) {
                    VStack(spacing: 2) {
                        Text("\(minutes)")
                            .font(.caption)
                            .fontWeight(Int(task.duration / 60) == minutes ? .bold : .regular)
                        Text("min")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 44, height: 36)
                    .background(
                        Int(task.duration / 60) == minutes
                            ? Color.accentColor
                            : Color.secondary.opacity(0.1)
                    )
                    .foregroundColor(
                        Int(task.duration / 60) == minutes
                            ? .white
                            : .primary
                    )
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // Custom duration slider
    VStack(alignment: .leading, spacing: 4) {
        Text("Custom duration:")
            .font(.caption2)
            .foregroundColor(.secondary)

        HStack {
            Slider(value: /* binding */, in: 5...90, step: 5)
                .frame(maxWidth: 200)

            TextField("", value: /* binding */, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 50)
                .multilineTextAlignment(.center)

            Text("min")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
.padding(12)
.background(Color.secondary.opacity(0.05))
.cornerRadius(6)
```

### 4. Reminder Selection Improvement

**Problem**: Selected reminder display is cramped and unclear
**Solution**: Better visual feedback and status

```swift
Button(action: { showReminderModal = true }) {
    HStack(spacing: 8) {
        // Status icon
        Image(systemName: task.reminder != nil
            ? "checkmark.circle.fill"
            : "exclamationmark.triangle.fill")
            .foregroundColor(task.reminder != nil ? .green : .orange)
            .font(.system(size: 14))

        VStack(alignment: .leading, spacing: 2) {
            Text(task.reminder?.title ?? "No reminder selected")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(task.reminder != nil ? .primary : .orange)
                .lineLimit(1)

            if let calendar = task.reminder?.calendar?.title {
                Text(calendar)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }

        Spacer()

        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
        task.reminder != nil
            ? Color.green.opacity(0.08)
            : Color.orange.opacity(0.08)
    )
    .cornerRadius(6)
    .overlay(
        RoundedRectangle(cornerRadius: 6)
            .stroke(
                task.reminder != nil
                    ? Color.green.opacity(0.3)
                    : Color.orange.opacity(0.3),
                lineWidth: 1
            )
    )
}
.buttonStyle(.plain)
.help(task.reminder != nil
    ? "Click to change reminder"
    : "Click to select a reminder")
```

### 5. Break Toggle Clarity

**Problem**: Break option appears disabled when not selected
**Solution**: Clear on/off states with visual feedback

```swift
VStack(alignment: .leading, spacing: 8) {
    // Break header with status
    HStack {
        Label("Break after task", systemImage: "pause.circle")
            .font(.caption)
            .fontWeight(.medium)

        Spacer()

        Toggle("", isOn: $task.hasBreak)
            .toggleStyle(.switch)
            .controlSize(.small)
    }

    // Break duration controls (show only when enabled)
    if task.hasBreak {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Break duration:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(task.breakDuration / 60)) min")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            // Quick break presets
            HStack(spacing: 4) {
                ForEach([3, 5, 10, 15], id: \.self) { minutes in
                    Button("\(minutes)m") {
                        task.breakDuration = Double(minutes) * 60
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(Int(task.breakDuration / 60) == minutes ? .blue : .clear)
                }
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(4)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
.animation(.easeInOut(duration: 0.2), value: task.hasBreak)
```

## Priority 2: Polish for Better UX

### 1. Empty State Improvements
- Add helpful illustrations or icons
- Provide clear instructions: "Select reminders from your lists to schedule them into focused work blocks"
- Add example timeline showing what a sprint looks like

### 2. Validation Feedback
- Show inline validation messages for missing reminders
- Highlight incomplete tasks with orange borders
- Add completion indicators (e.g., "3 of 3 tasks configured")

### 3. Keyboard Navigation
- Add tab navigation between task cards
- Keyboard shortcuts for quick duration selection (1-4 for presets)
- Enter to confirm reminder selection in modal

### 4. Visual Feedback
- Add hover states for all interactive elements
- Smooth transitions when adding/removing tasks
- Loading states when fetching reminders

### 5. Information Architecture
- Group related controls (all duration controls together)
- Add section headers: "Task Setup", "Timing", "Breaks"
- Progressive disclosure for advanced options

## Color Scheme Recommendations

```swift
extension Color {
    static let taskCardBg = Color(NSColor.controlBackgroundColor)
    static let taskCardBorder = Color.secondary.opacity(0.2)
    static let taskNumberBadge = Color.accentColor
    static let reminderSelected = Color.green.opacity(0.1)
    static let reminderMissing = Color.orange.opacity(0.1)
    static let breakBg = Color.blue.opacity(0.05)
    static let timelineItemBg = Color.secondary.opacity(0.05)
}
```

## Implementation Priority

1. **Must Have for Launch** (30 min):
   - Fix task card separation
   - Improve reminder selection display
   - Clarify duration controls
   - Add validation feedback

2. **Nice to Have** (1 hour):
   - Animations and transitions
   - Keyboard navigation
   - Better empty states
   - Hover states

3. **Future Enhancements**:
   - Drag and drop task reordering
   - Reminder search/filter
   - Sprint templates
   - Time estimation helpers