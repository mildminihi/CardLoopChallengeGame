import SwiftUI

// MARK: - Settings Page View
struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark green background matching game theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.1),
                    Color(red: 0.05, green: 0.2, blue: 0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .onTapGesture {
                        settingsManager.performLightHapticFeedback()
                    }
                    
                    Spacer()
                    
                    Text("settings_title".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer to center the title
                    Circle()
                        .frame(width: 40, height: 40)
                        .opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Settings Content
                ScrollView {
                    VStack(spacing: 25) {
                        // Audio Settings Section
                        settingSection(
                            title: "audio_settings".localized,
                            icon: "speaker.wave.3.fill"
                        ) {
                            settingToggleRow(
                                title: "sound_effects".localized,
                                description: "sound_effects_description".localized,
                                isOn: $settingsManager.isSoundEnabled,
                                isEnabled: true,
                                action: {
                                    settingsManager.toggleSound()
                                    if settingsManager.isHapticEnabled {
                                        settingsManager.performHapticFeedback()
                                    }
                                }
                            )
                        }
                        
                        // Haptic Settings Section
                        settingSection(
                            title: "haptic_settings".localized,
                            icon: "iphone.radiowaves.left.and.right"
                        ) {
                            settingToggleRow(
                                title: "haptic_feedback".localized,
                                description: "enable_haptic_description".localized,
                                isOn: $settingsManager.isHapticEnabled,
                                isEnabled: true,
                                action: {
                                    settingsManager.toggleHaptic()
                                    // Give immediate feedback when toggling
                                    if settingsManager.isHapticEnabled {
                                        settingsManager.performHapticFeedback()
                                    }
                                }
                            )
                        }
                        
                        settingSection(
                            title: "easy_mode_settings".localized,
                            icon: "face.smiling.fill"
                        ) {
                            settingToggleRow(
                                title: "easy_mode".localized,
                                description: "easy_mode_description".localized,
                                isOn: $settingsManager.isEasyMode,
                                isEnabled: true,
                                action: {
                                    settingsManager.toggleMode()
                                    
                                    if settingsManager.isHapticEnabled {
                                        settingsManager.performHapticFeedback()
                                    }
                                }
                            )
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force UI refresh when language changes
        }
    }
    
    @ViewBuilder
    private func settingSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            content()
        }
        .padding(20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func settingToggleRow(
        title: String,
        description: String,
        isOn: Binding<Bool>,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1.0 : 0.5)
                .onChange(of: isOn.wrappedValue) { _ in
                    if isEnabled {
                        action()
                    }
                }
        }
    }
}

#Preview {
    SettingsView()
}
