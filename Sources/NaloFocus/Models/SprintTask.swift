//
//  SprintTask.swift
//  NaloFocus
//
//  Data model for individual sprint tasks
//

import Foundation
@preconcurrency import EventKit

/// Represents a single task in a sprint session
struct SprintTask: Identifiable {
    let id = UUID()
    var reminder: EKReminder?
    var duration: TimeInterval
    var hasBreak: Bool = false
    var breakDuration: TimeInterval = 5 * 60 // 5 minutes default

    /// Total duration including break time if applicable
    var totalDuration: TimeInterval {
        duration + (hasBreak ? breakDuration : 0)
    }
}
