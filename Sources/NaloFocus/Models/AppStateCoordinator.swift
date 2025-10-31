//
//  AppStateCoordinator.swift
//  NaloFocus
//
//  Global app state coordination
//

import Foundation
import SwiftUI

/// Coordinates global application state
@MainActor
class AppStateCoordinator: ObservableObject {
    @Published var showSprintDialog: Bool = false
    @Published var hasRemindersPermission: Bool = false

    private let services = ServiceContainer.shared

    func requestPermissions() async {
        do {
            hasRemindersPermission = try await services.reminderManager.requestAccess()
        } catch {
            print("Permission request failed: \(error)")
            hasRemindersPermission = false
        }
    }

    func toggleSprintDialog() {
        showSprintDialog.toggle()
    }
}
