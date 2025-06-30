import Foundation
import SwiftUI

// MARK: - Game Statistics Model
class GameStatistics: ObservableObject {
    @Published var stage1RedCount = 0
    @Published var stage1BlackCount = 0
    
    @Published var stage2HigherCount = 0
    @Published var stage2LowerCount = 0
    @Published var stage2EqualCount = 0
    
    @Published var stage3InsideCount = 0
    @Published var stage3OutsideCount = 0
    @Published var stage3EqualCount = 0
    
    @Published var stage4SpadesCount = 0
    @Published var stage4HeartsCount = 0
    @Published var stage4DiamondsCount = 0
    @Published var stage4ClubsCount = 0
    
    @Published var totalGamesPlayed = 0
    @Published var gamesWon = 0
    @Published var gamesLost = 0
    
    static let shared = GameStatistics()
    
    private init() {
        loadStatistics()
    }
    
    // MARK: - Track Statistics
    func trackStage1Choice(isRed: Bool) {
        if isRed {
            stage1RedCount += 1
        } else {
            stage1BlackCount += 1
        }
        saveStatistics()
    }
    
    func trackStage2Choice(isHigher: Bool, wasEqual: Bool = false) {
        if wasEqual {
            stage2EqualCount += 1
        } else if isHigher {
            stage2HigherCount += 1
        } else {
            stage2LowerCount += 1
        }
        saveStatistics()
    }
    
    func trackStage3Choice(isInside: Bool, wasEqual: Bool = false) {
        if wasEqual {
            stage3EqualCount += 1
        } else if isInside {
            stage3InsideCount += 1
        } else {
            stage3OutsideCount += 1
        }
        saveStatistics()
    }
    
    func trackStage4Choice(suit: String) {
        switch suit {
        case "♠": stage4SpadesCount += 1
        case "♥": stage4HeartsCount += 1
        case "♦": stage4DiamondsCount += 1
        case "♣": stage4ClubsCount += 1
        default: break
        }
        saveStatistics()
    }
    
    func trackGameStart() {
        totalGamesPlayed += 1
        saveStatistics()
    }
    
    func trackGameEnd(won: Bool) {
        if won {
            gamesWon += 1
        } else {
            gamesLost += 1
        }
        saveStatistics()
    }
    
    // MARK: - Persistence
    private func saveStatistics() {
        let defaults = UserDefaults.standard
        defaults.set(stage1RedCount, forKey: "stage1RedCount")
        defaults.set(stage1BlackCount, forKey: "stage1BlackCount")
        
        defaults.set(stage2HigherCount, forKey: "stage2HigherCount")
        defaults.set(stage2LowerCount, forKey: "stage2LowerCount")
        defaults.set(stage2EqualCount, forKey: "stage2EqualCount")
        
        defaults.set(stage3InsideCount, forKey: "stage3InsideCount")
        defaults.set(stage3OutsideCount, forKey: "stage3OutsideCount")
        defaults.set(stage3EqualCount, forKey: "stage3EqualCount")
        
        defaults.set(stage4SpadesCount, forKey: "stage4SpadesCount")
        defaults.set(stage4HeartsCount, forKey: "stage4HeartsCount")
        defaults.set(stage4DiamondsCount, forKey: "stage4DiamondsCount")
        defaults.set(stage4ClubsCount, forKey: "stage4ClubsCount")
        
        defaults.set(totalGamesPlayed, forKey: "totalGamesPlayed")
        defaults.set(gamesWon, forKey: "gamesWon")
        defaults.set(gamesLost, forKey: "gamesLost")
    }
    
    private func loadStatistics() {
        let defaults = UserDefaults.standard
        stage1RedCount = defaults.integer(forKey: "stage1RedCount")
        stage1BlackCount = defaults.integer(forKey: "stage1BlackCount")
        
        stage2HigherCount = defaults.integer(forKey: "stage2HigherCount")
        stage2LowerCount = defaults.integer(forKey: "stage2LowerCount")
        stage2EqualCount = defaults.integer(forKey: "stage2EqualCount")
        
        stage3InsideCount = defaults.integer(forKey: "stage3InsideCount")
        stage3OutsideCount = defaults.integer(forKey: "stage3OutsideCount")
        stage3EqualCount = defaults.integer(forKey: "stage3EqualCount")
        
        stage4SpadesCount = defaults.integer(forKey: "stage4SpadesCount")
        stage4HeartsCount = defaults.integer(forKey: "stage4HeartsCount")
        stage4DiamondsCount = defaults.integer(forKey: "stage4DiamondsCount")
        stage4ClubsCount = defaults.integer(forKey: "stage4ClubsCount")
        
        totalGamesPlayed = defaults.integer(forKey: "totalGamesPlayed")
        gamesWon = defaults.integer(forKey: "gamesWon")
        gamesLost = defaults.integer(forKey: "gamesLost")
    }
    
    // MARK: - Clear Statistics
    func clearAllStatistics() {
        stage1RedCount = 0
        stage1BlackCount = 0
        
        stage2HigherCount = 0
        stage2LowerCount = 0
        stage2EqualCount = 0
        
        stage3InsideCount = 0
        stage3OutsideCount = 0
        stage3EqualCount = 0
        
        stage4SpadesCount = 0
        stage4HeartsCount = 0
        stage4DiamondsCount = 0
        stage4ClubsCount = 0
        
        totalGamesPlayed = 0
        gamesWon = 0
        gamesLost = 0
        
        saveStatistics()
    }
}