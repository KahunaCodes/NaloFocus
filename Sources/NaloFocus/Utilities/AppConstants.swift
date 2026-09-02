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

    enum Logging {
        /// os.Logger subsystem; read with `log stream --predicate 'subsystem == "com.kahunacodes.NaloFocus"'`
        static let subsystem = "com.kahunacodes.NaloFocus"
    }

    /// Calendar slot picker: Calendar.app creates a reminder in a slot, NaloFocus offers an existing one instead
    enum SlotPicker {
        static let enabledDefaultsKey = "calendarSlotPickerEnabled"
        static let calendarBundleID = "com.apple.iCal"
        /// Titles Calendar gives an untouched placeholder; anything else is used to prefill the search
        static let defaultPlaceholderTitles: Set<String> = ["New Reminder", ""]
        /// Due-date window the watcher snapshots (keeps a 1,000+ item store cheap to diff)
        static let lookbackWindow: TimeInterval = 24 * 60 * 60
        static let lookaheadWindow: TimeInterval = 400 * 24 * 60 * 60
        /// A reminder older than this was not just created in front of us
        static let maxCreationAge: TimeInterval = 15
        /// Store changes arrive in bursts; wait this long for silence before diffing
        static let quiescence: TimeInterval = 0.6
        /// Ignore changes this soon after our own save (the echo of our commit)
        static let ownSaveSuppression: TimeInterval = 2
        static let panelSize = CGSize(width: 440, height: 520)
        /// Set this env var at launch to preview the panel with a fake slot (dry run, nothing is saved)
        static let testPanelEnvKey = "NALOFOCUS_TEST_PANEL"
    }
}
