import SwiftUI

// MARK: - Game State
enum GameStage: Int, CaseIterable {
    case stage1 = 1, stage2 = 2, stage3 = 3, stage4 = 4
    
    var title: String {
        switch self {
        case .stage1: return "stage1_title".localized
        case .stage2: return "stage2_title".localized
        case .stage3: return "stage3_title".localized
        case .stage4: return "stage4_title".localized
        }
    }
    
    var description: String {
        switch self {
        case .stage1: return "stage1_description".localized
        case .stage2: return "stage2_description".localized
        case .stage3: return "stage3_description".localized
        case .stage4: return "stage4_description".localized
        }
    }
}

enum GameResult {
    case playing
    case nextStage
    case won
    case lost
}

// MARK: - Game Logic
class CardChallengeGameModel: ObservableObject {
    @Published var currentStage: GameStage = .stage1
    @Published var deck: [Card] = []
    @Published var revealedCards: [Card] = []
    @Published var gameResult: GameResult = .playing
    @Published var feedback: String = ""
    @Published var showingResult: Bool = false
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        createAndShuffleDeck()
        currentStage = .stage1
        revealedCards = []
        gameResult = .playing
        feedback = ""
        showingResult = false
        GameStatistics.shared.trackGameStart()
        SettingsManager.shared.playStartSound()
    }
    
    private func createAndShuffleDeck() {
        var newDeck: [Card] = []
        
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                newDeck.append(Card(suit: suit, rank: rank))
            }
        }
        
        deck = newDeck.shuffled()
    }
    
    private func drawCard() -> Card? {
        guard !deck.isEmpty else { return nil }
        return deck.removeFirst()
    }
    
    // MARK: - Stage 1: Red or Black
    func guessColor(isRed: Bool) {
        guard currentStage == .stage1, let card = drawCard() else { return }
        
        revealedCards.append(card)
        
        if card.isRed == isRed {
            feedback = "correct_card_was".localized(with: card.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
            GameStatistics.shared.trackStage1Choice(isRed: true)
        } else {
            feedback = "wrong_card_was_game_over".localized(with: card.displayText)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
            GameStatistics.shared.trackGameEnd(won: false)
            GameStatistics.shared.trackStage1Choice(isRed: false)
        }
    }
    
    // MARK: - Stage 2: Higher or Lower
    func guessHigherOrLower(isHigher: Bool) {
        guard currentStage == .stage2, let card = drawCard(), !revealedCards.isEmpty else { return }
        
        let previousCard = revealedCards[0]
        revealedCards.append(card)
        
        let isActuallyHigher = card.rank.rawValue > previousCard.rank.rawValue
        let isCorrect = (isHigher && isActuallyHigher) || (!isHigher && !isActuallyHigher)
        
        if card.rank.rawValue == previousCard.rank.rawValue {
            feedback = "lucky_equal_ranks".localized
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
            GameStatistics.shared.trackStage2Choice(isHigher: false, wasEqual: true)
        } else if isCorrect {
            let comparisonKey = isActuallyHigher ? "correct_card_is_higher_than" : "correct_card_is_lower_than"
            feedback = comparisonKey.localized(with: card.displayText, previousCard.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
            GameStatistics.shared.trackStage2Choice(isHigher: isActuallyHigher)
        } else {
            let comparisonKey = isActuallyHigher ? "wrong_card_is_higher_than" : "wrong_card_is_lower_than"
            feedback = comparisonKey.localized(with: card.displayText, previousCard.displayText)
            gameResult = .lost
            showingResult = true
            GameStatistics.shared.trackGameEnd(won: false)
            SettingsManager.shared.playWrongSound()
            GameStatistics.shared.trackStage2Choice(isHigher: isActuallyHigher)
        }
    }
    
    // MARK: - Stage 3: Inside or Outside
    func guessInsideOrOutside(isInside: Bool) {
        guard currentStage == .stage3, let card = drawCard(), revealedCards.count >= 2 else { return }
        
        let card1 = revealedCards[0]
        let card2 = revealedCards[1]
        let minRank = min(card1.rank.rawValue, card2.rank.rawValue)
        let maxRank = max(card1.rank.rawValue, card2.rank.rawValue)
        
        revealedCards.append(card)
        
        let cardRank = card.rank.rawValue
        let isActuallyInside = cardRank > minRank && cardRank < maxRank
        
        if cardRank == minRank || cardRank == maxRank {
            feedback = "lucky_equal_boundary".localized
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
            GameStatistics.shared.trackStage3Choice(isInside: true, wasEqual: true)
        } else if (isInside && isActuallyInside) || (!isInside && !isActuallyInside) {
            let positionKey = isActuallyInside ? "correct_card_is_inside" : "correct_card_is_outside"
            feedback = positionKey.localized(with: card.displayText)
            gameResult = .nextStage
            SettingsManager.shared.playCorrectSound()
            GameStatistics.shared.trackStage3Choice(isInside: isActuallyInside)
        } else {
            let positionKey = isActuallyInside ? "wrong_card_is_inside" : "wrong_card_is_outside"
            feedback = positionKey.localized(with: card.displayText)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
            GameStatistics.shared.trackGameEnd(won: false)
            GameStatistics.shared.trackStage3Choice(isInside: isActuallyInside)
        }
    }
    
    // MARK: - Stage 4: Guess the Suit
    func guessSuit(_ suit: Card.Suit) {
        guard currentStage == .stage4, let card = drawCard() else { return }
        
        revealedCards.append(card)
        
        GameStatistics.shared.trackStage4Choice(suit: suit.rawValue)
        
        if card.suit == suit {
            feedback = "correct_won_game".localized
            gameResult = .won
            showingResult = true
            SettingsManager.shared.playWinSound()
            GameStatistics.shared.trackGameEnd(won: true)
        } else {
            feedback = "wrong_suit_was".localized(with: card.suit.rawValue)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
            GameStatistics.shared.trackGameEnd(won: false)
        }
    }
    
    func advanceToNextStage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch self.currentStage {
            case .stage1:
                self.currentStage = .stage2
            case .stage2:
                self.currentStage = .stage3
            case .stage3:
                self.currentStage = .stage4
            case .stage4:
                break // Already at final stage
            }
            self.feedback = ""
            self.gameResult = .playing
        }
    }
}

