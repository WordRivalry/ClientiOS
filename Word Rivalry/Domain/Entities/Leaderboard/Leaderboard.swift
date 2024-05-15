//
//  Leaderboard.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-02.
//

import Foundation
import GameKit

final class Leaderboard: Codable {
    
    // Throttling updates
    let updateDate: Date
        
    // Identifier for the specific leaderboard
    let leaderboardID: LeaderboardID
    
    // Local player's leaderboard entry
    var localEntry: LeaderboardEntry?
    
    // Top entries on this leaderboard
    var topPlayers: [LeaderboardEntry]
    
    init(leaderboardID: LeaderboardID) {
        self.leaderboardID = leaderboardID
        self.topPlayers = []
        self.updateDate = .now
    }
}
