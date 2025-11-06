//
//  SprintTask.swift
//  NaloFocus
//
//  Data model for individual sprint tasks
//

import Foundation
@preconcurrency import EventKit

/// Represents a single task in a sprint session
struct SprintTask: Identifiable, @unchecked Sendable {
    let id = UUID()
    var reminder: EKReminder?
    var duration: TimeInterval
    var hasBreak: Bool = false
    var breakDuration: TimeInterval = 5 * 60 // 5 minutes default
    var symbolName: String? // Optional custom symbol for visual identification

    /// Total duration including break time if applicable
    var totalDuration: TimeInterval {
        duration + (hasBreak ? breakDuration : 0)
    }

    /// Default task symbols that can be used for visual variety
    static let defaultSymbols = [
        "star.fill",
        "bolt.fill",
        "flame.fill",
        "leaf.fill",
        "drop.fill",
        "cloud.fill",
        "moon.fill",
        "sparkle",
        "diamond.fill"
    ]

    /// Get symbol for display, using index-based default if none set
    func getSymbol(at index: Int) -> String {
        if let symbolName = symbolName {
            return symbolName
        }
        // Use modulo to cycle through symbols if more than 9 tasks
        return Self.defaultSymbols[index % Self.defaultSymbols.count]
    }
}
