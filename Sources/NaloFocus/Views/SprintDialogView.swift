//
//  SprintDialogView.swift
//  NaloFocus
//
//  Main sprint planning dialog interface
//

import SwiftUI
@preconcurrency import EventKit

struct SprintDialogView: View {
    @StateObject private var viewModel = SprintDialogViewModel()
    @EnvironmentObject var coordinator: AppStateCoordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            Divider()

            // Main content
            HSplitView {
                // Left: Sprint configuration
                sprintConfigSection
                    .frame(minWidth: 400, idealWidth: 450)

                // Right: Timeline preview
                timelinePreviewSection
                    .frame(minWidth: 300, idealWidth: 350)
            }
            .frame(height: 480)

            Divider()

            // Footer with actions
            footerSection
        }
        .frame(width: 800, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .task {
            await viewModel.loadReminders()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Sprint Planning")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Schedule your reminders into focused work blocks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding()
    }

    // MARK: - Sprint Configuration Section

    private var sprintConfigSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Task count selector
                taskCountSelector

                // Sprint start time
                startTimeSelector

                Divider()
                    .padding(.vertical, 4)

                // Task list
                Text("Tasks")
                    .font(.headline)
                    .padding(.bottom, 4)

                // Add task button at the beginning
                if viewModel.sprintSession.tasks.isEmpty || viewModel.sprintSession.tasks.count < 9 {
                    InsertTaskButton {
                        viewModel.insertTask(at: 0)
                    }
                }

                ForEach(viewModel.sprintSession.tasks.indices, id: \.self) { index in
                    TaskConfigurationRow(
                        task: $viewModel.sprintSession.tasks[index],
                        index: index,
                        availableReminders: viewModel.availableReminders,
                        onRemove: {
                            viewModel.removeTask(at: index)
                        }
                    )

                    // Add insertion button after each task (except if we're at max)
                    if viewModel.sprintSession.tasks.count < 9 {
                        InsertTaskButton {
                            viewModel.insertTask(at: index + 1)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
    }

    private var taskCountSelector: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "list.number")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.sprintSession.tasks.count) of 9 tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if viewModel.sprintSession.tasks.isEmpty {
                Button(action: { viewModel.addTask() }) {
                    Label("Add First Task", systemImage: "plus.circle.fill")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    private var startTimeSelector: some View {
        HStack {
            Text("Start time:")
                .font(.subheadline)
            DatePicker(
                "",
                selection: $viewModel.sprintSession.startTime,
                displayedComponents: [.hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.field)

            Button("Now") {
                viewModel.sprintSession.startTime = Date()
            }
            .buttonStyle(.link)
        }
    }

    // MARK: - Timeline Preview Section

    private var timelinePreviewSection: some View {
        VStack(alignment: .leading) {
            Text("Timeline")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(viewModel.timelineEntries.enumerated()), id: \.element.id) { index, entry in
                        // Only make tasks draggable, not breaks
                        if entry.type == .task {
                            TimelineEntryRow(
                                entry: entry,
                                index: viewModel.getTaskIndex(for: entry),
                                onMove: { fromIndex, toIndex in
                                    viewModel.moveTask(from: fromIndex, to: toIndex)
                                }
                            )
                            .onDrop(of: [.text], delegate: TimelineTaskDropDelegate(
                                taskIndex: viewModel.getTaskIndex(for: entry),
                                viewModel: viewModel
                            ))
                        } else {
                            // Breaks are not draggable
                            TimelineEntryRow(entry: entry, index: -1, onMove: nil)
                        }
                    }

                    if viewModel.timelineEntries.isEmpty {
                        Text("Add tasks to see timeline")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.horizontal)
            }

            // Total duration
            if !viewModel.timelineEntries.isEmpty {
                Divider()
                HStack {
                    Text("Total duration:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatDuration(viewModel.sprintSession.totalDuration))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        HStack {
            if viewModel.showSuccessMessage {
                Label("Sprint scheduled!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }

            Spacer()

            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape)

            Button("Start Sprint") {
                Task {
                    await viewModel.startSprint()
                    if viewModel.showSuccessMessage {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        dismiss()
                    }
                }
            }
            .keyboardShortcut(.return)
            .disabled(!viewModel.canStartSprint)
        }
        .padding(20)
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Insert Task Button

struct InsertTaskButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    Text("Add Task")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGreen).opacity(0.2))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                        .foregroundColor(.green.opacity(0.3))
                )
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Task Configuration Row

struct TaskConfigurationRow: View {
    @Binding var task: SprintTask
    let index: Int
    let availableReminders: CategorizedReminders
    let onRemove: () -> Void

    @State private var selectedReminderId: String?
    @State private var showReminderModal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            taskHeader
            reminderSection
            durationSection
            if index < 8 {
                breakSection
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .onAppear {
            selectedReminderId = task.reminder?.calendarItemIdentifier
        }
    }

    // MARK: - Task Header
    private var taskHeader: some View {
        HStack {
            // Task number badge
            Circle()
                .fill(Color.accentColor)
                .frame(width: 28, height: 28)
                .overlay(
                    Text("\(index + 1)")
                        .font(.system(.caption, weight: .semibold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Task \(index + 1)")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)

                if let reminderTitle = task.reminder?.title {
                    Text(reminderTitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            if task.reminder != nil {
                Label("Ready", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                    .labelStyle(.titleAndIcon)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .imageScale(.medium)
            }
            .buttonStyle(.plain)
            .help("Remove this task")
        }
    }

    // MARK: - Reminder Section
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Reminder")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Button(action: {
                showReminderModal = true
            }) {
                HStack(spacing: 8) {
                    // Calendar color indicator
                    if let reminder = task.reminder,
                       let calendarColor = reminder.calendar?.cgColor {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(NSColor(cgColor: calendarColor) ?? NSColor.systemBlue))
                            .frame(width: 3, height: 24)
                    } else {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 3, height: 24)
                    }

                    // Status icon with better visual feedback
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
                            .truncationMode(.tail)

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
        }
        .sheet(isPresented: $showReminderModal) {
            ReminderSelectionModal(
                isPresented: $showReminderModal,
                selectedReminder: $task.reminder,
                availableReminders: availableReminders
            )
        }
    }

    // MARK: - Duration Section
    private var durationSection: some View {
            VStack(alignment: .leading, spacing: 8) {
                // Duration header with current value display
                HStack {
                    Text("Duration")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
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
                        ForEach([5,10,15, 25, 30, 45], id: \.self) { minutes in
                            Button(action: { task.duration = Double(minutes) * 60 }) {
                                VStack(spacing: 2) {
                                    Text("\(minutes)")
                                        .font(.caption)
                                        .fontWeight(Int(task.duration / 60) == minutes ? .bold : .regular)
                                    Text("min")
                                        .font(.caption2)
                                        .foregroundColor(Int(task.duration / 60) == minutes ? .white.opacity(0.8) : .secondary)
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
                        Slider(
                            value: Binding(
                                get: { task.duration / 60 },
                                set: { newValue in
                                    task.duration = round(newValue) * 60
                                }
                            ),
                            in: 5...90,
                            step: 5
                        )
                        .frame(maxWidth: 200)

                        TextField(
                            "",
                            value: Binding(
                                get: { Int(task.duration / 60) },
                                set: { newValue in
                                    task.duration = Double(max(1, newValue)) * 60
                                }
                            ),
                            format: .number
                        )
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)

                        Text("min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(6)
    }

    // MARK: - Break Section
    private var breakSection: some View {
        VStack(alignment: .leading, spacing: 8) {
                    // Break header with toggle
                    HStack {
                        Label("Break after task", systemImage: "pause.circle")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

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
                                    .tint(Int(task.breakDuration / 60) == minutes ? .blue : nil)
                                }
                            }

                            // Break duration slider
                            HStack {
                                Slider(
                                    value: Binding(
                                        get: { task.breakDuration / 60 },
                                        set: { newValue in
                                            task.breakDuration = round(newValue) * 60
                                        }
                                    ),
                                    in: 1...20,
                                    step: 1
                                )
                                .frame(maxWidth: 200)

                                TextField(
                                    "",
                                    value: Binding(
                                        get: { Int(task.breakDuration / 60) },
                                        set: { newValue in
                                            task.breakDuration = Double(max(1, newValue)) * 60
                                        }
                                    ),
                                    format: .number
                                )
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 40)
                                .multilineTextAlignment(.center)

                                Text("min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
        }
        .animation(.easeInOut(duration: 0.2), value: task.hasBreak)
    }
}

// MARK: - Timeline Entry Row

struct TimelineEntryRow: View {
    let entry: TimelineEntry
    let index: Int
    let onMove: ((Int, Int) -> Void)?

    @State private var isDragging = false

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 8) {
            // Calendar color indicator for tasks
            if entry.type == .task {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(entry.calendarColor ?? NSColor.systemBlue))
                    .frame(width: 3, height: 24)
            }

            // Task or break indicator with calendar color
            Image(systemName: entry.type == .task ? "circle.fill" : "pause.circle")
                .foregroundColor(entry.type == .task ? Color(entry.calendarColor ?? NSColor.systemBlue) : .gray)
                .font(.caption)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.caption)
                    .lineLimit(1)
                Text("\(formatter.string(from: entry.startTime)) - \(formatter.string(from: entry.endTime))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Drag handle (only for tasks, not breaks)
            if entry.type == .task, onMove != nil {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary.opacity(0.4))
                    .font(.system(size: 14))
                    .padding(.horizontal, 8)
                    .contentShape(Rectangle())
                    .onDrag {
                        isDragging = true
                        // Use entry ID or index for drag data
                        return NSItemProvider(object: String(index) as NSString)
                    }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isDragging ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isDragging ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isDragging)
    }
}

// MARK: - Timeline Task Drop Delegate

struct TimelineTaskDropDelegate: DropDelegate {
    let taskIndex: Int
    let viewModel: SprintDialogViewModel

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let itemProvider = info.itemProviders(for: [.text]).first else { return }

        itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, error in
            guard let data = data as? Data,
                  let sourceIndexString = String(data: data, encoding: .utf8),
                  let sourceIndex = Int(sourceIndexString) else {
                return
            }

            if sourceIndex != taskIndex && sourceIndex >= 0 && taskIndex >= 0 {
                DispatchQueue.main.async {
                    viewModel.moveTask(from: sourceIndex, to: taskIndex)
                }
            }
        }
    }
}

// MARK: - Extensions

// totalDuration is already defined in SprintSession.swift