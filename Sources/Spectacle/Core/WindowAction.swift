import Foundation

enum WindowAction: String, CaseIterable, Identifiable {
    case leftHalf = "left_half"
    case rightHalf = "right_half"
    case topHalf = "top_half"
    case bottomHalf = "bottom_half"

    case upperLeft = "upper_left"
    case lowerLeft = "lower_left"
    case upperRight = "upper_right"
    case lowerRight = "lower_right"

    case center = "center"
    case maximize = "maximize"
    case almostMaximize = "almost_maximize"

    case makeLarger = "make_larger"
    case makeSmaller = "make_smaller"

    case nextThird = "next_third"
    case previousThird = "previous_third"
    case centerThird = "center_third"

    case nextDisplay = "next_display"
    case previousDisplay = "previous_display"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .leftHalf: return "Left Half"
        case .rightHalf: return "Right Half"
        case .topHalf: return "Top Half"
        case .bottomHalf: return "Bottom Half"
        case .upperLeft: return "Upper Left"
        case .lowerLeft: return "Lower Left"
        case .upperRight: return "Upper Right"
        case .lowerRight: return "Lower Right"
        case .center: return "Center"
        case .maximize: return "Maximize"
        case .almostMaximize: return "Almost Maximize"
        case .makeLarger: return "Make Larger"
        case .makeSmaller: return "Make Smaller"
        case .nextThird: return "Next Third"
        case .previousThird: return "Previous Third"
        case .centerThird: return "Center Third"
        case .nextDisplay: return "Next Display"
        case .previousDisplay: return "Previous Display"
        }
    }

    var category: String {
        switch self {
        case .leftHalf, .rightHalf, .topHalf, .bottomHalf:
            return "Halves"
        case .upperLeft, .lowerLeft, .upperRight, .lowerRight:
            return "Quarters"
        case .center, .maximize, .almostMaximize, .makeLarger, .makeSmaller:
            return "Size & Position"
        case .nextThird, .previousThird, .centerThird:
            return "Thirds"
        case .nextDisplay, .previousDisplay:
            return "Displays"
        }
    }
}
