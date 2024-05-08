//
//  leaderboardUC.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import OSLog

/// Utility Usecase class. No business logic handled here.
final class LeaderboardFetcher {

    private let repo: LeaderboardRepositoryProtocol
    
    init(repo: LeaderboardRepositoryProtocol = LeaderboardRepository()) {
        self.repo = repo
    }

    /// Fetches leaderboard by ID.
    func fetchLeaderboard(
        with leaderboardID: LeaderboardID
    ) async throws -> Leaderboard {
        return try await repo.fetchLeaderboard(
            leaderboardID: leaderboardID
        )
    }
}
