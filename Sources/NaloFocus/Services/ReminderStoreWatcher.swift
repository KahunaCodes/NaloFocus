//
//  ReminderStoreWatcher.swift
//  NaloFocus
//
//  Detects reminders that Calendar.app just created in a time slot by diffing the store on every change
//

import AppKit
import Foundation
import os
@preconcurrency import EventKit

/// A reminder that appeared in the store moments ago while Calendar.app was frontmost
struct SlotCandidate {
    let reminder: EKReminder
    let slot: Date
}

/// Snapshot-and-diff observer over the reminder store.
///
/// `.EKEventStoreChanged` is coalesced and carries no payload, so the only reliable "what is new"
/// is to re-fetch and diff identifiers. Bursts are settled with a short quiescence wait so a
/// reminder Calendar is still writing is evaluated once, in its final shape.
@MainActor
final class ReminderStoreWatcher {
    private let reminderManager: ReminderManagerProtocol
    private let logger = Logger(subsystem: AppConstants.Logging.subsystem, category: "watcher")
    private var observer: NSObjectProtocol?
    private var isStarting = false
    private var knownIdentifiers: Set<String> = []
    private var quiescenceTask: Task<Void, Never>?
    private var burstStartedAt: Date?
    private var frontmostAtBurstStart: String?

    /// While set, changes keep the snapshot current but never produce a candidate (a picker is open)
    var isPaused = false
    var onCandidate: ((SlotCandidate) -> Void)?

    var isRunning: Bool { observer != nil }

    init(reminderManager: ReminderManagerProtocol) {
        self.reminderManager = reminderManager
    }

    func start() async {
        guard observer == nil, !isStarting else { return }
        isStarting = true
        defer { isStarting = false }
        await refreshSnapshot(report: nil)
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: reminderManager.eventStore,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.storeDidChange() }
        }
        logger.info("started; tracking \(self.knownIdentifiers.count) incomplete reminders in window")
    }

    func stop() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        quiescenceTask?.cancel()
        quiescenceTask = nil
        burstStartedAt = nil
        frontmostAtBurstStart = nil
        logger.info("stopped")
    }

    // MARK: - Change handling

    private struct BurstContext {
        let startedAt: Date
        let frontmost: String?
    }

    private func storeDidChange() {
        if burstStartedAt == nil {
            burstStartedAt = Date()
            frontmostAtBurstStart = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
            logger.debug("store changed; frontmost=\(self.frontmostAtBurstStart ?? "none", privacy: .public)")
        } else {
            logger.debug("store changed again inside burst")
        }
        quiescenceTask?.cancel()
        quiescenceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(AppConstants.SlotPicker.quiescence))
            guard !Task.isCancelled else { return }
            await self?.settleBurst()
        }
    }

    private func settleBurst() async {
        let burst = BurstContext(startedAt: burstStartedAt ?? Date(), frontmost: frontmostAtBurstStart)
        burstStartedAt = nil
        frontmostAtBurstStart = nil
        await refreshSnapshot(report: burst)
    }

    /// Re-fetches the window and updates `knownIdentifiers`; reports new reminders when `burst` is set
    private func refreshSnapshot(report burst: BurstContext?) async {
        let now = Date()
        let reminders: [EKReminder]
        do {
            reminders = try await reminderManager.fetchIncompleteReminders(
                dueBetween: now.addingTimeInterval(-AppConstants.SlotPicker.lookbackWindow),
                and: now.addingTimeInterval(AppConstants.SlotPicker.lookaheadWindow)
            )
        } catch {
            logger.error("fetch failed, keeping previous snapshot: \(error.localizedDescription, privacy: .public)")
            return
        }

        let current = Set(reminders.map(\.calendarItemIdentifier))
        let newIdentifiers = current.subtracting(knownIdentifiers)
        knownIdentifiers = current
        guard let burst, !newIdentifiers.isEmpty else { return }

        let fresh = reminders.filter { newIdentifiers.contains($0.calendarItemIdentifier) }
        let candidates = fresh.compactMap { classify($0, now: now, burst: burst) }
        if fresh.count > 1 {
            logger.notice("\(fresh.count) new reminders in one burst, \(candidates.count) candidate(s)")
        }
        guard let candidate = candidates.first else { return }
        onCandidate?(candidate)
    }

    /// Applies every gate in order and logs the first one that fails
    private func classify(_ reminder: EKReminder, now: Date, burst: BurstContext) -> SlotCandidate? {
        let title = reminder.title ?? ""
        let age = reminder.creationDate.map { now.timeIntervalSince($0) }
        let notifyLatency = reminder.creationDate.map { burst.startedAt.timeIntervalSince($0) }
        let seconds = { (value: TimeInterval?) in value.map { String(format: "%.2fs", $0) } ?? "unknown" }
        let facts = "timed=\(reminder.hasTimedDueDate) frontmost=\(burst.frontmost ?? "none")"
            + " age=\(seconds(age)) notifyLatency=\(seconds(notifyLatency))"
            + " burst=\(seconds(now.timeIntervalSince(burst.startedAt)))"
        logger.info("new reminder '\(title, privacy: .public)' \(facts, privacy: .public)")

        if isPaused {
            return reject(title, "picker already open")
        }
        if now.timeIntervalSince(reminderManager.lastOwnSaveAt) < AppConstants.SlotPicker.ownSaveSuppression {
            return reject(title, "echo of our own save")
        }
        if burst.frontmost != AppConstants.SlotPicker.calendarBundleID {
            return reject(title, "Calendar not frontmost")
        }
        guard let age, age < AppConstants.SlotPicker.maxCreationAge else {
            return reject(title, "not freshly created")
        }
        guard reminder.hasTimedDueDate, let slot = reminder.resolvedDueDate else {
            return reject(title, "no timed due date")
        }
        return SlotCandidate(reminder: reminder, slot: slot)
    }

    private func reject(_ title: String, _ reason: String) -> SlotCandidate? {
        logger.info("ignoring '\(title, privacy: .public)': \(reason, privacy: .public)")
        return nil
    }
}
