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
    
//    // Entries immediately preceding the local player's entry
//    var entriesBeforeLocal: [LeaderboardEntry]?
//
//    // Entries immediately following the local player's entry
//    var entriesAfterLocal: [LeaderboardEntry]?
    
    // Top 50 entries on this leaderboard
    var top50: [LeaderboardEntry]
    
    init(leaderboardID: LeaderboardID) {
        self.leaderboardID = leaderboardID
        self.top50 = []
        self.updateDate = .now
    }
}
