//
//  AppStateCoordinator.swift
//  NaloFocus
//
//  Global app state coordination
//

import Foundation
import SwiftUI

/// Permission state for tracking user authorization
enum PermissionState {
    case notDetermined
    case requesting
    case granted
    case denied
}

/// Coordinates global application state
@MainActor
class AppStateCoordinator: ObservableObject {
    @Published var showSprintDialog: Bool = false
    @Published var hasRemindersPermission: Bool = false
    @Published var permissionState: PermissionState = .notDetermined

    private let services = ServiceContainer.shared

    func requestPermissions() async {
        permissionState = .requesting

        do {
            let granted = try await services.reminderManager.requestAccess()
            hasRemindersPermission = granted
            permissionState = granted ? .granted : .denied
        } catch {
            // TODO: Implement proper logging system
            // For now, silently fail and show error in UI
            print("Error requesting permissions: \(error)")
            hasRemindersPermission = false
            permissionState = .denied
        }
    }

    func toggleSprintDialog() {
        showSprintDialog.toggle()
    }
}
