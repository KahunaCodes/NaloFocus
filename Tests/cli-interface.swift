#!/usr/bin/env swift

//
//  NaloFocus CLI Interface
//  Test the app functionality from the terminal
//  Run with: swift Tests/cli-interface.swift
//

import Foundation
@preconcurrency import EventKit

// MARK: - Models

struct SprintTask {
    var reminder: EKReminder?
    var duration: TimeInterval
    var hasBreak: Bool = false
    var breakDuration: TimeInterval = 5 * 60
}

struct SprintSession {
    var startTime: Date = Date()
    var tasks: [SprintTask] = []
}

// MARK: - CLI Interface

class CLIInterface {
    let eventStore = EKEventStore()
    var currentSession = SprintSession()
    var reminders: [EKReminder] = []

    func run() async {
        print("""

        ╔══════════════════════════════════════╗
        ║       NaloFocus CLI Interface       ║
        ║      Time-Blocked Sprint Planner    ║
        ╚══════════════════════════════════════╝

        """)

        await checkPermissions()

        var running = true
        while running {
            printMenu()

            if let choice = readLine() {
                switch choice {
                case "1":
                    await loadReminders()
                case "2":
                    await createSprint()
                case "3":
                    previewTimeline()
                case "4":
                    await testScheduling()
                case "5":
                    adjustSettings()
                case "q", "Q":
                    running = false
                default:
                    print("Invalid choice. Please try again.")
                }
            }
        }

        print("\n👋 Goodbye!")
    }

    func printMenu() {
        print("""

        ════════════ Main Menu ════════════
        1. Load Reminders
        2. Create Sprint Session
        3. Preview Timeline
        4. Test Sprint Scheduling
        5. Adjust Settings
        Q. Quit

        Enter choice:
        """, terminator: "")
    }

    func checkPermissions() async {
        do {
            let granted = try await eventStore.requestFullAccessToReminders()
            if !granted {
                print("""

                ⚠️  Reminders Permission Required

                Please grant permission in:
                System Settings > Privacy & Security > Reminders

                Press Enter to continue...
                """)
                _ = readLine()
            }
        } catch {
            print("Error checking permissions: \(error.localizedDescription)")
        }
    }

    func loadReminders() async {
        print("\n📋 Loading reminders...")

        do {
            let calendars = eventStore.calendars(for: .reminder)
            let predicate = eventStore.predicateForReminders(in: calendars)

            reminders = try await withCheckedThrowingContinuation { continuation in
                eventStore.fetchReminders(matching: predicate) { reminders in
                    continuation.resume(returning: reminders ?? [])
                }
            }

            // Filter incomplete reminders
            reminders = reminders.filter { !$0.isCompleted }

            print("\nFound \(reminders.count) incomplete reminder(s)")

            // Categorize and display
            let now = Date()
            var pastDue: [EKReminder] = []
            var scheduled: [EKReminder] = []
            var noTime: [EKReminder] = []

            for reminder in reminders {
                if let dueDate = reminder.dueDateComponents?.date {
                    if dueDate < now {
                        pastDue.append(reminder)
                    } else {
                        scheduled.append(reminder)
                    }
                } else {
                    noTime.append(reminder)
                }
            }

            print("\n🔴 Past Due (\(pastDue.count)):")
            for reminder in pastDue.prefix(5) {
                print("   - \(reminder.title ?? "Untitled")")
            }

            print("\n🟢 Scheduled (\(scheduled.count)):")
            for reminder in scheduled.prefix(5) {
                print("   - \(reminder.title ?? "Untitled")")
            }

            print("\n⚪ No Time Set (\(noTime.count)):")
            for reminder in noTime.prefix(5) {
                print("   - \(reminder.title ?? "Untitled")")
            }

        } catch {
            print("Error loading reminders: \(error.localizedDescription)")
        }

        print("\nPress Enter to continue...")
        _ = readLine()
    }

    func createSprint() async {
        print("\n🏃 Create Sprint Session")
        print("────────────────────────")

        // Get number of tasks
        print("\nHow many tasks? (1-9): ", terminator: "")
        let taskCount = Int(readLine() ?? "3") ?? 3
        let clampedCount = min(max(taskCount, 1), 9)

        currentSession = SprintSession()
        currentSession.startTime = Date()

        // Create tasks
        for i in 1...clampedCount {
            print("\n📝 Task \(i):")

            // Duration
            print("   Duration in minutes (default 25): ", terminator: "")
            let duration = Double(readLine() ?? "25") ?? 25

            // Break
            var hasBreak = false
            var breakDuration: Double = 5

            if i < clampedCount {
                print("   Add break after? (y/n, default y): ", terminator: "")
                let breakChoice = readLine() ?? "y"
                hasBreak = breakChoice.lowercased() == "y"

                if hasBreak {
                    print("   Break duration in minutes (default 5): ", terminator: "")
                    breakDuration = Double(readLine() ?? "5") ?? 5
                }
            }

            // Select reminder if available
            var selectedReminder: EKReminder?
            if !reminders.isEmpty {
                print("   Select reminder? (y/n): ", terminator: "")
                if (readLine() ?? "n").lowercased() == "y" {
                    print("\n   Available reminders:")
                    for (index, reminder) in reminders.prefix(10).enumerated() {
                        print("   \(index + 1). \(reminder.title ?? "Untitled")")
                    }
                    print("   Enter number (or 0 to skip): ", terminator: "")

                    if let choice = Int(readLine() ?? "0"),
                       choice > 0 && choice <= min(reminders.count, 10) {
                        selectedReminder = reminders[choice - 1]
                        print("   ✅ Selected: \(selectedReminder?.title ?? "Untitled")")
                    }
                }
            }

            let task = SprintTask(
                reminder: selectedReminder,
                duration: duration * 60,
                hasBreak: hasBreak,
                breakDuration: breakDuration * 60
            )
            currentSession.tasks.append(task)
        }

        print("\n✅ Sprint session created with \(currentSession.tasks.count) tasks")
        print("Press Enter to continue...")
        _ = readLine()
    }

