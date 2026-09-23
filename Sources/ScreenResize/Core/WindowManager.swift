import AppKit
import ApplicationServices

final class WindowManager {
    static let shared = WindowManager()

    private var previousFrames: [AXUIElement: CGRect] = [:]

    private init() {}

    /// Executes the specified window management action on the currently focused window.
    func perform(_ action: WindowAction) {
        guard AccessibilityManager.shared.isGranted else {
            AccessibilityManager.shared.checkOrPrompt()
            NSSound.beep()
            return
        }

        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return }
        let appElement = AXUIElementCreateApplication(frontmostApp.processIdentifier)

        var focusedWindowValue: AnyObject?
        let copyStatus = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindowValue)
        guard copyStatus == .success, let window = focusedWindowValue as! AXUIElement? else {
            return
        }

        // Get current window frame in AX coordinates
        guard let currentAxRect = getAxFrame(for: window) else { return }

        guard let primaryScreen = NSScreen.screens.first else { return }

        // Convert to NSScreen coordinates
        let currentScreenRect = ScreenGeometry.axToScreen(rect: currentAxRect, primaryScreen: primaryScreen)

        // Find containing screen
        let currentScreen = ScreenGeometry.findScreen(for: currentScreenRect)

        // Calculate target rect in NSScreen coordinates
        let targetScreenRect = ScreenGeometry.calculateTargetRect(
            action: action,
            currentWindowRect: currentScreenRect,
            screen: currentScreen
        )

        // Convert back to AX coordinates
        let targetAxRect = ScreenGeometry.screenToAx(rect: targetScreenRect, primaryScreen: primaryScreen)

        // Save previous frame for potential undo
        previousFrames[window] = currentAxRect

        // Apply new frame to window
        setAxFrame(targetAxRect, for: window)
    }

    /// Undoes the last window move/resize on the focused window.
    func undoLastAction() {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return }
        let appElement = AXUIElementCreateApplication(frontmostApp.processIdentifier)

        var focusedWindowValue: AnyObject?
        let copyStatus = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindowValue)
        guard copyStatus == .success, let window = focusedWindowValue as! AXUIElement? else { return }

        if let previousFrame = previousFrames[window] {
            setAxFrame(previousFrame, for: window)
            previousFrames.removeValue(forKey: window)
        }
    }

    // MARK: - AX Helpers

    private func getAxFrame(for window: AXUIElement) -> CGRect? {
        var positionValue: AnyObject?
        var sizeValue: AnyObject?

        let posStatus = AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionValue)
        let sizeStatus = AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue)

        guard posStatus == .success, sizeStatus == .success,
              let posVal = positionValue, CFGetTypeID(posVal) == AXValueGetTypeID(),
              let sizeVal = sizeValue, CFGetTypeID(sizeVal) == AXValueGetTypeID() else {
            return nil
        }

        var point = CGPoint.zero
        var size = CGSize.zero

        AXValueGetValue(posVal as! AXValue, .cgPoint, &point)
        AXValueGetValue(sizeVal as! AXValue, .cgSize, &size)

        return CGRect(origin: point, size: size)
    }

    private func setAxFrame(_ rect: CGRect, for window: AXUIElement) {
        var origin = rect.origin
        var size = rect.size

        if let posVal = AXValueCreate(.cgPoint, &origin) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posVal)
        }
        if let sizeVal = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeVal)
        }
        // Set position again in case resizing shifted or clamped constraints
        if let posVal = AXValueCreate(.cgPoint, &origin) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posVal)
        }
    }
}
