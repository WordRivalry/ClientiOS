//
//  LeaderboardRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation
import GameKit

// MARK: - Leaderboard Repository
final class GKLeaderboardService {
    
    
    // MARK: - Set Loading
    
    /// Loads all available leaderboard sets asynchronously.
    /// - Returns: An array of `GKLeaderboardSet` representing all the leaderboard sets available.
    /// - Throws: An `Error` if there is any issue in fetching the leaderboard sets.
    func loadLeaderboardSets() async throws -> [GKLeaderboardSet] {
        return try await GKLeaderboardSet.loadLeaderboardSets()
    }
    
    
    // MARK: - Leaderboard Loading
    
    /// Asynchronously loads a single leaderboard by its unique identifier.
    /// - Parameter leaderboardID: Unique identifier for the leaderboard.
    /// - Returns: An optional `GKLeaderboard` found by the ID.
    /// - Throws: `Error` if the leaderboard cannot be loaded.
    func loadLeaderboard(
        byID leaderboardID: String
    ) async throws -> GKLeaderboard? {
        
        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
        return leaderboards.first
    }
    
    /// Asynchronously loads multiple leaderboards based on their identifiers.
    /// - Parameter leaderboardIDs: An array of leaderboard IDs.
    /// - Returns: An array of `GKLeaderboard`.
    /// - Throws: `Error` if the leaderboards cannot be loaded.
    func loadLeaderboards(
        byIDs leaderboardIDs: [String]
    ) async throws -> [GKLeaderboard] {
        
        return try await GKLeaderboard.loadLeaderboards(IDs: leaderboardIDs)
    }
    
    /// Loads all leaderboards associated with a specific leaderboard set.
    /// This function is crucial for games that have multiple leaderboards organized under a single set, allowing a grouped presentation.
    /// - Parameter set: The `GKLeaderboardSet` whose leaderboards need to be loaded.
    /// - Returns: An array of `GKLeaderboard` containing all the leaderboards under the specified set.
    /// - Throws: An `Error` if there is any issue in fetching the leaderboards.
    func loadLeaderboards(
        in set: GKLeaderboardSet
    ) async throws -> [GKLeaderboard] {
        
        var leaderboards: [GKLeaderboard]?
        var error: Error? = nil
        
        set.loadLeaderboards { (loadedLeaderboards, loadError) in
            leaderboards = loadedLeaderboards
            error = loadError
        }
        
        if let error = error {
            throw error
        }
        
        return leaderboards ?? []
    }
    
    
    // MARK: - Entry Loading
    
    /// Asynchronously loads leaderboard entries based on player scope, time scope, and a specified rank range.
    /// Useful for filtering scores by player relationship (global or friends) and over specific periods.
    /// - Parameters:
    ///   - leaderboard: Source GKLeaderboard instance.
    ///   - playerScope: Filter for global scores or friends-only.
    ///   - timeScope: Time period for the scores, e.g., today, this week.
    ///   - startRank: Starting rank position.
    ///   - length: Number of ranks to include from the startRank.
    /// - Returns: A tuple of optional local player entry, array of entries, and total player count.
    /// - Throws: Error on issues like network failures or invalid Game Center configurations.
    func loadEntries(
        from leaderboard: GKLeaderboard,
        for playerScope: GKLeaderboard.PlayerScope,
        timeScope: GKLeaderboard.TimeScope,
        startRank: Int,
        length: Int
    ) async throws -> (GKLeaderboard.Entry?, [GKLeaderboard.Entry], Int) {
        // Create an NSRange object to define the range of ranks to load.
        let range = NSRange(location: startRank, length: length)
        
        // Fetch the leaderboard entries using the created range.
        return try await leaderboard.loadEntries(for: playerScope, timeScope: timeScope, range: range)
    }
    
    
    /// Fetches scores for specified players within a certain time period.
    /// - Parameters:
    ///   - leaderboard: Source GKLeaderboard instance.
    ///   - players: Array of GKPlayer whose scores are to be fetched.
    ///   - timeScope: Time period for score retrieval.
    /// - Returns: Tuple of optional local player entry and an array of entries.
    /// - Throws: Error on retrieval failures.
    func loadEntries(
        from leaderboard: GKLeaderboard,
        for players: [GKPlayer],
        timeScope: GKLeaderboard.TimeScope
    ) async throws -> (GKLeaderboard.Entry?, [GKLeaderboard.Entry]) {
        return try await leaderboard.loadEntries(for: players, timeScope: timeScope)
    }
    
