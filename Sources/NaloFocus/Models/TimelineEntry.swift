//
//  TimelineEntry.swift
//  NaloFocus
//
//  Data model for timeline preview entries
//

import Foundation
import AppKit

/// Represents a single entry in the timeline preview
struct TimelineEntry: Identifiable, Sendable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let title: String
    let type: EntryType
    let calendarColor: NSColor?

    enum EntryType: Sendable {
        case task
        case breakTime
    }

    init(startTime: Date, endTime: Date, title: String, type: EntryType, calendarColor: NSColor? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.type = type
        self.calendarColor = calendarColor
    }
}
