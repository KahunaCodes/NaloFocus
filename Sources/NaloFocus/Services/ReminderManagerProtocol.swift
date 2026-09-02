//
//  ReminderManagerProtocol.swift
//  NaloFocus
//
//  Protocol definition for EventKit reminder management
//

import Foundation
@preconcurrency import EventKit

/// Protocol for managing EventKit reminders
@MainActor
protocol ReminderManagerProtocol {
    /// The store every EKReminder handed out by this manager belongs to (observers must watch this one)
    var eventStore: EKEventStore { get }

    /// When this manager last wrote to the store, so observers can ignore the echo of our own commits
    var lastOwnSaveAt: Date { get }

    /// Request access to Reminders
    func requestAccess() async throws -> Bool

    /// Fetch all incomplete reminders
    func fetchReminders() async throws -> [EKReminder]

    /// Fetch incomplete reminders whose due date falls inside [start, end]
    func fetchIncompleteReminders(dueBetween start: Date, and end: Date) async throws -> [EKReminder]

    /// Move a reminder to a date (due date + single alarm) and, in the same commit, delete a placeholder
    func reschedule(_ reminder: EKReminder, to date: Date, replacing placeholder: EKReminder?) async throws

    /// Categorize reminders by their due date status
    func categorizeReminders(_ reminders: [EKReminder]) -> CategorizedReminders

    /// Update a reminder's alarm to a specific date
    func updateReminderAlarm(_ reminder: EKReminder, at date: Date) async throws

    /// Create a break reminder at the specified time
    func createBreakReminder(at date: Date, duration: TimeInterval) async throws -> EKReminder

    /// Find or create the "Breaks" reminder list
    func findOrCreateBreaksList() async throws -> EKCalendar

    /// Update all reminders for a sprint session
    func updateRemindersForSprint(_ session: SprintSession) async throws
}
