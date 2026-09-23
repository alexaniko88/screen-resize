import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize menu bar item and menus
        menuBarController = MenuBarController()

        // Register global keyboard shortcuts
        ShortcutsManager.shared.registerHandlers()

        // Check accessibility permissions
        if !AccessibilityManager.shared.isGranted {
            AccessibilityManager.shared.checkOrPrompt()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                if !AccessibilityManager.shared.isGranted {
                    self?.menuBarController?.openSettings()
                }
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        menuBarController?.openSettings()
        return true
    }
}
