//
//  Card.swift
//  CardLoopChallengeGame
//
//  Created by Supanat.w on 30/6/2568 BE.
//
// MARK: - Card Model

import SwiftUICore

struct Card {
    let suit: Suit
    let rank: Rank
    
    enum Suit: String, CaseIterable {
        case spades = "♠"
        case hearts = "♥"
        case diamonds = "♦"
        case clubs = "♣"
        
        var isRed: Bool {
            return self == .hearts || self == .diamonds
        }
        
        var color: Color {
            return isRed ? .red : .white // Changed to white for better contrast on dark background
        }
    }
    
    enum Rank: Int, CaseIterable {
        case two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10
        case jack = 11, queen = 12, king = 13, ace = 14
        
        var displayValue: String {
            switch self {
            case .ace: return "A"
            case .jack: return "J"
            case .queen: return "Q"
            case .king: return "K"
            default: return "\(rawValue)"
            }
        }
    }
    
    var displayText: String {
        return "\(rank.displayValue)\(suit.rawValue)"
    }
    
    var isRed: Bool {
        return suit.isRed
    }
    
    var isOdd: Bool {
        guard rank != .ace else { return true }
        return rank.rawValue % 2 != 0
    }
    
    var isNumber: Bool {
        return rank.rawValue >= 2 && rank.rawValue <= 10
    }
    
    static func getPercentRed(remainDeck: [Card]) -> Double {
        let redCount = remainDeck.filter { $0.isRed }.count
        return (Double(redCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentBlack(remainDeck: [Card]) -> Double {
        let blackCount = remainDeck.filter { !$0.isRed }.count
        return (Double(blackCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentHigh(remainDeck: [Card], currentRank: Int) -> Double {
        let highCount = remainDeck.filter { $0.rank.rawValue >= currentRank }.count
        return (Double(highCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentLow(remainDeck: [Card], currentRank: Int) -> Double {
        let lowCount = remainDeck.filter { $0.rank.rawValue < currentRank }.count
        return (Double(lowCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentRange(remainDeck: [Card], revealDeck: [Card]) -> Double {
        let minRank = min(revealDeck[revealDeck.count - 2].rank.rawValue, revealDeck.last?.rank.rawValue ?? 0)
        let maxRank = max(revealDeck[revealDeck.count - 2].rank.rawValue, revealDeck.last?.rank.rawValue ?? 0)
        let inRangeCount = remainDeck.filter { $0.rank.rawValue >= minRank && $0.rank.rawValue <= maxRank }.count
        return (Double(inRangeCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentOutRange(remainDeck: [Card], revealDeck: [Card]) -> Double {
        let minRank = min(revealDeck[revealDeck.count - 2].rank.rawValue, revealDeck.last?.rank.rawValue ?? 0)
        let maxRank = max(revealDeck[revealDeck.count - 2].rank.rawValue, revealDeck.last?.rank.rawValue ?? 0)
        let outRangeCount = remainDeck.filter { $0.rank.rawValue < minRank || $0.rank.rawValue > maxRank }.count
        return (Double(outRangeCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentSuit(remainDeck: [Card], suit: Suit) -> Double {
        let suitCount = remainDeck.filter { $0.suit == suit }.count
        return (Double(suitCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentOdd(remainDeck: [Card]) -> Double {
        let oddCount = remainDeck.filter { $0.isOdd }.count
        return (Double(oddCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentEven(remainDeck: [Card]) -> Double {
        let evenCount = remainDeck.filter { !$0.isOdd }.count
        return (Double(evenCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentNumber(remainDeck: [Card]) -> Double {
        let numberCount = remainDeck.filter { $0.isNumber }.count
        return (Double(numberCount) / Double(remainDeck.count)) * 100
    }
    
    static func getPercentFace(remainDeck: [Card]) -> Double {
        let faceCount = remainDeck.filter { !$0.isNumber }.count
        return (Double(faceCount) / Double(remainDeck.count)) * 100
    }
    
    static func formatPercent(percent: Double) -> String {
        return "\(String(format: "%.0f", percent))%"
    }
}
