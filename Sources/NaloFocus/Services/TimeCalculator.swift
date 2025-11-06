//
//  TimeCalculator.swift
//  NaloFocus
//
//  Time calculation and timeline generation service
//

import Foundation
import AppKit

/// Protocol for time calculation operations
protocol TimeCalculatorProtocol {
    func generateTimeline(from session: SprintSession) -> [TimelineEntry]
    func calculateEndTime(startTime: Date, tasks: [SprintTask]) -> Date
    func formatTimeRange(_ start: Date, _ end: Date) -> String
}

/// Calculates sprint timings and generates timeline previews
final class TimeCalculator: TimeCalculatorProtocol, @unchecked Sendable {
    private let formatter = DateFormatter()

    init() {
        formatter.dateStyle = .none
        formatter.timeStyle = .short
    }

    func generateTimeline(from session: SprintSession) -> [TimelineEntry] {
        var entries: [TimelineEntry] = []
        var currentTime = session.startTime

        for task in session.tasks {
            // Add task entry with calendar color
            let taskEnd = currentTime.addingTimeInterval(task.duration)
            let calendarColor = task.reminder?.calendar?.cgColor.flatMap { NSColor(cgColor: $0) }

            entries.append(TimelineEntry(
                startTime: currentTime,
                endTime: taskEnd,
                title: task.reminder?.title ?? "Untitled Task",
                type: .task,
                calendarColor: calendarColor
            ))

            currentTime = taskEnd

            // Add break entry if needed
            if task.hasBreak {
                let breakEnd = currentTime.addingTimeInterval(task.breakDuration)
                entries.append(TimelineEntry(
                    startTime: currentTime,
                    endTime: breakEnd,
                    title: "Break (\(Int(task.breakDuration / 60)) min)",
                    type: .breakTime,
                    calendarColor: nil
                ))
                currentTime = breakEnd
            }
        }

        return entries
    }

    func calculateEndTime(startTime: Date, tasks: [SprintTask]) -> Date {
        let totalDuration = tasks.reduce(0) { $0 + $1.totalDuration }
        return startTime.addingTimeInterval(totalDuration)
    }

    func formatTimeRange(_ start: Date, _ end: Date) -> String {
        "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
