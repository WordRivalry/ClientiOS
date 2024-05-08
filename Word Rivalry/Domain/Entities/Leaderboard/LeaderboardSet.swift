//
//  LeaderboardSet.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-02.
//

import Foundation

final class LeaderboardSet: Codable {
    var leaderboards: [LeaderboardID: Leaderboard] = [:]
    
    let leaderboardSetID: LeaderboardSetID
    
    init(leaderboardSetID: LeaderboardSetID) {
        self.leaderboardSetID = leaderboardSetID
    }
    
    // Adds a leaderboard to the set, or updates an existing one
    func addOrUpdateLeaderboard(_ leaderboard: Leaderboard) {
        leaderboards[leaderboard.leaderboardID] = leaderboard
    }
    
    // Retrieve a leaderboard by ID with error handling
    func leaderboard(forID id: LeaderboardID) throws -> Leaderboard {
        guard let entry = leaderboards[id] else {
            throw NSError(domain: "LeaderboardSetError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found"])
        }
        
        return entry
    }
}