    /// Loads scores around a specified player’s rank.
    /// - Parameters:
    ///   - leaderboard: Source GKLeaderboard instance.
    ///   - player: GKPlayer to center the score retrieval on.
    ///   - range: Number of entries before and after the player’s score to load.
    /// - Returns: Array of GKLeaderboard.Entry around the player's rank.
    /// - Throws: Error if the player’s rank cannot be determined or on data fetch issues.
    func loadScoresAroundPlayer(
        from leaderboard: GKLeaderboard,
        for player: GKPlayer,
        range: Int
    ) async throws -> [GKLeaderboard.Entry] {
        // First, load the player's entry to find the rank
        let (playerEntry, _) = try await leaderboard.loadEntries(
            for: [player],
            timeScope: .allTime
        )
        guard let rank = playerEntry?.rank else {
            throw NSError(domain: "GCService", code: 2002, userInfo: [NSLocalizedDescriptionKey: "Player rank not found"])
        }
        
        // Calculate the range to fetch entries around the player
        let lowerBound = max(1, rank - range)
        let upperBound = rank + range
        let range = NSRange(location: lowerBound, length: upperBound - lowerBound + 1)
        
        // Load entries around the player's rank
        let (_, entries, _) = try await leaderboard.loadEntries(for: .global, timeScope: .allTime, range: range)
        return entries
    }
    
    /// Retrieves scores around a known leaderboard entry’s rank.
    /// - Parameters:
    ///   - leaderboard: Source GKLeaderboard instance.
    ///   - entry: GKLeaderboard.Entry to focus the retrieval on.
    ///   - range: Number of entries before and after the focused entry to load.
    /// - Returns: Array of GKLeaderboard.Entry surrounding the specified entry.
    /// - Throws: Error on data retrieval issues.
    func loadScoresAroundEntry(
        from leaderboard: GKLeaderboard,
        centeredOn entry: GKLeaderboard.Entry,
        range: Int
    ) async throws -> [GKLeaderboard.Entry] {
        // Use the rank
        let rank = entry.rank
        
        // Calculate the range to fetch entries around the given rank
        let lowerBound = max(1, rank - range)
        let upperBound = rank + range
        let calculatedRange = NSRange(location: lowerBound, length: upperBound - lowerBound + 1)
        
        // Load entries around the given rank
        let (_, entries, _) = try await leaderboard.loadEntries(for: .global, timeScope: .allTime, range: calculatedRange)
        return entries
    }
    
    /// Fetches the most recent leaderboard score for the local player based on a specified time scope.
    /// - Parameters:
    ///   - leaderboard: GKLeaderboard from which to load the score.
    ///   - timeScope: Period over which scores are considered.
    /// - Returns: Optional GKLeaderboard.Entry for the local player if available.
    /// - Throws: Error if unable to fetch the score.
    func loadEntryForLocalPlayer(
        from leaderboard: GKLeaderboard,
        timeScope: GKLeaderboard.TimeScope
    ) async throws -> GKLeaderboard.Entry? {
        
        let (localPlayerEntry, _) = try await leaderboard.loadEntries(
            for: [], // Empty since we fetch only for local
            timeScope: timeScope
        )
        
        return localPlayerEntry
    }
    
    /// Retrieves the latest leaderboard entry for the local player.
    /// - Parameter leaderboard: GKLeaderboard from which to load the score.
    /// - Returns: Latest GKLeaderboard.Entry for the local player if available.
    /// - Throws: Error if the score cannot be loaded.
    func loadLatestEntryForLocalPlayer(
        from leaderboard: GKLeaderboard
    ) async throws -> GKLeaderboard.Entry? {
        
        let (localPlayerEntry, _) = try await leaderboard.loadEntries(
            for: [],  // Empty since we fetch only for local
            timeScope: .allTime
        )
        return localPlayerEntry
    }
    
    
    // MARK: - Score Submit
    
    /// Asynchronously submits a score to multiple leaderboards.
    /// - Parameters:
    ///   - score: The score that the player earns.
    ///   - context: An integer value that your game uses, typically to store additional data relevant to the score.
    ///   - player: The `GKPlayer` object representing the player who earns the score.
    ///   - leaderboardIDs: An array of strings representing the IDs of the leaderboards to which the score will be submitted.
    /// - Throws: `Error` if the score cannot be submitted.
    func submitScore(
        _ score: Int,
        context: Int,
        player: GKPlayer,
        leaderboardIDs: [String]
    ) async throws -> Void {
        try await GKLeaderboard.submitScore(score, context: context, player: player, leaderboardIDs: leaderboardIDs)
    }
}
