//
//  GameResults.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-03.
//

import Foundation

struct WordHistory: Codable {
    let word: String
    let path: CodableWordPath
    let time: Float
    let score: Int
}

struct PlayerResult: Codable, Identifiable {
    let playerName: String
    let playerEloRating: Int
    let score: Int
    let historic: [WordHistory]
    var id: String { playerName }
}

struct GameResults {
    var winner: String
    var playerResults: [PlayerResult]
    
    // Follow null pattern
    init(winner: String, playerResults: [PlayerResult]) {
        self.winner = winner
        self.playerResults = playerResults
    }
}
