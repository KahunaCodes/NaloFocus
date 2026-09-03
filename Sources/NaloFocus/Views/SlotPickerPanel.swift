//
//  SlotPickerPanel.swift
//  NaloFocus
//
//  Floating, non-activating panel that hosts ReminderSelectionModal over Calendar.app
//

import AppKit
import SwiftUI
@preconcurrency import EventKit

/// Backs the modal's bindings so AppKit can observe the outcome
@MainActor
final class SlotPickerModel: ObservableObject {
    @Published var isPresented = true
    @Published var selectedReminder: EKReminder?
}

/// NSPanel that takes keyboard focus without activating the app (the Spotlight pattern),
/// so Calendar stays frontmost while the user types into the picker.
@MainActor
final class SlotPickerPanel: NSPanel {
    var onCancel: (() -> Void)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    /// Escape from the field editor lands here when SwiftUI did not already claim it
    override func cancelOperation(_ sender: Any?) {
        onCancel?()
    }

    /// The red close button counts as cancel, so the placeholder is kept
    override func performClose(_ sender: Any?) {
        onCancel?()
    }
}

/// Presents the picker for one Calendar-created slot and reports pick or cancel exactly once
@MainActor
final class SlotPickerController {
    private var panel: SlotPickerPanel?
    private var model: SlotPickerModel?
    private var onPick: ((EKReminder) -> Void)?
    private var onCancel: (() -> Void)?
    private var closeObserver: NSObjectProtocol?
    private var escapeMonitor: Any?

    var isPresenting: Bool { panel != nil }

    func present(
        slot: Date,
        reminders: CategorizedReminders,
        initialSearch: String,
        onPick: @escaping (EKReminder) -> Void,
        onCancel: @escaping () -> Void
    ) {
        dismiss()
        let model = SlotPickerModel()
        self.model = model
        self.onPick = onPick
        self.onCancel = onCancel

        let content = SlotPickerContent(model: model, slot: slot, reminders: reminders, initialSearch: initialSearch) {
            [weak self] in self?.finish(with: self?.model?.selectedReminder)
        }
        let hosting = NSHostingView(rootView: content)
        let size = AppConstants.SlotPicker.panelSize
        let panel = makePanel(size: size)
        panel.contentView = hosting
        panel.onCancel = { [weak self] in self?.finish(with: nil) }
        panel.setFrameOrigin(Self.origin(for: size, near: NSEvent.mouseLocation))
        self.panel = panel

        // Any close that did not come through a pick is a cancel. The red close button and Cmd-W
        // close the window without touching the SwiftUI model, and a missed cancel left the store
        // watcher paused for good (found 2026-09-03 on the first installed build).
        closeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.panel != nil else { return }
                self.panel = nil   // already closing; dismiss() must not close it again
                self.finish(with: nil)
            }
        }
        // Escape inside the text field can be swallowed before it reaches the window, so catch it
        // at the event level while this panel is key.
        escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            MainActor.assumeIsolated {
                guard event.keyCode == 53, let panel = self?.panel, panel.isKeyWindow else { return event }
                self?.finish(with: nil)
                return nil
            }
        }

        panel.makeKeyAndOrderFront(nil)
        // SwiftUI's @FocusState asks for focus on appear; this is the AppKit belt to that brace
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak panel, weak hosting] in
            guard let panel, let hosting, let field = Self.firstTextField(in: hosting) else { return }
            panel.makeFirstResponder(field)
        }
    }

    func dismiss() {
        if let closeObserver {
            NotificationCenter.default.removeObserver(closeObserver)
        }
        closeObserver = nil
        if let escapeMonitor {
            NSEvent.removeMonitor(escapeMonitor)
        }
        escapeMonitor = nil
        onPick = nil
        onCancel = nil
        model = nil
        // Detach before closing so our own close cannot re-enter through the observer
        let closing = panel
        panel = nil
        closing?.close()
    }

    private func finish(with reminder: EKReminder?) {
        let pick = onPick
        let cancel = onCancel
        dismiss()
        if let reminder {
            pick?(reminder)
        } else {
            cancel?()
        }
    }

    private func makePanel(size: CGSize) -> SlotPickerPanel {
        let panel = SlotPickerPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.title = "Schedule into slot"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        return panel
    }

    /// Panel hangs below-right of the cursor, clamped into the visible frame of the screen under it
    private static func origin(for size: CGSize, near mouse: NSPoint) -> NSPoint {
        let screen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
        let bounds = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let proposedX = mouse.x + 12
        let proposedY = mouse.y - size.height - 12
        let x = min(max(proposedX, bounds.minX), bounds.maxX - size.width)
        let y = min(max(proposedY, bounds.minY), bounds.maxY - size.height)
        return NSPoint(x: x, y: y)
    }

    private static func firstTextField(in view: NSView) -> NSTextField? {
        if let field = view as? NSTextField, field.isEditable {
            return field
        }
        for subview in view.subviews {
            if let field = firstTextField(in: subview) {
                return field
            }
        }
        return nil
    }
}

/// Bridges the AppKit-owned model into the SwiftUI modal and reports when the modal dismisses itself
private struct SlotPickerContent: View {
    @ObservedObject var model: SlotPickerModel
    let slot: Date
    let reminders: CategorizedReminders
    let initialSearch: String
    let onDismiss: @MainActor () -> Void

    private static let slotFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d 'at' h:mm a"
        return formatter
    }()

    var body: some View {
        ReminderSelectionModal(
            isPresented: $model.isPresented,
            selectedReminder: $model.selectedReminder,
            availableReminders: reminders,
            title: "Schedule into slot",
            subtitle: Self.slotFormatter.string(from: slot),
            initialTab: 1,
            initialSearch: initialSearch,
            size: AppConstants.SlotPicker.panelSize
        )
        .onChange(of: model.isPresented) { _, presented in
            if !presented {
                onDismiss()
            }
        }
    }
}
