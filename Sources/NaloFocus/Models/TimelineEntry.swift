//
//  TimelineEntry.swift
//  NaloFocus
//
//  Data model for timeline preview entries
//

import Foundation

/// Represents a single entry in the timeline preview
struct TimelineEntry: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let title: String
    let type: EntryType

    enum EntryType {
        case task
        case breakTime
    }
}
