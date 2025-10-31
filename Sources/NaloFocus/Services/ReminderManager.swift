//
//  ReminderManager.swift
//  NaloFocus
//
//  Implementation of EventKit reminder management
//

import Foundation
@preconcurrency import EventKit

/// Manages EventKit reminders for sprint scheduling
final class ReminderManager: ReminderManagerProtocol, @unchecked Sendable {
    private let eventStore = EKEventStore()
    private var breaksCalendar: EKCalendar?

    // MARK: - Permission Management

    func requestAccess() async throws -> Bool {
        if #available(macOS 14.0, *) {
            return try await eventStore.requestFullAccessToReminders()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .reminder) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }

    // MARK: - Reminder Fetching

    func fetchReminders() async throws -> [EKReminder] {
        let calendars = eventStore.calendars(for: .reminder)
        let predicate = eventStore.predicateForReminders(in: calendars)

        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                let safeReminders = reminders ?? []
                continuation.resume(with: .success(safeReminders))
            }
        }
    }

    func categorizeReminders(_ reminders: [EKReminder]) -> CategorizedReminders {
        var categorized = CategorizedReminders()
        let now = Date()

        for reminder in reminders where !reminder.isCompleted {
            if let dueDate = reminder.dueDateComponents?.date {
                if dueDate < now {
                    categorized.pastDue.append(reminder)
                } else {
                    categorized.scheduled.append(reminder)
                }
            } else {
                categorized.noTimeSet.append(reminder)
            }
        }

        // Sort each category appropriately
        categorized.pastDue.sort { ($0.dueDateComponents?.date ?? now) < ($1.dueDateComponents?.date ?? now) }
        categorized.scheduled.sort { ($0.dueDateComponents?.date ?? now) < ($1.dueDateComponents?.date ?? now) }
        categorized.noTimeSet.sort { $0.title ?? "" < $1.title ?? "" }

        return categorized
    }

    // MARK: - Reminder Updates

    func updateReminderAlarm(_ reminder: EKReminder, at date: Date) async throws {
        reminder.alarms = [EKAlarm(absoluteDate: date)]
        reminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        try eventStore.save(reminder, commit: true)
    }

    // MARK: - Sprint Operations

    func updateRemindersForSprint(_ session: SprintSession) async throws {
        var currentTime = session.startTime

        for task in session.tasks {
            // Update task reminder
            if let reminder = task.reminder {
                try await updateReminderAlarm(reminder, at: currentTime)
            }

            currentTime = currentTime.addingTimeInterval(task.duration)

            // Create break reminder if needed
            if task.hasBreak {
                _ = try await createBreakReminder(
                    at: currentTime,
                    duration: task.breakDuration
                )
                currentTime = currentTime.addingTimeInterval(task.breakDuration)
            }
        }
    }

    // MARK: - Break Management

    func createBreakReminder(at date: Date, duration: TimeInterval) async throws -> EKReminder {
        let breakCalendar = try await findOrCreateBreaksList()
        let breakReminder = EKReminder(eventStore: eventStore)

        let minutes = Int(duration / 60)
        breakReminder.title = "Break - \(minutes) min"
        breakReminder.calendar = breakCalendar
        breakReminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        breakReminder.alarms = [EKAlarm(absoluteDate: date)]

        try eventStore.save(breakReminder, commit: true)
        return breakReminder
    }

    func findOrCreateBreaksList() async throws -> EKCalendar {
        if let existing = breaksCalendar {
            return existing
        }

        // Try to find existing "Breaks" calendar
        let calendars = eventStore.calendars(for: .reminder)
        if let breaksCalendar = calendars.first(where: { $0.title == "Breaks" }) {
            self.breaksCalendar = breaksCalendar
            return breaksCalendar
        }

        // Create new "Breaks" calendar
        let newCalendar = EKCalendar(for: .reminder, eventStore: eventStore)
        newCalendar.title = "Breaks"
        newCalendar.source = eventStore.defaultCalendarForNewReminders()?.source

        try eventStore.saveCalendar(newCalendar, commit: true)
        self.breaksCalendar = newCalendar
        return newCalendar
    }
}
