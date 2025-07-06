//
//  GameStage.swift
//  CardLoopChallengeGame
//
//  Created by Supanat.w on 30/6/2568 BE.
//


import SwiftUI
enum GameType: CaseIterable {
    case color, highLow, inOut, suite, odd, number
    
    var title: String {
        switch self {
        case .color: return "stage1_title".localized
        case .highLow: return "stage2_title".localized
        case .inOut: return "stage3_title".localized
        case .suite: return "stage4_title".localized
        case .odd: return "stage5_title".localized
        case .number: return "stage6_title".localized
        }
    }
    
    var description: String {
        switch self {
        case .color: return "stage1_description".localized
        case .highLow: return "stage2_description".localized
        case .inOut: return "stage3_description".localized
        case .suite: return "stage4_description".localized
        case .odd: return "stage5_description".localized
        case .number: return "stage6_description".localized
        }
    }
    
    static func getInitalStage() -> GameType {
        return [GameType.color, GameType.suite, GameType.odd, GameType.number].randomElement() ?? .color
    }
    
    static func getNewStage() -> GameType {
        return GameType.allCases.randomElement() ?? .color
    }
}

// MARK: - Game Logic
class EndLessGameModel: ObservableObject {
    @Published var currentStage: GameType = GameType.getInitalStage()
    @Published var deck: [Card] = []
    @Published var revealedCards: [Card] = []
    @Published var gameResult: GameResult = .playing
    @Published var feedback: String = ""
    @Published var showingResult: Bool = false
    @Published var winCount: Int = 0
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        createAndShuffleDeck()
        currentStage = GameType.getInitalStage()
        revealedCards = []
        gameResult = .playing
        feedback = ""
        showingResult = false
        GameStatistics.shared.trackStageEncounterEndLessMode(stage: currentStage)
        GameStatistics.shared.trackEndlessGameStart()
        winCount = 0
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
        guard currentStage == .color, let card = drawCard() else { return }
        
        revealedCards.append(card)
        
