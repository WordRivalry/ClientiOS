//
//  MockLeaderboardRepository.swift
//  Word RivalryTests
//
//  Created by benoit barbier on 2024-05-07.
//

import Foundation
@testable import Word_Rivalry
import XCTest


protocol LeaderboardRepositoryProtocol2 {
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

class MockLeaderboardRepository: LeaderboardRepositoryProtocol {
    
    // Mock storage for leaderboards
    private var leaderboards: [LeaderboardID: Leaderboard] = [:]
    
    // Ability to simulate failures for testing error handling
    var shouldReturnFailure: Bool = false
    var failureError: Error = LeaderboardRepositoryError.fetchLeaderboardFailure
    
    // Mock data setup
    init() {
        // Setup initial mock data if necessary
        leaderboards[.currentStars] = .previewLeaderboard(id: .currentStars)
        leaderboards[.allTimeStars] = .previewLeaderboard(id: .allTimeStars)
        leaderboards[.experience] = .previewLeaderboard(id: .experience)
    }
    
    func fetchLeaderboard(leaderboardID: Word_Rivalry.LeaderboardID) async throws -> Word_Rivalry.Leaderboard {
        if shouldReturnFailure {
            throw failureError
        }
        guard let leaderboard = leaderboards[leaderboardID] else {
            throw LeaderboardRepositoryError.wrongLeaderboardID
        }
        return leaderboard
    }
    
    func submitScore(score: Int, context: Int, leaderboardID: Word_Rivalry.LeaderboardID) async throws -> Word_Rivalry.Leaderboard {
        if shouldReturnFailure {
            throw failureError
        }
        var leaderboard = try await fetchLeaderboard(leaderboardID: leaderboardID)
        
        leaderboards[leaderboardID] = leaderboard
        return leaderboard
    }
    
    func submitScore(score: Int, context: Int, leaderboardIDs: [Word_Rivalry.LeaderboardID]) async throws -> ([Word_Rivalry.Leaderboard], [Word_Rivalry.LeaderboardID]) {
        var updatedLeaderboards: [Word_Rivalry.Leaderboard] = []
        var failedIDs: [Word_Rivalry.LeaderboardID] = []
        
        for id in leaderboardIDs {
            do {
                let updatedLeaderboard = try await submitScore(
                    score: score,
                    context: context,
                    leaderboardID: id
                )
                updatedLeaderboards.append(updatedLeaderboard)
            } catch {
                failedIDs.append(id)
            }
        }
        return (updatedLeaderboards, failedIDs)
    }
    
    // Function to simulate updating score in a leaderboard
    private func updateScore(_ score: Int, in leaderboard: inout Word_Rivalry.Leaderboard) {
        // Simulate updating the score
        
    }
}
