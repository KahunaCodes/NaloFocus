//
//  AppConstants.swift
//  NaloFocus
//
//  Application-wide constants and configuration
//

import Foundation
import CoreGraphics

enum AppConstants {
    enum Duration {
        /// Available duration presets in seconds
        static let presets: [TimeInterval] = [
            5 * 60,   // 5 min
            10 * 60,  // 10 min
            15 * 60,  // 15 min
            20 * 60,  // 20 min
            25 * 60,  // 25 min (default)
            30 * 60,  // 30 min
            45 * 60,  // 45 min
            60 * 60,  // 60 min
            90 * 60   // 90 min
        ]

        /// Available break duration presets in seconds
        static let breakPresets: [TimeInterval] = [
            5 * 60,   // 5 min (default)
            10 * 60,  // 10 min
            15 * 60,  // 15 min
            20 * 60   // 20 min
        ]

        /// Default task duration
        static let defaultTaskDuration: TimeInterval = 25 * 60

        /// Default break duration
        static let defaultBreakDuration: TimeInterval = 5 * 60
    }

    enum UI {
        static let maxTaskCount = 9
        static let minTaskCount = 1
        static let defaultTaskCount = 3
        static let reminderPickerWidth: CGFloat = 250
        static let durationPickerWidth: CGFloat = 100
    }

    enum Strings {
        static let appName = "NaloFocus"
        static let breaksListName = "Breaks"
        static let successMessageFormat = "✓ Sprint scheduled! First task at %@"
        static let permissionDeniedMessage = "NaloFocus needs permission to access your reminders"
    }
}
