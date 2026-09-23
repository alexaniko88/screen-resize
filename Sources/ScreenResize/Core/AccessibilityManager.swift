import AppKit
import ApplicationServices

final class AccessibilityManager {
    static let shared = AccessibilityManager()

    private var hasPrompted = false

    private init() {}

    /// Returns whether the app currently has Accessibility permissions.
    var isGranted: Bool {
        AXIsProcessTrusted()
    }

    /// Checks if accessibility permission is granted; if not, triggers the macOS system prompt.
    /// The prompt is shown at most once per launch so repeated shortcuts don't spam it.
    @discardableResult
    func checkOrPrompt() -> Bool {
        guard !hasPrompted else { return isGranted }
        hasPrompted = true
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
