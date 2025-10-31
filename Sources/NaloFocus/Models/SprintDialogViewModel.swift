//
//  SprintDialogViewModel.swift
//  NaloFocus
//
//  ViewModel for sprint dialog management
//

import Foundation
import SwiftUI
@preconcurrency import EventKit

/// ViewModel managing sprint dialog state and operations
@MainActor
class SprintDialogViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var taskCount: Int = 3 {
        didSet { updateTasks() }
    }
    @Published var sprintSession: SprintSession = SprintSession()
    @Published var availableReminders: CategorizedReminders = CategorizedReminders()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccessMessage: Bool = false

    // MARK: - Dependencies

    private let reminderManager: ReminderManagerProtocol
    private let timeCalculator: TimeCalculatorProtocol

    init(
        reminderManager: ReminderManagerProtocol = ServiceContainer.shared.reminderManager,
        timeCalculator: TimeCalculatorProtocol = ServiceContainer.shared.timeCalculator
    ) {
        self.reminderManager = reminderManager
        self.timeCalculator = timeCalculator
        updateTasks()
    }

    // MARK: - Computed Properties

    var timelineEntries: [TimelineEntry] {
        timeCalculator.generateTimeline(from: sprintSession)
    }

    var canStartSprint: Bool {
        sprintSession.tasks.allSatisfy { $0.reminder != nil } &&
        !sprintSession.tasks.isEmpty
    }

    // MARK: - Public Methods

    func loadReminders() async {
        isLoading = true
        errorMessage = nil

        do {
            let reminders = try await reminderManager.fetchReminders()
            availableReminders = reminderManager.categorizeReminders(reminders)
        } catch {
            errorMessage = "Failed to load reminders: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func addTask() {
        guard taskCount < 9 else { return }
        taskCount += 1
    }

    func removeTask(at index: Int) {
        guard index < sprintSession.tasks.count else { return }
        sprintSession.tasks.remove(at: index)
        taskCount = sprintSession.tasks.count
    }

    func toggleBreak(for taskIndex: Int) {
        guard taskIndex < sprintSession.tasks.count else { return }
        sprintSession.tasks[taskIndex].hasBreak.toggle()
    }

    func startSprint() async {
        guard canStartSprint else { return }

        isLoading = true
        errorMessage = nil

        do {
            try await reminderManager.updateRemindersForSprint(sprintSession)
            showSuccessMessage = true

            // Reset after a brief delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            reset()
        } catch {
            errorMessage = "Failed to create sprint: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func reset() {
        sprintSession = SprintSession()
        taskCount = 3
        showSuccessMessage = false
        errorMessage = nil
        updateTasks()
    }

    // MARK: - Private Methods

    private func updateTasks() {
        let currentCount = sprintSession.tasks.count
        let targetCount = taskCount

        if targetCount > currentCount {
            // Add new tasks
            for _ in 0..<(targetCount - currentCount) {
                sprintSession.tasks.append(SprintTask(duration: 25 * 60)) // 25 min default
            }
        } else if targetCount < currentCount {
            // Remove excess tasks
            sprintSession.tasks.removeLast(currentCount - targetCount)
        }
    }
}
