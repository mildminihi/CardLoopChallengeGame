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
}