// MARK: - Game View
struct CardChallengeGameView: View {
    @StateObject private var game = CardChallengeGameModel()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var showingLanguagePicker = false
    @State private var showingStatistics = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Dark green background
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
                // Header with Back Button
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Text("normal_mode".localized)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("stage_of".localized(with: game.currentStage.rawValue, 4))
                                .font(.headline)
                                .foregroundColor(.green.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Back to Home Button - Top Right
                        
                    }
                    .overlay(alignment: .trailing) {
                        Button(action: {
                            SettingsManager.shared.performHapticFeedback()
                            dismiss()
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "house.fill")
                                    .font(.title3)
                                Text("home".localized)
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    Text(game.currentStage.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(game.currentStage.description)
                        .font(.caption)
                        .foregroundColor(.green.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Deck Counter
                Text("cards_remaining".localized(with: game.deck.count))
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.6))
                
                // Revealed Cards Area
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(game.revealedCards.enumerated()), id: \.offset) { index, card in
                            CardView(card: card, stage: index + 1)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
                
                // Feedback
                if !game.feedback.isEmpty {
                    Text(game.feedback)
                        .font(.headline)
                        .foregroundColor(game.gameResult == .lost ? .red : .green)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green.opacity(0.5), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                // Game Buttons
                if game.gameResult == .playing {
                    gameButtonsView
                }
                
                if game.gameResult == .nextStage {
                    Button("next_stage".localized) {
                        SettingsManager.shared.performHapticFeedback()
                        game.advanceToNextStage()
                    }.font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
                } else {
                    // New Game Button
                    Button("start_new_game".localized) {
                        SettingsManager.shared.performHapticFeedback()
                        game.startNewGame()
                    }.font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
            
            // Bottom Buttons - Statistics (Left) and Language (Right)
            VStack {
                Spacer()
                HStack {
                    // Statistics Button - Bottom Left
                    Button(action: {
                        SettingsManager.shared.performHapticFeedback()
                        showingStatistics = true
                    }) {
                        Text("📊")
                            .font(.title3)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                    
                    // Language Button - Bottom Right
                    Button(action: {
                        SettingsManager.shared.performHapticFeedback()
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
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(isInGamePage: true, isNormalModel: true)
                .presentationDetents([.fraction(0.9)])
                .presentationDragIndicator(.visible)
        }
        .alert("language_selection".localized, isPresented: $showingLanguagePicker) {
            ForEach(languageManager.availableLanguages, id: \.code) { language in
                Button("\(language.flag) \(language.name)") {
                    SettingsManager.shared.performHapticFeedback()
                    languageManager.setLanguage(language.code)
                }
            }
            Button("cancel".localized, role: .cancel) {
                SettingsManager.shared.performHapticFeedback()
            }
        } message: {
            Text("select_language".localized)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force UI refresh when language changes
            game.objectWillChange.send()
        }
    }
    
    private func getCurrentLanguageFlag() -> String {
        return languageManager.availableLanguages.first { $0.code == languageManager.currentLanguage }?.flag ?? "🌐"
    }
    
    @ViewBuilder
    private var gameButtonsView: some View {
        VStack(spacing: 15) {
            switch game.currentStage {
            case .stage1:
                let redButtonText = SettingsManager.shared.isEasyMode ? "\("red_button".localized) \(Card.formatPercent(percent: Card.getPercentRed(remainDeck: game.deck)))" : "red_button".localized
                
                let blackButtonText = SettingsManager.shared.isEasyMode ? "\("black_button".localized) \(Card.formatPercent(percent: Card.getPercentBlack(remainDeck: game.deck)))" : "black_button".localized
                
                HStack(spacing: 20) {
                    Button(redButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessColor(isRed: true)
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
                    
                    Button(blackButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessColor(isRed: false)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                }
                
            case .stage2:
                let higherButtonText = SettingsManager.shared.isEasyMode ? "\("higher_button".localized) \(Card.formatPercent(percent: Card.getPercentHigh(remainDeck: game.deck, currentRank: game.revealedCards.last?.rank.rawValue ?? 2)))" : "higher_button".localized
                
                let lowerButtonText = SettingsManager.shared.isEasyMode ? "\("lower_button".localized) \(Card.formatPercent(percent: Card.getPercentLow(remainDeck: game.deck, currentRank: game.revealedCards.last?.rank.rawValue ?? 2)))" : "lower_button".localized
                
                HStack(spacing: 20) {
                    Button(higherButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessHigherOrLower(isHigher: true)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2)
                    )
                    
                    Button(lowerButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessHigherOrLower(isHigher: false)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }
                
            case .stage3:
                let insideButtonText = SettingsManager.shared.isEasyMode ? "\("inside_button".localized) \(Card.formatPercent(percent: Card.getPercentRange(remainDeck: game.deck, revealDeck: game.revealedCards)))" : "inside_button".localized
                
                let outsideButtonText = SettingsManager.shared.isEasyMode ? "\("outside_button".localized) \(Card.formatPercent(percent: Card.getPercentOutRange(remainDeck: game.deck, revealDeck: game.revealedCards)))" : "outside_button".localized
                
                HStack(spacing: 20) {
                    Button(insideButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessInsideOrOutside(isInside: true)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2)
                    )
                    
                    Button(outsideButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessInsideOrOutside(isInside: false)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }
                
            case .stage4:
                let spadesButtonText = SettingsManager.shared.isEasyMode ? "\("spades_button".localized) \(Card.formatPercent(percent: Card.getPercentSuit(remainDeck: game.deck, suit: .spades)))" : "spades_button".localized
                let heartsButtonText = SettingsManager.shared.isEasyMode ? "\("hearts_button".localized) \(Card.formatPercent(percent: Card.getPercentSuit(remainDeck: game.deck, suit: .hearts)))" : "hearts_button".localized
                let diamondsButtonText = SettingsManager.shared.isEasyMode ? "\("diamonds_button".localized) \(Card.formatPercent(percent: Card.getPercentSuit(remainDeck: game.deck, suit: .diamonds)))" : "diamonds_button".localized
                let clubsButtonText = SettingsManager.shared.isEasyMode ? "\("clubs_button".localized) \(Card.formatPercent(percent: Card.getPercentSuit(remainDeck: game.deck, suit: .clubs)))" : "clubs_button".localized
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    Button(spadesButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessSuit(.spades)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    
                    Button(heartsButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessSuit(.hearts)
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red.opacity(0.5), lineWidth: 2)
                    )
                    
                    Button(diamondsButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessSuit(.diamonds)
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red.opacity(0.5), lineWidth: 2)
                    )
                    
                    Button(clubsButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessSuit(.clubs)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                }
            }
        }
    }
}

// MARK: - Card View Component
struct CardView: View {
    let card: Card
    let stage: Int
    
    var body: some View {
        VStack {
            Text("stage_label".localized(with: stage))
                .font(.caption2)
                .foregroundColor(.green.opacity(0.8))
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.7))
                .frame(width: 60, height: 80)
                .overlay(
                    Text(card.displayText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(card.suit.color)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 2)
        }
    }
}
