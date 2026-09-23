import SwiftUI
import ServiceManagement
import KeyboardShortcuts

struct SettingsView: View {
    @State private var isAccessibilityGranted: Bool = AccessibilityManager.shared.isGranted
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @State private var selectedTab: SettingsTab = .shortcuts

    enum SettingsTab: String, CaseIterable, Identifiable {
        case shortcuts = "Shortcuts"
        case general = "General"
        case about = "About"

        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            switch selectedTab {
            case .shortcuts:
                shortcutsView
            case .general:
                generalView
            case .about:
                aboutView
            }
        }
        .frame(width: 520, height: 500)
        .onAppear {
            checkPermissions()
        }
    }

    // MARK: - Shortcuts Tab

    private var shortcutsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let categories = ["Halves", "Quarters", "Size & Position", "Thirds", "Displays"]

                ForEach(categories, id: \.self) { category in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)

                        let actions = WindowAction.allCases.filter { $0.category == category }
                        VStack(spacing: 6) {
                            ForEach(actions) { action in
                                HStack {
                                    Text(action.displayName)
                                        .font(.body)
                                    Spacer()
                                    KeyboardShortcuts.Recorder(for: action.shortcutName)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - General Tab

    private var generalView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Accessibility permission card
            GroupBox(label: Label("Accessibility Permission", systemImage: "hand.raised.fill")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Circle()
                            .fill(isAccessibilityGranted ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)

                        Text(isAccessibilityGranted ? "Permission Granted" : "Permission Required")
                            .font(.subheadline)
                            .bold()

                        Spacer()

                        if !isAccessibilityGranted {
                            Button("Open Settings") {
                                AccessibilityManager.shared.openSystemSettings()
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Check Again") {
                                checkPermissions()
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Text("Spectacle requires Accessibility permissions to resize and arrange windows on your desktop.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }

            // Launch at login card
            GroupBox(label: Label("Startup", systemImage: "gearshape.fill")) {
                Toggle("Launch Spectacle at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        toggleLaunchAtLogin(newValue)
                    }
                    .padding(8)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - About Tab

    private var aboutView: some View {
        VStack(spacing: 16) {
            Spacer()

            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 96, height: 96)
                    .cornerRadius(18)
            } else {
                Image(systemName: "arrow.left.and.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.accentColor)
            }

            Text("Spectacle")
                .font(.title)
                .bold()

            Text("Version 1.0 (Swift)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("A modern, lightweight window manager for macOS written in Swift.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private func checkPermissions() {
        isAccessibilityGranted = AccessibilityManager.shared.isGranted
    }

    private func toggleLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            print("Failed to update launch at login: \(error.localizedDescription)")
        }
    }
}
