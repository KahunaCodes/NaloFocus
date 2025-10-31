//
//  MenuBarContentView.swift
//  NaloFocus
//
//  Menu bar dropdown content
//

import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var coordinator: AppStateCoordinator

    var body: some View {
        VStack(spacing: 0) {
            Button("Start New Sprint") {
                openSprintDialog()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Divider()

            Button("Quit NaloFocus") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
        .padding(8)
    }

    private func openSprintDialog() {
        // This will be enhanced to actually show the sprint dialog
        coordinator.toggleSprintDialog()
    }
}
