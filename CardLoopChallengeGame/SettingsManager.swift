import Foundation
import SwiftUI
import AVFoundation

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    @Published var isSoundEnabled = true
    @Published var isHapticEnabled = true
    @Published var isEasyMode = true
    
    static let shared = SettingsManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        loadSettings()
        setupAudioSession()
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
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
    
    // MARK: - Sound Effects
    func playCorrectSound() {
        guard isSoundEnabled else { return }
        playSound(named: "correct_sound")
    }
    
    func playWrongSound() {
        guard isSoundEnabled else { return }
        playSound(named: "wrong_sound")
    }
    
    func playWinSound() {
        guard isSoundEnabled else { return }
        playSound(named: "win_sound")
    }
    
    func playStartSound() {
        guard isSoundEnabled else { return }
        playSound(named: "start_sound")
    }
    
    private func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") ?? 
              Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}
