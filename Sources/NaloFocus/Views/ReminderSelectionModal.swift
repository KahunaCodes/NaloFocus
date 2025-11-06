//
//  ReminderSelectionModal.swift
//  NaloFocus
//
//  Modal view for selecting reminders with tabs and list grouping
//

import SwiftUI
import EventKit

struct ReminderSelectionModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedReminder: EKReminder?
    let availableReminders: CategorizedReminders

    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var expandedLists: Set<String> = []

    // Group reminders by their calendar (list)
    private func groupRemindersByList(_ reminders: [EKReminder]) -> [(String, NSColor?, [EKReminder])] {
        let grouped = Dictionary(grouping: reminders) { reminder in
            reminder.calendar?.title ?? "Default"
        }

        return grouped
            .map { (key, value) in
                let color = value.first?.calendar?.cgColor.flatMap { NSColor(cgColor: $0) } ?? NSColor.systemBlue
                let sortedReminders = value.sorted { ($0.title ?? "") < ($1.title ?? "") }
                return (key, color, sortedReminders)
            }
            .sorted { $0.0 < $1.0 }
    }

    private var currentReminders: [EKReminder] {
        switch selectedTab {
        case 0: return availableReminders.pastDue
        case 1: return availableReminders.noTimeSet
        case 2: return availableReminders.scheduled
        default: return []
        }
    }

    private var filteredGroups: [(String, NSColor?, [EKReminder])] {
        let reminders = currentReminders
        let filtered = searchText.isEmpty ? reminders : reminders.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
        }
        return groupRemindersByList(filtered)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            tabSelection
            Divider()
            reminderListSection
            Divider()
            footerSection
        }
        .frame(width: 500, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Select Reminder")
                .font(.title2)
                .fontWeight(.semibold)

            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search reminders...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .padding()
    }

    private var tabSelection: some View {
        Picker("Category", selection: $selectedTab) {
            Text("Past Due (\(availableReminders.pastDue.count))")
                .tag(0)
            Text("No Time Set (\(availableReminders.noTimeSet.count))")
                .tag(1)
            Text("Scheduled (\(availableReminders.scheduled.count))")
                .tag(2)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private var reminderListSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(filteredGroups, id: \.0) { listName, color, reminders in
                    ReminderListGroup(
                        listName: listName,
                        color: color,
                        reminders: reminders,
                        selectedReminder: $selectedReminder,
                        isPresented: $isPresented
                    )
                }

                if filteredGroups.isEmpty {
                    Text("No reminders found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                }
            }
            .padding(.vertical)
        }
    }

    private var footerSection: some View {
        HStack {
            Button("Cancel") {
                isPresented = false
            }
            .keyboardShortcut(.escape)

            Spacer()

            if selectedReminder != nil {
                Button("Clear Selection") {
                    selectedReminder = nil
                    isPresented = false
                }
            }
        }
        .padding()
    }
}

// MARK: - Reminder List Group

struct ReminderListGroup: View {
    let listName: String
    let color: NSColor?
    let reminders: [EKReminder]
    @Binding var selectedReminder: EKReminder?
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // List header with color indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(color ?? NSColor.systemBlue))
                    .frame(width: 10, height: 10)

                Text(listName)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("(\(reminders.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal)

            // Reminders in this list
            VStack(alignment: .leading, spacing: 4) {
                ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                    ReminderRow(
                        reminder: reminder,
                        isSelected: selectedReminder?.calendarItemIdentifier == reminder.calendarItemIdentifier,
                        color: color
                    ) {
                        selectedReminder = reminder
                        withAnimation(.easeOut(duration: 0.2)) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isPresented = false
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    let reminder: EKReminder
    let isSelected: Bool
    let color: NSColor?
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.accentColor : Color.secondary)
                    .font(.system(size: 16))

                // Calendar color bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(color ?? NSColor.systemBlue))
                    .frame(width: 3, height: 20)

                // Reminder details
                VStack(alignment: .leading, spacing: 2) {
                    Text(reminder.title ?? "Untitled")
                        .font(.system(size: 13))
                        .foregroundColor(isSelected ? .accentColor : .primary)
                        .lineLimit(1)

                    if let dueDate = reminder.dueDateComponents?.date {
                        Text(formatDate(dueDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Priority indicator if high priority
                if reminder.priority > 0 && reminder.priority <= 3 {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "h:mm a"
            return "Tomorrow, \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }
}

// Preview
struct ReminderSelectionModal_Previews: PreviewProvider {
    static var previews: some View {
        ReminderSelectionModal(
            isPresented: .constant(true),
            selectedReminder: .constant(nil),
            availableReminders: CategorizedReminders(
                pastDue: [],
                noTimeSet: [],
                scheduled: []
            )
        )
    }
}