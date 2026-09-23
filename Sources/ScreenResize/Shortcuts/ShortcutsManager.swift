import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let leftHalf = Self("leftHalf", default: .init(.leftArrow, modifiers: [.option, .command]))
    static let rightHalf = Self("rightHalf", default: .init(.rightArrow, modifiers: [.option, .command]))
    static let topHalf = Self("topHalf", default: .init(.upArrow, modifiers: [.option, .command]))
    static let bottomHalf = Self("bottomHalf", default: .init(.downArrow, modifiers: [.option, .command]))

    static let upperLeft = Self("upperLeft", default: .init(.leftArrow, modifiers: [.control, .command]))
    static let lowerLeft = Self("lowerLeft", default: .init(.leftArrow, modifiers: [.control, .shift, .command]))
    static let upperRight = Self("upperRight", default: .init(.rightArrow, modifiers: [.control, .command]))
    static let lowerRight = Self("lowerRight", default: .init(.rightArrow, modifiers: [.control, .shift, .command]))

    static let center = Self("center", default: .init(.c, modifiers: [.option, .command]))
    static let maximize = Self("maximize", default: .init(.f, modifiers: [.option, .command]))
    static let almostMaximize = Self("almostMaximize", default: .init(.f, modifiers: [.option, .shift, .command]))

    static let makeLarger = Self("makeLarger", default: .init(.equal, modifiers: [.control, .option]))
    static let makeSmaller = Self("makeSmaller", default: .init(.minus, modifiers: [.control, .option]))

    static let nextThird = Self("nextThird", default: .init(.rightArrow, modifiers: [.control, .option]))
    static let previousThird = Self("previousThird", default: .init(.leftArrow, modifiers: [.control, .option]))
    static let centerThird = Self("centerThird", default: .init(.c, modifiers: [.control, .option]))

    static let nextDisplay = Self("nextDisplay", default: .init(.rightArrow, modifiers: [.control, .option, .command]))
    static let previousDisplay = Self("previousDisplay", default: .init(.leftArrow, modifiers: [.control, .option, .command]))
}

extension WindowAction {
    var shortcutName: KeyboardShortcuts.Name {
        switch self {
        case .leftHalf: return .leftHalf
        case .rightHalf: return .rightHalf
        case .topHalf: return .topHalf
        case .bottomHalf: return .bottomHalf
        case .upperLeft: return .upperLeft
        case .lowerLeft: return .lowerLeft
        case .upperRight: return .upperRight
        case .lowerRight: return .lowerRight
        case .center: return .center
        case .maximize: return .maximize
        case .almostMaximize: return .almostMaximize
        case .makeLarger: return .makeLarger
        case .makeSmaller: return .makeSmaller
        case .nextThird: return .nextThird
        case .previousThird: return .previousThird
        case .centerThird: return .centerThird
        case .nextDisplay: return .nextDisplay
        case .previousDisplay: return .previousDisplay
        }
    }
}

final class ShortcutsManager {
    static let shared = ShortcutsManager()

    private init() {}

    func registerHandlers() {
        for action in WindowAction.allCases {
            KeyboardShortcuts.onKeyDown(for: action.shortcutName) {
                WindowManager.shared.perform(action)
            }
        }
    }
}
