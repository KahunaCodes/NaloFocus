//
//  EKReminder+Scheduling.swift
//  NaloFocus
//
//  Due-date helpers shared by the store watcher, the picker and the coordinator
//

import Foundation
@preconcurrency import EventKit

extension EKReminder {
    /// Due date resolved from `dueDateComponents`, tolerating components without an attached calendar
    var resolvedDueDate: Date? {
        guard let components = dueDateComponents else { return nil }
        return components.date ?? Calendar.current.date(from: components)
    }

    /// True when the due date carries a clock time (a Calendar slot); false for all-day or undated reminders
    var hasTimedDueDate: Bool {
        dueDateComponents?.hour != nil
    }
}
