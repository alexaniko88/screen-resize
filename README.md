# Spectacle (Swift Clone)

A modern, fast, and lightweight clone of the classic **Spectacle** window manager for macOS, rewritten completely in Swift.

![Spectacle](Sources/Spectacle/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

## Highlights

- **Pure Swift**: Written from the ground up in modern Swift and SwiftUI.
- **Modern macOS Support**: Fully compatible with macOS 13.0 (Ventura), macOS 14.0 (Sonoma), macOS 15.0 (Sequoia), and future versions.
- **Lightweight Menu Bar App**: Runs quietly in the menu bar (`LSUIElement`) with zero unnecessary overhead.
- **Customizable Global Hotkeys**: Uses [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) for recording and managing shortcuts.
- **Multi-Monitor Support**: Effortlessly move and scale windows across multiple displays.
- **Launch at Login**: Native toggle supported via modern macOS `SMAppService`.

---

## Default Shortcuts

| Action | Shortcut |
| :--- | :--- |
| **Left Half** | `⌥ ⌘ ←` |
| **Right Half** | `⌥ ⌘ →` |
| **Top Half** | `⌥ ⌘ ↑` |
| **Bottom Half** | `⌥ ⌘ ↓` |
| **Upper Left** | `⌃ ⌘ ←` |
| **Lower Left** | `⌃ ⇧ ⌘ ←` |
| **Upper Right** | `⌃ ⌘ →` |
| **Lower Right** | `⌃ ⇧ ⌘ →` |
| **Center** | `⌥ ⌘ C` |
| **Maximize** | `⌥ ⌘ F` |
| **Almost Maximize** | `⌥ ⇧ ⌘ F` |
| **Make Larger** | `⌃ ⌥ =` |
| **Make Smaller** | `⌃ ⌥ -` |
| **Next Third** | `⌃ ⌥ →` |
| **Previous Third** | `⌃ ⌥ ←` |
| **Center Third** | `⌃ ⌥ C` |
| **Next Display** | `⌃ ⌥ ⌘ →` |
| **Previous Display** | `⌃ ⌥ ⌘ ←` |
| **Undo** | `⌥ ⌘ Z` |

---

## Getting Started

### Prerequisites

- macOS 13.0 or higher
- Xcode 15 or higher
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Building the Project

1. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

2. Open the project in Xcode:
   ```bash
   open Spectacle.xcodeproj
   ```
   Or build from the terminal:
   ```bash
   xcodebuild -scheme Spectacle -configuration Release build
   ```

3. **Grant Accessibility Permission**:
   On first launch, macOS will ask for Accessibility permissions. Enable Spectacle under:
   **System Settings > Privacy & Security > Accessibility**

---

## License

MIT License.
