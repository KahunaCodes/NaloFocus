//
//  ReminderCategory.swift
//  NaloFocus
//
//  Categorization for reminder organization
//

import Foundation
@preconcurrency import EventKit

/// Categories for organizing reminders in the picker
enum ReminderCategory: String, CaseIterable {
    case pastDue = "Past Due"
    case noTimeSet = "No Time Set"
    case scheduled = "Scheduled"
}

/// Organized reminder structure with categorization
struct CategorizedReminders: @unchecked Sendable {
    var pastDue: [EKReminder] = []
    var noTimeSet: [EKReminder] = []
    var scheduled: [EKReminder] = []

    /// All reminders combined
    var allReminders: [EKReminder] {
        pastDue + noTimeSet + scheduled
    }
}
