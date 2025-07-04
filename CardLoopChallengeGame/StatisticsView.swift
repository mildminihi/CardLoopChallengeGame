import SwiftUI

// MARK: - Statistics Page View
struct StatisticsView: View {
    @StateObject private var statistics = GameStatistics.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var showingClearConfirmation = false
    @State private var showingEndlessMode = false
    @Environment(\.dismiss) private var dismiss
    
    var isInGamePage: Bool = false
    var isNormalModel: Bool = true
    
    init(isInGamePage: Bool = false, isNormalModel: Bool = true) {
        self.isInGamePage = isInGamePage
        self.isNormalModel = isNormalModel
    }
    
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
            
            VStack(spacing: 20) {
                
                // Mode Switch Toggle
                if !isInGamePage {
                    modeSwitchSection
                }
                ScrollView {
                    VStack(spacing: 20) {
                        // Game Overview Stats
                        if isInGamePage {
                            if isNormalModel {
                                gameOverviewSection
                                // Normal Mode Statistics
                                normalModeStatistics
                            } else {
                                endlessModeStatistics
                            }
                        }
                        
                        else {
                            if !showingEndlessMode {
                                gameOverviewSection
                                // Normal Mode Statistics
                                normalModeStatistics
                            } else {
                                // Endless Mode Statistics
                                endlessModeStatistics
                            }
                        }
                        
                        Spacer()
                        
                        // Clear Statistics Button
                        Button("clear_stats".localized) {
                            SettingsManager.shared.performHapticFeedback()
                            showingClearConfirmation = true
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        )
                    }
                    .padding()
                }
            }
        }
        .alert("clear_stats_confirmation".localized, isPresented: $showingClearConfirmation) {
            Button("cancel".localized, role: .cancel) { }
            Button("clear_stats_confirm".localized, role: .destructive) {
                statistics.clearAllStatistics()
            }
        } message: {
            Text("clear_stats_message".localized)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force UI refresh when language changes
            statistics.objectWillChange.send()
        }
    }
    
    private var modeSwitchSection: some View {
        HStack {
            Text(showingEndlessMode ? "endless_mode".localized : "normal_mode".localized)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $showingEndlessMode)
                .toggleStyle(SwitchToggleStyle(tint: Color.green))
//                .scaleEffect(1.2)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private var gameOverviewSection: some View {
        VStack(spacing: 15) {
            Text("game_overview".localized)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                statCard(
                    title: "total_games".localized,
                    value: "\(statistics.totalGamesPlayed)",
                    color: .blue
                )
                
                statCard(
                    title: "games_won".localized,
                    value: "\(statistics.gamesWon)",
                    color: .green
                )
                
                statCard(
                    title: "games_lost".localized,
                    value: "\(statistics.gamesLost)",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
    }
    
    private var endlessModeStatistics: some View {
        VStack(spacing: 20) {
            // Endless Mode Overview Stats
            stageStatSection(
                title: "endless_mode_overview".localized,
                stats: [
                    ("high_score".localized, statistics.highScoreCount, Color.yellow),
                    ("total_endless_games".localized, statistics.totalEndLessGamesPlayed, Color.blue)
                ]
            )
            
            // Stage Encounter Statistics
            stageStatSection(
                title: "stage_encounters".localized,
                stats: [
                    ("stage1_title".localized, statistics.colorStageEncounter, Color.red),
                    ("stage2_title".localized, statistics.highLowStageEncounter, Color.green),
                    ("stage3_title".localized, statistics.rangeStageEncounter, Color.blue),
                    ("stage4_title".localized, statistics.suitStageEncounter, Color.purple),
                    ("stage5_title".localized, statistics.evenOddStageEncounter, Color.orange),
                    ("stage6_title".localized, statistics.numberStageEncounter, Color.cyan)
                ]
            )
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
    }
    
    private var normalModeStatistics: some View {
        VStack(spacing: 20) {
            // Stage 1 Statistics
            stageStatSection(
                title: "stage1_title".localized,
                stats: [
                    ("red_button".localized, statistics.stage1RedCount, Color.red),
                    ("black_button".localized, statistics.stage1BlackCount, Color.white)
                ]
            )
            
            // Stage 2 Statistics
            stageStatSection(
                title: "stage2_title".localized,
                stats: [
                    ("higher_button".localized, statistics.stage2HigherCount, Color.green),
                    ("lower_button".localized, statistics.stage2LowerCount, Color.green),
                    ("stats_equal".localized, statistics.stage2EqualCount, Color.yellow)
                ]
            )
            
            // Stage 3 Statistics
            stageStatSection(
                title: "stage3_title".localized,
                stats: [
                    ("inside_button".localized, statistics.stage3InsideCount, Color.green),
                    ("outside_button".localized, statistics.stage3OutsideCount, Color.green),
                    ("stats_equal".localized, statistics.stage3EqualCount, Color.yellow)
                ]
            )
            
            // Stage 4 Statistics
            stageStatSection(
                title: "stage4_title".localized,
                stats: [
                    ("spades_button".localized, statistics.stage4SpadesCount, Color.white),
                    ("hearts_button".localized, statistics.stage4HeartsCount, Color.red),
                    ("diamonds_button".localized, statistics.stage4DiamondsCount, Color.red),
                    ("clubs_button".localized, statistics.stage4ClubsCount, Color.white)
                ]
            )
        }
    }
    
    private func stageStatSection(title: String, stats: [(String, Int, Color)]) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                    HStack {
                        Text(stat.0)
                            .foregroundColor(stat.2)
                            .font(.body)
                        
                        Spacer()
                        
                        Text("\(stat.1)")
                            .foregroundColor(.white)
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
    }
    
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
