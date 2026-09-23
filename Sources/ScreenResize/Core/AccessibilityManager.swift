import AppKit
import ApplicationServices

final class AccessibilityManager {
    static let shared = AccessibilityManager()

    private init() {}

    /// Returns whether the app currently has Accessibility permissions.
    var isGranted: Bool {
        AXIsProcessTrusted()
    }

    /// Checks if accessibility permission is granted; if not, triggers the macOS system prompt.
    @discardableResult
    func checkOrPrompt() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Opens the Accessibility pane in macOS System Settings.
    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
