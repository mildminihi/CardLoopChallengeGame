import Foundation

// MARK: - Game Mode Definitions
enum GameMode: String, CaseIterable, Identifiable {
    case normal = "normal"
    case endless = "endless"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .normal:
            return "normal_mode".localized
        case .endless:
            return "endless_mode".localized
        }
    }
    
    var description: String {
        switch self {
        case .normal:
            return "normal_mode_description".localized
        case .endless:
            return "endless_mode_description".localized
        }
    }
    
    var isComingSoon: Bool {
        switch self {
        case .normal:
            return false
        case .endless:
            return false
        }
    }
    
    var icon: String {
        switch self {
        case .normal:
            return "🃏"
        case .endless:
            return "♾️"
        }
    }
}
