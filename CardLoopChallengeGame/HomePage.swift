import SwiftUI

// MARK: - Home Page View
struct HomePage: View {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showingLanguagePicker = false
    @State private var showingSettings = false
    @State private var selectedGameMode: GameMode?
    
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
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 15) {
                    Text("game_title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("welcome_message".localized)
                        .font(.title3)
                        .foregroundColor(.green.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Menu Buttons
                VStack(spacing: 30) {
                    Text("select_game_mode".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        ForEach(GameMode.allCases, id: \.rawValue) { mode in
                            gameMenuButton(for: mode)
                        }
                    }
                }
                
                Spacer()
                
                // Statistics, Settings and Language buttons at bottom
                HStack {
                    // Statistics Button - Bottom Left
                    NavigationLink(destination: StatisticsView(isInGamePage: false)) {
                        Text("📊")
                            .font(.title3)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.5)
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        settingsManager.performLightHapticFeedback()
                    })
                    
                    Spacer()
                    
                    // Settings Button - Bottom Center
                    Button(action: {
                        settingsManager.performLightHapticFeedback()
                        showingSettings = true
                    }) {
                        Text("⚙️")
                            .font(.title3)
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 1.5)
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    // Language Button - Bottom Right
                    Button(action: {
                        settingsManager.performLightHapticFeedback()
                        showingLanguagePicker = true
                    }) {
                        Text(getCurrentLanguageFlag())
                            .font(.title3)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.green.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: .green.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .padding()
        }
        .alert("language_selection".localized, isPresented: $showingLanguagePicker) {
            ForEach(languageManager.availableLanguages, id: \.code) { language in
                Button("\(language.flag) \(language.name)") {
                    settingsManager.performLightHapticFeedback()
                    languageManager.setLanguage(language.code)
                }
            }
            Button("cancel".localized, role: .cancel) {
                settingsManager.performLightHapticFeedback()
            }
        } message: {
            Text("select_language".localized)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force UI refresh when language changes
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private func getCurrentLanguageFlag() -> String {
        return languageManager.availableLanguages.first { $0.code == languageManager.currentLanguage }?.flag ?? "🌐"
    }
    
    @ViewBuilder
    private func gameMenuButton(for mode: GameMode) -> some View {
        Button(action: {
            if !mode.isComingSoon {
                settingsManager.performHapticFeedback()
                selectedGameMode = mode
            }
        }) {
            HStack(spacing: 15) {
                // Mode Icon
                Text(mode.icon)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(mode.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if mode.isComingSoon {
                            Text("coming_soon".localized)
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(mode.description)
                        .font(.body)
                        .foregroundColor(.green.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if !mode.isComingSoon {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding(20)
            .background(
                Color.black.opacity(mode.isComingSoon ? 0.2 : 0.3)
            )
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        mode.isComingSoon ? Color.gray.opacity(0.3) : Color.green.opacity(0.5),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: mode.isComingSoon ? .clear : .green.opacity(0.3),
                radius: mode.isComingSoon ? 0 : 5,
                x: 0,
                y: 2
            )
        }
        .disabled(mode.isComingSoon)
        .opacity(mode.isComingSoon ? 0.6 : 1.0)
        .fullScreenCover(item: $selectedGameMode) { mode in
            if mode == .normal {
                CardChallengeGameView()
            } else {
                EndLessGameView()
            }
        }
    }
}
