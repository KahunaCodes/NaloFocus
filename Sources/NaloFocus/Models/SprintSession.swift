//
//  SprintSession.swift
//  NaloFocus
//
//  Data model for a complete sprint session
//

import Foundation

/// Represents a complete sprint session with multiple tasks
struct SprintSession: Sendable {
    var tasks: [SprintTask] = []
    var startTime: Date = Date()

    /// Calculated end time based on all task durations
    var endTime: Date {
        var time = startTime
        for task in tasks {
            time = time.addingTimeInterval(task.totalDuration)
        }
        return time
    }

    /// Total duration of the entire sprint
    var totalDuration: TimeInterval {
        tasks.reduce(0) { $0 + $1.totalDuration }
    }
}
