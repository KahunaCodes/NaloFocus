#!/usr/bin/env swift

//
//  Test Core Functionality
//  Run with: swift Tests/test-core.swift
//

import Foundation
@preconcurrency import EventKit

// Simple models for testing (mirror the actual models)
struct SprintTask {
    var duration: TimeInterval
    var hasBreak: Bool = false
    var breakDuration: TimeInterval = 5 * 60
}

struct SprintSession {
    var startTime: Date = Date()
    var tasks: [SprintTask] = []
}

// Test functions
func testEventKitPermission() async {
    print("\n===== EventKit Permission Test =====")

    let eventStore = EKEventStore()

    do {
        let granted: Bool
        if #available(macOS 14.0, *) {
            print("Using macOS 14+ API for reminder access")
            granted = try await eventStore.requestFullAccessToReminders()
        } else {
            print("Using legacy API for reminder access")
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

        if granted {
            print("✅ App has access to Reminders")
        } else {
            print("⚠️ User denied access to Reminders")
            print("   Go to System Settings > Privacy & Security > Reminders")
        }
    } catch {
        print("❌ Error: \(error.localizedDescription)")
    }
}

func testFetchReminders() async {
    print("\n===== Fetch Reminders Test =====")

    let eventStore = EKEventStore()

    do {
        let calendars = eventStore.calendars(for: .reminder)
        print("Found \(calendars.count) reminder list(s):")

        for calendar in calendars.prefix(3) {
            print("  📋 \(calendar.title)")
        }

        let predicate = eventStore.predicateForReminders(in: calendars)

        let reminders = try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }

        print("✅ Found \(reminders.count) total reminder(s)")

        // Categorize
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

        // Show first 3 reminders
        if !reminders.isEmpty {
            print("\nFirst 3 reminders:")
            for reminder in reminders.prefix(3) {
                let status = reminder.isCompleted ? "☑" : "☐"
                let title = reminder.title ?? "Untitled"
                print("  \(status) \(title)")
            }
        }

    } catch {
        print("❌ Error: \(error.localizedDescription)")
    }
}

func testSprintSession() {
    print("\n===== Sprint Session Test =====")

    var session = SprintSession()

    // Add 3 test tasks
    for i in 1...3 {
        let task = SprintTask(
            duration: TimeInterval(25 * 60),
            hasBreak: i < 3,
            breakDuration: TimeInterval(5 * 60)
        )
        session.tasks.append(task)
    }

    print("✅ Created session with \(session.tasks.count) tasks")

    // Calculate total duration
    let totalDuration = session.tasks.reduce(0) { total, task in
        total + task.duration + (task.hasBreak ? task.breakDuration : 0)
    }

    let hours = Int(totalDuration) / 3600
    let minutes = Int(totalDuration) % 3600 / 60

    print("Total duration: \(hours)h \(minutes)m")

    // Show timeline
    print("\nTimeline:")
    var currentTime = session.startTime
    let formatter = DateFormatter()
    formatter.timeStyle = .short

    for (index, task) in session.tasks.enumerated() {
        let endTime = currentTime.addingTimeInterval(task.duration)
        print("  Task \(index + 1): \(formatter.string(from: currentTime)) - \(formatter.string(from: endTime))")
        currentTime = endTime

        if task.hasBreak {
            let breakEnd = currentTime.addingTimeInterval(task.breakDuration)
            print("  Break: \(formatter.string(from: currentTime)) - \(formatter.string(from: breakEnd))")
            currentTime = breakEnd
        }
    }
}

// Main execution
print("\n🚀 NaloFocus Core Functionality Test")
print("====================================")

// Run tests
Task {
    await testEventKitPermission()
    await testFetchReminders()
    testSprintSession()

    print("\n✨ Tests complete!")
    print("\nTo test the full UI:")
    print("1. Open Package.swift in Xcode")
    print("2. Select NaloFocus target")
    print("3. Run (⌘R)")

    exit(0)
}

// Keep alive for async tasks
RunLoop.main.run()