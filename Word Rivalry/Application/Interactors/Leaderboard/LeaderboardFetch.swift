//
//  leaderboardUC.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

struct LeaderboardData: Codable {
    let cacheTime: Date
    let users: [User]
    
    init(cacheTime: Date = Date.now, users: [User]) {
        self.cacheTime = cacheTime
        self.users = users
    }
}

/// A use case class for fetching the leaderboard based on users' Elo ratings from a public database.
/// This class adheres to the `UseCaseProtocol`, making it specific for fetching a sorted list of users.
final class LeaderboardFetch: UseCaseProtocol {
    /// The `Request` type specifies the maximum number of `User` objects to return, representing the limit on the leaderboard size.
    typealias Request = Int // The number of top users to fetch
    
    /// The `Response` type is an array of `User` objects, representing the users who are at the top of the leaderboard.
    typealias Response = [User]
    
    let leaderboardRepository: LeaderboardRepository = LeaderboardRepository()
    
    /// Executes the fetch operation to retrieve a sorted list of users based on their Elo rating in descending order.
    /// - Parameter request: The number of users to fetch, which acts as a limit to the result set.
    /// - Returns: An array of `User` objects sorted by Elo rating from highest to lowest.
    /// - Throws: Propagates errors from the database layer if the fetch operation fails.
    func execute(request: Request) async throws -> Response {
        return try await leaderboardRepository.fetchTopPlayers(limit: request)
    }
}

