//
//  PermissionSplashView.swift
//  NaloFocus
//
//  Permission splash screen for Reminders access
//

import SwiftUI

/// Permission splash screen shown on first launch or when permissions are needed
struct PermissionSplashView: View {
    @EnvironmentObject var coordinator: AppStateCoordinator
    @State private var isAnimating = false
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.accentColor.opacity(0.15),
                    Color.accentColor.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App branding section
                brandingSection

                Spacer()

                // Permission explanation
                permissionExplanation

                Spacer()

                // Action section
                actionSection

                Spacer()
            }
            .padding(40)
            .frame(maxWidth: 500)
        }
        .frame(width: 600, height: 500)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .onChange(of: coordinator.permissionState) { oldValue, newValue in
            if newValue == .granted {
                // Give user a moment to see the success state
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    #if DEBUG
                    // In DEBUG mode, the view will automatically switch
                    #else
                    // In RELEASE mode, close the window
                    dismiss()
                    #endif
                }
            }
        }
    }

    // MARK: - Branding Section

    private var brandingSection: some View {
        VStack(spacing: 20) {
            // App icon representation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor.opacity(0.8),
                                Color.accentColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 20, y: 10)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)

                Image(systemName: "timer")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
            }

            // App name and tagline
            VStack(spacing: 8) {
                Text("NaloFocus")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("Transform reminders into focused work sprints")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Permission Explanation

    private var permissionExplanation: some View {
        VStack(spacing: 24) {
            // Title
            Text("Reminders Access Required")
                .font(.title2)
                .fontWeight(.semibold)

            // Features list
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "calendar.badge.clock",
                    title: "Schedule Your Tasks",
                    description: "Update reminder times to create focused work blocks"
                )

                FeatureRow(
                    icon: "list.bullet.clipboard",
                    title: "Access Your Reminders",
                    description: "View and organize reminders from all your accounts"
                )

                FeatureRow(
                    icon: "pause.circle",
                    title: "Add Breaks",
                    description: "Create break reminders to maintain productivity"
                )
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Action Section

    @ViewBuilder
    private var actionSection: some View {
        VStack(spacing: 16) {
            if coordinator.permissionState == .granted {
                // Success state
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                        .symbolEffect(.bounce, value: coordinator.permissionState)

                    Text("Access Granted!")
                        .font(.headline)
                        .foregroundColor(.green)

                    Text("Opening NaloFocus...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)
                .padding()

            } else if coordinator.permissionState == .requesting {
                // Requesting state
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding(.bottom, 4)

                    Text("Requesting permission...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)

            } else if coordinator.permissionState == .denied {
                // Denied state
                VStack(spacing: 12) {
                    Label("Access Denied", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Text("Please grant Reminders access in System Settings to use NaloFocus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Open System Settings") {
                        openSystemSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)

            } else {
                // Initial state - show grant button
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await coordinator.requestPermissions()
                        }
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Grant Access")
                        }
                        .font(.headline)
                        .frame(width: 200)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Text("NaloFocus respects your privacy and only accesses\nthe reminders you explicitly schedule")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Reminders") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Feature Row Component

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PermissionSplashView()
        .environmentObject(AppStateCoordinator())
}
