//
//  ServiceContainer.swift
//  NaloFocus
//
//  Dependency injection container for services
//

import Foundation
import SwiftUI

/// Centralized dependency injection container
@MainActor
final class ServiceContainer: @unchecked Sendable {
    static let shared = ServiceContainer()

    lazy var reminderManager: ReminderManagerProtocol = ReminderManager()
    lazy var timeCalculator: TimeCalculatorProtocol = TimeCalculator()

    private init() {}
}

// MARK: - Environment Injection

struct ServiceEnvironmentKey: @preconcurrency EnvironmentKey {
    @MainActor
    static let defaultValue = ServiceContainer.shared
}

extension EnvironmentValues {
    @MainActor
    var services: ServiceContainer {
        get { self[ServiceEnvironmentKey.self] }
        set { self[ServiceEnvironmentKey.self] = newValue }
    }
}
