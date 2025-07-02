import Foundation
import SwiftUI

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    @Published var isSoundEnabled = true
    @Published var isHapticEnabled = true
    @Published var isEasyMode = true
    
    static let shared = SettingsManager()
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Persistence
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isSoundEnabled, forKey: "isSoundEnabled")
        defaults.set(isHapticEnabled, forKey: "isHapticEnabled")
        defaults.set(isEasyMode, forKey: "isEasyMode")
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        isSoundEnabled = defaults.bool(forKey: "isSoundEnabled")
        isHapticEnabled = defaults.bool(forKey: "isHapticEnabled")
        isEasyMode = defaults.bool(forKey: "isEasyMode")
        
        // Set default values on first launch
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            isSoundEnabled = true
            isHapticEnabled = true
            isEasyMode = true
            defaults.set(true, forKey: "hasLaunchedBefore")
            saveSettings()
        }
    }
    
    // MARK: - Setting Updates
    func toggleSound() {
        isSoundEnabled.toggle()
        saveSettings()
    }
    
    func toggleHaptic() {
        isHapticEnabled.toggle()
        saveSettings()
    }
    
    func toggleMode() {
        isEasyMode.toggle()
        saveSettings()
    }
    
    // MARK: - Haptic Feedback
    func performHapticFeedback() {
        guard isHapticEnabled else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func performLightHapticFeedback() {
        guard isHapticEnabled else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func performHeavyHapticFeedback() {
        guard isHapticEnabled else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
}
