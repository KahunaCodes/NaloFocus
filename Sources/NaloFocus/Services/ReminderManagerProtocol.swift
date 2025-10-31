//
//  ReminderManagerProtocol.swift
//  NaloFocus
//
//  Protocol definition for EventKit reminder management
//

import Foundation
@preconcurrency import EventKit

/// Protocol for managing EventKit reminders
protocol ReminderManagerProtocol {
    /// Request access to Reminders
    func requestAccess() async throws -> Bool

    /// Fetch all incomplete reminders
    func fetchReminders() async throws -> [EKReminder]

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
