//
//  LeaderboardRepositoryProtocol.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation

protocol LeaderboardRepositoryProtocol {
    func fetchLeaderboard(
        leaderboardID: LeaderboardID
    ) async throws -> Leaderboard
   
    func submitScore(
        score: Int,
        context: Int,
        leaderboardID: LeaderboardID
    ) async throws -> Leaderboard
    
    // Submit to multiple leaderboards, return ldID who failed local data update.
    func submitScore(
        score: Int,
        context: Int,
        leaderboardIDs: [LeaderboardID]
    ) async throws -> ([Leaderboard], [LeaderboardID])
}
