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
            Group {
                if coordinator.permissionState == .granted {
                    SprintDialogView()
                        .environmentObject(coordinator)
                        .frame(minWidth: 800, minHeight: 600)
                } else {
                    PermissionSplashView()
                        .environmentObject(coordinator)
                }
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
        #else
        // Production mode: Menu bar app
        MenuBarExtra("NaloFocus", systemImage: "timer") {
            MenuBarContentView()
                .environmentObject(coordinator)
        }
        .menuBarExtraStyle(.window)

        // Permission Splash Window (shown first)
        Window("Welcome to NaloFocus", id: "permission-splash") {
            PermissionSplashView()
                .environmentObject(coordinator)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 600, height: 500)
        .defaultPosition(.center)

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