    func previewTimeline() {
        print("\n📅 Timeline Preview")
        print("───────────────────")

        if currentSession.tasks.isEmpty {
            print("\n⚠️ No sprint session created yet. Create one first!")
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            var currentTime = currentSession.startTime

            print("\nStart time: \(formatter.string(from: currentTime))")
            print("─────────────────────────")

            for (index, task) in currentSession.tasks.enumerated() {
                let endTime = currentTime.addingTimeInterval(task.duration)

                print("\n📝 Task \(index + 1)")
                if let reminder = task.reminder {
                    print("   \(reminder.title ?? "Untitled")")
                }
                print("   \(formatter.string(from: currentTime)) → \(formatter.string(from: endTime))")
                print("   Duration: \(Int(task.duration / 60)) minutes")

                currentTime = endTime

                if task.hasBreak {
                    let breakEnd = currentTime.addingTimeInterval(task.breakDuration)
                    print("\n☕ Break")
                    print("   \(formatter.string(from: currentTime)) → \(formatter.string(from: breakEnd))")
                    print("   Duration: \(Int(task.breakDuration / 60)) minutes")
                    currentTime = breakEnd
                }
            }

            let totalDuration = currentSession.tasks.reduce(0) { total, task in
                total + task.duration + (task.hasBreak ? task.breakDuration : 0)
            }

            print("\n─────────────────────────")
            print("End time: \(formatter.string(from: currentTime))")
            print("Total duration: \(Int(totalDuration / 60)) minutes")
        }

        print("\nPress Enter to continue...")
        _ = readLine()
    }

    func testScheduling() async {
        print("\n🚀 Test Sprint Scheduling")
        print("─────────────────────────")

        if currentSession.tasks.isEmpty {
            print("\n⚠️ No sprint session created yet. Create one first!")
        } else if currentSession.tasks.allSatisfy({ $0.reminder == nil }) {
            print("\n⚠️ No reminders selected for tasks. Load reminders and create sprint with selections.")
        } else {
            print("\n⚠️ This will UPDATE your actual reminders!")
            print("Are you sure? (y/n): ", terminator: "")

            if (readLine() ?? "n").lowercased() == "y" {
                print("\nScheduling sprint...")

                var currentTime = currentSession.startTime
                var updatedCount = 0

                for task in currentSession.tasks {
                    if let reminder = task.reminder {
                        reminder.alarms = [EKAlarm(absoluteDate: currentTime)]
                        reminder.dueDateComponents = Calendar.current.dateComponents(
                            [.year, .month, .day, .hour, .minute],
                            from: currentTime
                        )

                        do {
                            try eventStore.save(reminder, commit: true)
                            updatedCount += 1
                            print("✅ Updated: \(reminder.title ?? "Untitled")")
                        } catch {
                            print("❌ Failed to update: \(reminder.title ?? "Untitled")")
                        }
                    }

                    currentTime = currentTime.addingTimeInterval(task.duration)

                    if task.hasBreak {
                        // Create break reminder
                        let breakReminder = EKReminder(eventStore: eventStore)
                        breakReminder.title = "Break - \(Int(task.breakDuration / 60)) min"

                        // Find or create Breaks calendar
                        let calendars = eventStore.calendars(for: .reminder)
                        let breaksCalendar = calendars.first { $0.title == "Breaks" } ??
                                            eventStore.defaultCalendarForNewReminders()

                        breakReminder.calendar = breaksCalendar
                        breakReminder.dueDateComponents = Calendar.current.dateComponents(
                            [.year, .month, .day, .hour, .minute],
                            from: currentTime
                        )
                        breakReminder.alarms = [EKAlarm(absoluteDate: currentTime)]

                        do {
                            try eventStore.save(breakReminder, commit: true)
                            print("✅ Created break reminder")
                        } catch {
                            print("❌ Failed to create break")
                        }

                        currentTime = currentTime.addingTimeInterval(task.breakDuration)
                    }
                }

                print("\n✅ Sprint scheduled! Updated \(updatedCount) reminder(s)")
                print("Check your Reminders app to see the changes.")
            } else {
                print("Scheduling cancelled.")
            }
        }

        print("\nPress Enter to continue...")
        _ = readLine()
    }

    func adjustSettings() {
        print("\n⚙️ Settings")
        print("───────────")

        print("""

        Default Settings:
        • Task duration: 25 minutes
        • Break duration: 5 minutes
        • Max tasks: 9

        Note: These are the defaults used when creating sprints.
        You can customize each task during sprint creation.

        """)

        print("Press Enter to continue...")
        _ = readLine()
    }
}

// MARK: - Main

print("Starting NaloFocus CLI...")

let cli = CLIInterface()
Task {
    await cli.run()
    exit(0)
}

RunLoop.main.run()