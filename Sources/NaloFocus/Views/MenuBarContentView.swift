//
//  MenuBarContentView.swift
//  NaloFocus
//
//  Menu bar dropdown content
//

import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var coordinator: AppStateCoordinator
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Header with permission status
            HStack {
                Image(systemName: "timer")
                    .font(.title2)
                Text("NaloFocus")
                    .font(.headline)
                Spacer()
                Image(systemName: coordinator.hasRemindersPermission ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(coordinator.hasRemindersPermission ? .green : .orange)
                    .help(coordinator.hasRemindersPermission ? "Reminders access granted" : "Reminders access needed")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Main actions
            VStack(alignment: .leading, spacing: 4) {
                Button(action: openSprintDialog) {
                    Label("Start New Sprint", systemImage: "play.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .keyboardShortcut("n", modifiers: [.command])
                .buttonStyle(.plain)
                .disabled(!coordinator.hasRemindersPermission)

                if !coordinator.hasRemindersPermission {
                    Button(action: requestPermissions) {
                        Label("Grant Reminders Access", systemImage: "key")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)

            Divider()

            // Footer
            Button("Quit NaloFocus") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 250)
    }

    private func openSprintDialog() {
        openWindow(id: "sprint-dialog")
    }

    private func requestPermissions() {
        Task {
            await coordinator.requestPermissions()
        }
    }
}
