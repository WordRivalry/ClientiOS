//
//  LeaderboardEntry.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-02.
//

import Foundation
import GameKit

struct LeaderboardEntry: Codable {
    
    // Player Data
    var gamePlayerID: String
    var displayName: String
    
    // User Data
    var user: User
    
    // Entry Data
    var context: Int
    var date: Date
    var formattedScore: String
    var rank: Int
    var score: Int
    
    init(gamePlayerID: String, displayName: String, user: User, context: Int, date: Date, formattedScore: String, rank: Int, score: Int) {
        self.gamePlayerID = gamePlayerID
        self.displayName = displayName
        self.user = user
        self.context = context
        self.date = date
        self.formattedScore = formattedScore
        self.rank = rank
        self.score = score
    }

    init(from entry: GKLeaderboard.Entry, user: User) {
        
        // Player Data
        self.gamePlayerID = entry.player.gamePlayerID
        self.displayName = entry.player.displayName
        
        // User Data
        self.user = user
        
        // Entry Data
        self.context = entry.context
        self.date = entry.date
        self.formattedScore = entry.formattedScore
        self.rank = entry.rank
        self.score = entry.score
    }
}