        if card.isRed == isRed {
            feedback = "correct_card_was".localized(with: card.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else {
            feedback = "wrong_card_was_game_over".localized(with: card.displayText)
            gameResult = .lost
            SettingsManager.shared.playWrongSound()
            showingResult = true
        }
    }
    
    // MARK: - Stage 2: Higher or Lower
    func guessHigherOrLower(isHigher: Bool) {
        guard currentStage == .highLow, let card = drawCard(), !revealedCards.isEmpty, let previousCard = revealedCards.last else { return }
        
        
        revealedCards.append(card)
        
        let isActuallyHigher = card.rank.rawValue > previousCard.rank.rawValue
        let isCorrect = (isHigher && isActuallyHigher) || (!isHigher && !isActuallyHigher)
        
        if card.rank.rawValue == previousCard.rank.rawValue {
            feedback = "lucky_equal_ranks".localized
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else if isCorrect {
            let comparisonKey = isActuallyHigher ? "correct_card_is_higher_than" : "correct_card_is_lower_than"
            feedback = comparisonKey.localized(with: card.displayText, previousCard.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else {
            let comparisonKey = isActuallyHigher ? "wrong_card_is_higher_than" : "wrong_card_is_lower_than"
            feedback = comparisonKey.localized(with: card.displayText, previousCard.displayText)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
        }
    }
    
    // MARK: - Stage 3: Inside or Outside
    func guessInsideOrOutside(isInside: Bool) {
        guard currentStage == .inOut,
              let card = drawCard(),
              revealedCards.count >= 2,
              let card2 = revealedCards.last else { return }
        
        let card1 = revealedCards[revealedCards.count - 2]
        let minRank = min(card1.rank.rawValue, card2.rank.rawValue)
        let maxRank = max(card1.rank.rawValue, card2.rank.rawValue)
        
        revealedCards.append(card)
        
        let cardRank = card.rank.rawValue
        let isActuallyInside = cardRank > minRank && cardRank < maxRank
        
        if cardRank == minRank || cardRank == maxRank {
            feedback = "lucky_equal_boundary".localized
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else if (isInside && isActuallyInside) || (!isInside && !isActuallyInside) {
            let positionKey = isActuallyInside ? "correct_card_is_inside" : "correct_card_is_outside"
            feedback = positionKey.localized(with: card.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else {
            let positionKey = isActuallyInside ? "wrong_card_is_inside" : "wrong_card_is_outside"
            feedback = positionKey.localized(with: card.displayText)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
        }
    }
    
    // MARK: - Stage 4: Guess the Suit
    func guessSuit(_ suit: Card.Suit) {
        guard currentStage == .suite, let card = drawCard() else { return }
        
        revealedCards.append(card)
        
        if card.suit == suit {
            feedback = "correct_card_was".localized(with: card.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else {
            feedback = "wrong_suit_was".localized(with: card.suit.rawValue)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
        }
    }
    
    func guessOdd(isOdd: Bool) {
        guard currentStage == .odd, let card = drawCard() else { return }
        
        revealedCards.append(card)
        
        if card.isOdd == isOdd {
            feedback = "correct_card_was".localized(with: card.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else {
            feedback = "wrong_card_was_game_over".localized(with: card.displayText)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
        }
    }
    
    func guessNumber(isNumber: Bool) {
        guard currentStage == .number, let card = drawCard() else { return }
        
        revealedCards.append(card)
        
        if card.isNumber == isNumber {
            feedback = "correct_card_was".localized(with: card.displayText)
            SettingsManager.shared.playCorrectSound()
            gameResult = .nextStage
        } else {
            feedback = "wrong_card_was_game_over".localized(with: card.displayText)
            SettingsManager.shared.playWrongSound()
            gameResult = .lost
            showingResult = true
        }
    }
    
    func advanceToNextStage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.winCount += 1
            self.currentStage = self.winCount > 2 ? GameType.getNewStage() : [.color, .suite, .highLow, .odd, .number].randomElement() ?? .color
            GameStatistics.shared.trackStageEncounterEndLessMode(stage: self.currentStage)
            GameStatistics.shared.trackNewHighScore(score: self.winCount)
            self.feedback = ""
            self.gameResult = .playing
        }
    }
}

// MARK: - Game View
struct EndLessGameView: View {
    @StateObject private var game = EndLessGameModel()
    @StateObject private var languageManager = LanguageManager.shared
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
                            Text("endless_mode".localized)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("win_of".localized(with: game.winCount))
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
                
                // Current Card
                if let lastCard = game.revealedCards.last {
                    Text("current_stage".localized)
                        .font(.title3)
                        .foregroundColor(.green.opacity(0.8))
                    
                    if game.currentStage == .inOut, let secondLastCard = game.revealedCards.dropLast().last {
                        HStack {
                            BigCardView(card: secondLastCard)
                            BigCardView(card: lastCard)
                        }
                    } else {
                        BigCardView(card: lastCard)
                    }
                }
                
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
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(isInGamePage: true, isNormalModel: false)
                .presentationDetents([.fraction(0.7)])
                        .presentationDragIndicator(.visible)
        }
    }
    
    private func getCurrentLanguageFlag() -> String {
        return languageManager.availableLanguages.first { $0.code == languageManager.currentLanguage }?.flag ?? "🌐"
    }
    
    @ViewBuilder
    private var gameButtonsView: some View {
        VStack(spacing: 15) {
            switch game.currentStage {
            case .color:
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
                
            case .highLow:
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
                
            case .inOut:
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
                
            case .suite:
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
            case .odd:
                let oddButtonText = SettingsManager.shared.isEasyMode ? "\("odd_button".localized) \(Card.formatPercent(percent: Card.getPercentOdd(remainDeck: game.deck)))" : "odd_button".localized
                
                let evenButtonText = SettingsManager.shared.isEasyMode ? "\("even_button".localized) \(Card.formatPercent(percent: Card.getPercentEven(remainDeck: game.deck)))" : "even_button".localized
                
                HStack(spacing: 20) {
                    Button(evenButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessOdd(isOdd: false)
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
                    
                    Button(oddButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessOdd(isOdd: true)
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
            case .number:
                let numberButtonText = SettingsManager.shared.isEasyMode ? "\("number_button".localized) \(Card.formatPercent(percent: Card.getPercentNumber(remainDeck: game.deck)))" : "number_button".localized
                
                let faceButtonText = SettingsManager.shared.isEasyMode ? "\("face_button".localized) \(Card.formatPercent(percent: Card.getPercentFace(remainDeck: game.deck)))" : "face_button".localized
                
                HStack(spacing: 20) {
                    Button(numberButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessNumber(isNumber: true)
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
                    
                    Button(faceButtonText) {
                        SettingsManager.shared.performHapticFeedback()
                        game.guessNumber(isNumber: false)
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
            }
        }
    }
}
