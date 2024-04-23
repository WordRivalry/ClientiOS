//
//  LeaderboardRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation

final class LeaderboardRepository: LeaderboardRepositoryProtocol {
    func fetchTopPlayers(limit: Int) async throws -> [User] {
        do {
            // Call the database to fetch sorted models based on the `eloRating` field.
            // The list is sorted in descending order to get the top players first, and the result is limited by the `request` value.
            let users: [User] = try await db.fetchSortedModels(for: .eloRating, ascending: false, limit: limit)
            // If fetch is successful, update local file storage with the fresh data.
            await cacheLeaderboard(users)
            return users
        } catch {
            // If database fetch fails, attempt to retrieve the user from local file storage.
            if let cachedUsers = try? await leaderboardStorage.load() {
                return cachedUsers.users // Return cached users if available.
            } else {
                // If no user data is available in local storage, rethrow the original database error.
                throw error
            }
        }
    }
    
    /// Reference to the shared database instance, providing access to user data.
    let db = PublicDatabase.shared.db
    
    /// Local file storage for backing up or retrieving the leaderboard data when the database is unavailable.
    var leaderboardStorage: FileStorage<LeaderboardData> = FileStorage(fileName: "leaderboard.data")
    
    private func cacheLeaderboard(_ users: [User]) async -> Void {
        do {
            let leaderboardData = LeaderboardData(users: users)
            try await leaderboardStorage.save(data: leaderboardData)
        } catch {
            try? leaderboardStorage.invalidate()
        }
    }
}
