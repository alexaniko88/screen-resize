import AppKit

struct ScreenGeometry {

    /// Converts an NSScreen coordinate CGRect to an AX (Accessibility) coordinate CGRect.
    static func screenToAx(rect: CGRect, primaryScreen: NSScreen) -> CGRect {
        let primaryHeight = primaryScreen.frame.height
        let axY = primaryHeight - (rect.origin.y + rect.size.height)
        return CGRect(x: rect.origin.x, y: axY, width: rect.size.width, height: rect.size.height)
    }

    /// Converts an AX coordinate CGRect to an NSScreen coordinate CGRect.
    static func axToScreen(rect: CGRect, primaryScreen: NSScreen) -> CGRect {
        let primaryHeight = primaryScreen.frame.height
        let screenY = primaryHeight - (rect.origin.y + rect.size.height)
        return CGRect(x: rect.origin.x, y: screenY, width: rect.size.width, height: rect.size.height)
    }

    /// Finds the screen that best contains the given window rect in NSScreen coordinates.
    static func findScreen(for windowRect: CGRect) -> NSScreen {
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return NSScreen.main ?? NSScreen() }

        let center = CGPoint(x: windowRect.midX, y: windowRect.midY)
        if let containingScreen = screens.first(where: { $0.frame.contains(center) }) {
            return containingScreen
        }

        // Fallback: Screen with the largest overlapping intersection
        var bestScreen = screens[0]
        var maxArea: CGFloat = 0

        for screen in screens {
            let intersection = screen.frame.intersection(windowRect)
            let area = intersection.isNull ? 0 : intersection.width * intersection.height
            if area > maxArea {
                maxArea = area
                bestScreen = screen
            }
        }

        return maxArea > 0 ? bestScreen : (NSScreen.main ?? screens[0])
    }

    /// Calculates the target window rect in NSScreen coordinates for a given action.
    static func calculateTargetRect(
        action: WindowAction,
        currentWindowRect: CGRect,
        screen: NSScreen
    ) -> CGRect {
        let vf = screen.visibleFrame

        switch action {
        case .leftHalf:
            let width = floor(vf.width / 2.0)
            return CGRect(x: vf.minX, y: vf.minY, width: width, height: vf.height)

        case .rightHalf:
            let width = floor(vf.width / 2.0)
            return CGRect(x: vf.maxX - width, y: vf.minY, width: width, height: vf.height)

        case .topHalf:
            let height = floor(vf.height / 2.0)
            return CGRect(x: vf.minX, y: vf.maxY - height, width: vf.width, height: height)

        case .bottomHalf:
            let height = floor(vf.height / 2.0)
            return CGRect(x: vf.minX, y: vf.minY, width: vf.width, height: height)

        case .upperLeft:
            let width = floor(vf.width / 2.0)
            let height = floor(vf.height / 2.0)
            return CGRect(x: vf.minX, y: vf.maxY - height, width: width, height: height)

        case .lowerLeft:
            let width = floor(vf.width / 2.0)
            let height = floor(vf.height / 2.0)
            return CGRect(x: vf.minX, y: vf.minY, width: width, height: height)

        case .upperRight:
            let width = floor(vf.width / 2.0)
            let height = floor(vf.height / 2.0)
            return CGRect(x: vf.maxX - width, y: vf.maxY - height, width: width, height: height)

        case .lowerRight:
            let width = floor(vf.width / 2.0)
            let height = floor(vf.height / 2.0)
            return CGRect(x: vf.maxX - width, y: vf.minY, width: width, height: height)

        case .center:
            let w = min(currentWindowRect.width, vf.width)
            let h = min(currentWindowRect.height, vf.height)
            let x = vf.minX + floor((vf.width - w) / 2.0)
            let y = vf.minY + floor((vf.height - h) / 2.0)
            return CGRect(x: x, y: y, width: w, height: h)

        case .maximize:
            return vf

        case .almostMaximize:
            let insetX = floor(vf.width * 0.05)
            let insetY = floor(vf.height * 0.05)
            return vf.insetBy(dx: insetX, dy: insetY)

        case .makeLarger:
            let delta: CGFloat = 50.0
            var w = min(currentWindowRect.width + delta * 2, vf.width)
            var h = min(currentWindowRect.height + delta * 2, vf.height)
            let x = max(vf.minX, min(currentWindowRect.minX - delta, vf.maxX - w))
            let y = max(vf.minY, min(currentWindowRect.minY - delta, vf.maxY - h))
            return CGRect(x: x, y: y, width: w, height: h)

        case .makeSmaller:
            let delta: CGFloat = 50.0
            let minSize: CGFloat = 200.0
            let w = max(currentWindowRect.width - delta * 2, minSize)
            let h = max(currentWindowRect.height - delta * 2, minSize)
            let x = currentWindowRect.minX + delta
            let y = currentWindowRect.minY + delta
            return CGRect(x: x, y: y, width: w, height: h)

        case .previousThird:
            let width = floor(vf.width / 3.0)
            return CGRect(x: vf.minX, y: vf.minY, width: width, height: vf.height)

        case .centerThird:
            let width = floor(vf.width / 3.0)
            let x = vf.minX + width
            return CGRect(x: x, y: vf.minY, width: width, height: vf.height)

        case .nextThird:
            let width = floor(vf.width / 3.0)
            return CGRect(x: vf.maxX - width, y: vf.minY, width: width, height: vf.height)

        case .nextDisplay, .previousDisplay:
            return calculateDisplayTransfer(
                forward: action == .nextDisplay,
                currentRect: currentWindowRect,
                currentScreen: screen
            )
        }
    }

    /// Moves the window to the next or previous display, maintaining proportional position and size.
    private static func calculateDisplayTransfer(
        forward: Bool,
        currentRect: CGRect,
        currentScreen: NSScreen
    ) -> CGRect {
        let screens = NSScreen.screens
        guard screens.count > 1,
              let currentIndex = screens.firstIndex(of: currentScreen) else {
            return currentRect
        }

        let targetIndex: Int
        if forward {
            targetIndex = (currentIndex + 1) % screens.count
        } else {
            targetIndex = (currentIndex - 1 + screens.count) % screens.count
        }

        let targetScreen = screens[targetIndex]
        let currentVF = currentScreen.visibleFrame
        let targetVF = targetScreen.visibleFrame

        // Proportional relative coordinates
        let relativeX = (currentRect.origin.x - currentVF.origin.x) / max(currentVF.width, 1.0)
        let relativeY = (currentRect.origin.y - currentVF.origin.y) / max(currentVF.height, 1.0)
        let relativeW = currentRect.width / max(currentVF.width, 1.0)
        let relativeH = currentRect.height / max(currentVF.height, 1.0)

        let newW = min(relativeW * targetVF.width, targetVF.width)
        let newH = min(relativeH * targetVF.height, targetVF.height)
        let newX = targetVF.origin.x + (relativeX * targetVF.width)
        let newY = targetVF.origin.y + (relativeY * targetVF.height)

        // Ensure window stays within target visible frame
        let clampedX = max(targetVF.minX, min(newX, targetVF.maxX - newW))
        let clampedY = max(targetVF.minY, min(newY, targetVF.maxY - newH))

        return CGRect(x: clampedX, y: clampedY, width: newW, height: newH)
    }
}
