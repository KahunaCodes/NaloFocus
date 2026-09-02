//
//  AppStateCoordinator.swift
//  NaloFocus
//
//  Global app state coordination
//

import Foundation
import os
import SwiftUI
@preconcurrency import EventKit

/// Coordinates global application state
@MainActor
class AppStateCoordinator: ObservableObject {
    @Published var showSprintDialog: Bool = false
    @Published var hasRemindersPermission: Bool = false
    /// Whether Calendar-created reminders trigger the slot picker (persisted in UserDefaults)
    @Published private(set) var slotPickerEnabled: Bool

    private let services = ServiceContainer.shared
    private let logger = Logger(subsystem: AppConstants.Logging.subsystem, category: "coordinator")
    private lazy var watcher = ReminderStoreWatcher(reminderManager: services.reminderManager)
    private let picker = SlotPickerController()

    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [AppConstants.SlotPicker.enabledDefaultsKey: true])
        slotPickerEnabled = defaults.bool(forKey: AppConstants.SlotPicker.enabledDefaultsKey)
    }

    func requestPermissions() async {
        do {
            hasRemindersPermission = try await services.reminderManager.requestAccess()
        } catch {
            logger.error("Reminders access request failed: \(error.localizedDescription, privacy: .public)")
            hasRemindersPermission = false
        }
        logger.info("Reminders access granted=\(self.hasRemindersPermission)")
        syncWatcher()

        if ProcessInfo.processInfo.environment[AppConstants.SlotPicker.testPanelEnvKey] != nil {
            await presentPicker(slot: Date().addingTimeInterval(3600), placeholder: nil, dryRun: true)
        }
    }

    func toggleSprintDialog() {
        showSprintDialog.toggle()
    }

    func setSlotPickerEnabled(_ enabled: Bool) {
        slotPickerEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: AppConstants.SlotPicker.enabledDefaultsKey)
        syncWatcher()
    }

    // MARK: - Calendar slot picker

    private func syncWatcher() {
        let shouldRun = hasRemindersPermission && slotPickerEnabled
        if shouldRun, !watcher.isRunning {
            watcher.onCandidate = { [weak self] candidate in self?.handle(candidate) }
            Task { await self.watcher.start() }
        } else if !shouldRun, watcher.isRunning {
            watcher.stop()
        }
    }

    private func handle(_ candidate: SlotCandidate) {
        guard !picker.isPresenting else { return }
        watcher.isPaused = true
        Task { await self.presentPicker(slot: candidate.slot, placeholder: candidate.reminder, dryRun: false) }
    }

    private func presentPicker(slot: Date, placeholder: EKReminder?, dryRun: Bool) async {
        let manager = services.reminderManager
        let available: CategorizedReminders
        do {
            let all = try await manager.fetchReminders()
                .filter { $0.calendarItemIdentifier != placeholder?.calendarItemIdentifier }
            available = manager.categorizeReminders(all)
        } catch {
            logger.error("could not load reminders for the picker: \(error.localizedDescription, privacy: .public)")
            watcher.isPaused = false
            return
        }

        let title = placeholder?.title ?? ""
        let search = AppConstants.SlotPicker.defaultPlaceholderTitles.contains(title) ? "" : title
        let context = "slot=\(slot) placeholder='\(title)' dryRun=\(dryRun)"
        logger.info("presenting picker \(context, privacy: .public)")
        picker.present(
            slot: slot,
            reminders: available,
            initialSearch: search,
            onPick: { [weak self] picked in
                self?.schedule(picked, into: slot, replacing: placeholder, dryRun: dryRun)
            },
            onCancel: { [weak self] in
                self?.logger.info("picker cancelled; placeholder kept")
                self?.watcher.isPaused = false
            }
        )
    }

    private func schedule(_ picked: EKReminder, into slot: Date, replacing placeholder: EKReminder?, dryRun: Bool) {
        Task { [weak self] in
            guard let self else { return }
            let outcome = "'\(picked.title ?? "Untitled")' into \(slot); placeholder removed=\(placeholder != nil)"
            do {
                if dryRun {
                    logger.info("dry run: would schedule \(outcome, privacy: .public)")
                } else {
                    try await services.reminderManager.reschedule(picked, to: slot, replacing: placeholder)
                    logger.info("scheduled \(outcome, privacy: .public)")
                }
            } catch {
                logger.error("swap failed, placeholder kept: \(error.localizedDescription, privacy: .public)")
            }
            watcher.isPaused = false
        }
    }
}
