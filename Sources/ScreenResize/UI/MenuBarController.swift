import AppKit
import SwiftUI

final class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?

    override init() {
        super.init()
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            if let image = NSImage(named: "MenuBarIcon") {
                image.size = NSSize(width: 24, height: 18)
                image.isTemplate = true
                button.image = image
            } else {
                let fallback = NSImage(systemSymbolName: "arrow.left.and.right", accessibilityDescription: "Screen Resize")
                fallback?.isTemplate = true
                button.image = fallback
            }
        }

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        // Snapping actions
        addMenuItem(to: menu, title: "Left Half", action: .leftHalf, keyEquivalent: "")
        addMenuItem(to: menu, title: "Right Half", action: .rightHalf, keyEquivalent: "")
        addMenuItem(to: menu, title: "Top Half", action: .topHalf, keyEquivalent: "")
        addMenuItem(to: menu, title: "Bottom Half", action: .bottomHalf, keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        addMenuItem(to: menu, title: "Upper Left", action: .upperLeft, keyEquivalent: "")
        addMenuItem(to: menu, title: "Lower Left", action: .lowerLeft, keyEquivalent: "")
        addMenuItem(to: menu, title: "Upper Right", action: .upperRight, keyEquivalent: "")
        addMenuItem(to: menu, title: "Lower Right", action: .lowerRight, keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        addMenuItem(to: menu, title: "Center", action: .center, keyEquivalent: "")
        addMenuItem(to: menu, title: "Maximize", action: .maximize, keyEquivalent: "")
        addMenuItem(to: menu, title: "Almost Maximize", action: .almostMaximize, keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        addMenuItem(to: menu, title: "Next Display", action: .nextDisplay, keyEquivalent: "")
        addMenuItem(to: menu, title: "Previous Display", action: .previousDisplay, keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        let undoItem = NSMenuItem(title: "Undo", action: #selector(undoTriggered), keyEquivalent: "z")
        undoItem.keyEquivalentModifierMask = [.option, .command]
        undoItem.target = self
        menu.addItem(undoItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Screen Resize", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    private func addMenuItem(to menu: NSMenu, title: String, action: WindowAction, keyEquivalent: String) {
        let item = NSMenuItem(title: title, action: #selector(menuActionTriggered(_:)), keyEquivalent: keyEquivalent)
        item.representedObject = action
        item.target = self
        menu.addItem(item)
    }

    @objc private func menuActionTriggered(_ sender: NSMenuItem) {
        guard let action = sender.representedObject as? WindowAction else { return }
        WindowManager.shared.perform(action)
    }

    @objc private func undoTriggered() {
        WindowManager.shared.undoLastAction()
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            let hostingController = NSHostingController(rootView: SettingsView())
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Screen Resize Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
