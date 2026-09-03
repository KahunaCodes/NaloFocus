//
//  NaloFocusApp.swift
//  NaloFocus
//
//  Main application entry point for NaloFocus menu bar app
//

import SwiftUI

@main
struct NaloFocusApp: App {
    @StateObject private var coordinator = AppStateCoordinator()

    var body: some Scene {
        #if DEBUG
        // Development mode: Regular window app for easier testing
        WindowGroup {
            SprintDialogView()
                .environmentObject(coordinator)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
        #else
        // Production mode: Menu bar app
        // Reminders access is requested by AppStateCoordinator at launch, not here: a MenuBarExtra's
        // content only appears (and runs its .task) when the icon is first clicked, and the Calendar
        // slot picker needs the store watcher running from the moment the app starts.
        MenuBarExtra("NaloFocus", systemImage: "timer") {
            MenuBarContentView()
                .environmentObject(coordinator)
        }
        .menuBarExtraStyle(.window)

        // Sprint Dialog Window (for production menu bar mode)
        Window("Sprint Planning", id: "sprint-dialog") {
            SprintDialogView()
                .environmentObject(coordinator)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        #endif
    }
}
