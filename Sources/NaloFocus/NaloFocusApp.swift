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
        MenuBarExtra("NaloFocus", systemImage: "timer") {
            MenuBarContentView()
                .environmentObject(coordinator)
        }
        .menuBarExtraStyle(.window)
    }
}
