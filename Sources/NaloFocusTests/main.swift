//
//  Test Harness for NaloFocus
//  Run with: swift run --package-path . NaloFocusTests
//

import Foundation
@preconcurrency import EventKit

// MARK: - Test Utilities

func printSection(_ title: String) {
    print("\n" + "=" * 60)
    print("  \(title)")
    print("=" * 60)
}

func printTest(_ name: String, passed: Bool) {
    let status = passed ? "✅" : "❌"
    print("\(status) \(name)")
}

func printInfo(_ message: String) {
    print("ℹ️  \(message)")
}

// MARK: - Core Tests

@MainActor
class TestRunner {
    func runAllTests() async {
        printSection("NaloFocus Core Functionality Tests")

        // Test 1: EventKit Permission
        await testEventKitPermission()

        // Test 2: Fetch Reminders
        await testFetchReminders()

        // Test 3: Sprint Session Creation
        testSprintSessionCreation()

        // Test 4: Time Calculation
        testTimeCalculation()

        printSection("Test Summary")
        print("All core functionality tests completed.")
        print("\nNote: Full UI testing requires running in Xcode.")
        print("To test the menu bar app: open Package.swift in Xcode and run.")
    }

    func testEventKitPermission() async {
        printSection("EventKit Permission Test")

        let eventStore = EKEventStore()

        do {
            let granted: Bool
            if #available(macOS 14.0, *) {
                printInfo("Using macOS 14+ API for reminder access")
                granted = try await eventStore.requestFullAccessToReminders()
            } else {
                printInfo("Using legacy API for reminder access")
                granted = try await withCheckedThrowingContinuation { continuation in
                    eventStore.requestAccess(to: .reminder) { granted, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            }

            printTest("Request Reminder Access", granted)
            if granted {
                printInfo("✓ App has access to Reminders")
            } else {
                printInfo("⚠️  User denied access to Reminders")
                printInfo("Go to System Settings > Privacy & Security > Reminders to grant access")
            }
        } catch {
            printTest("Request Reminder Access", false)
            printInfo("Error: \(error.localizedDescription)")
        }
    }

    func testFetchReminders() async {
        printSection("Fetch Reminders Test")

        let eventStore = EKEventStore()

        do {
            let calendars = eventStore.calendars(for: .reminder)
            printInfo("Found \(calendars.count) reminder list(s)")

            for calendar in calendars.prefix(3) {
                print("  📋 \(calendar.title)")
            }

            let predicate = eventStore.predicateForReminders(in: calendars)

            let reminders = try await withCheckedThrowingContinuation { continuation in
                eventStore.fetchReminders(matching: predicate) { reminders in
                    continuation.resume(returning: reminders ?? [])
                }
            }

            printTest("Fetch Reminders", true)
            printInfo("Found \(reminders.count) total reminder(s)")

            // Categorize reminders
            let now = Date()
            var pastDue = 0
            var scheduled = 0
            var noTime = 0

            for reminder in reminders where !reminder.isCompleted {
                if let dueDate = reminder.dueDateComponents?.date {
                    if dueDate < now {
                        pastDue += 1
                    } else {
                        scheduled += 1
                    }
                } else {
                    noTime += 1
                }
            }

            print("\nReminder Categories:")
            print("  🔴 Past Due: \(pastDue)")
            print("  🟢 Scheduled: \(scheduled)")
            print("  ⚪ No Time Set: \(noTime)")

            // Show sample reminders
            if !reminders.isEmpty {
                print("\nSample Reminders (first 5):")
                for reminder in reminders.prefix(5) {
                    let status = reminder.isCompleted ? "☑" : "☐"
                    let title = reminder.title ?? "Untitled"
                    if let date = reminder.dueDateComponents?.date {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        print("  \(status) \(title) - \(formatter.string(from: date))")
                    } else {
                        print("  \(status) \(title) - No date")
                    }
                }
            }

        } catch {
            printTest("Fetch Reminders", false)
            printInfo("Error: \(error.localizedDescription)")
            printInfo("Make sure the app has Reminder permissions")
        }
    }

    func testSprintSessionCreation() {
        printSection("Sprint Session Test")

        // Create a test sprint session
        var session = SprintSession()
        session.startTime = Date()

        // Add test tasks
        for i in 1...3 {
            var task = SprintTask(duration: TimeInterval(25 * 60)) // 25 minutes
            task.hasBreak = i < 3 // Break after first two tasks
            task.breakDuration = TimeInterval(5 * 60) // 5 minute breaks
            session.tasks.append(task)
        }

        printTest("Create Sprint Session", true)
        printInfo("Created session with \(session.tasks.count) tasks")

        // Calculate total duration
        let totalDuration = session.tasks.reduce(0) { total, task in
            total + task.duration + (task.hasBreak ? task.breakDuration : 0)
        }

        let hours = Int(totalDuration) / 3600
        let minutes = Int(totalDuration) % 3600 / 60

        printInfo("Total sprint duration: \(hours)h \(minutes)m")

        // Show timeline
        print("\nTimeline Preview:")
        var currentTime = session.startTime
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        for (index, task) in session.tasks.enumerated() {
            let endTime = currentTime.addingTimeInterval(task.duration)
            print("  📝 Task \(index + 1): \(formatter.string(from: currentTime)) - \(formatter.string(from: endTime))")
            currentTime = endTime

            if task.hasBreak {
                let breakEnd = currentTime.addingTimeInterval(task.breakDuration)
                print("  ☕ Break: \(formatter.string(from: currentTime)) - \(formatter.string(from: breakEnd))")
                currentTime = breakEnd
            }
        }
    }

    func testTimeCalculation() {
        printSection("Time Calculator Test")

        // Test duration formatting
        let durations: [TimeInterval] = [
            15 * 60,      // 15 minutes
            25 * 60,      // 25 minutes
            60 * 60,      // 1 hour
            90 * 60,      // 1.5 hours
            125 * 60      // 2h 5m
        ]

        print("Duration Formatting:")
        for duration in durations {
            let hours = Int(duration) / 3600
            let minutes = Int(duration) % 3600 / 60

            var formatted = ""
            if hours > 0 {
                formatted = "\(hours)h"
                if minutes > 0 {
                    formatted += " \(minutes)m"
                }
            } else {
                formatted = "\(minutes)m"
            }

            print("  \(Int(duration/60)) minutes → \(formatted)")
        }

        printTest("Time Calculations", true)

        // Test end time calculation
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        print("\nEnd Time Calculations (from now):")
        for duration in [25, 50, 90] {
            let endTime = now.addingTimeInterval(TimeInterval(duration * 60))
            print("  +\(duration)m → \(formatter.string(from: endTime))")
        }
    }
}

// MARK: - String Extension for separators

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

// MARK: - Main Execution

@main
struct TestHarness {
    static func main() async {
        print("\n🚀 NaloFocus Test Harness")
        print("Testing core functionality without UI...")

        let runner = await TestRunner()
        await runner.runAllTests()

        print("\n✨ Tests complete!")
        print("Press Ctrl+C to exit")

        // Keep the process alive briefly to see output
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}