//
//  LeaderboardRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-02.
//

import Foundation
import GameKit

enum LeaderboardRepositoryError: Error {
    case setNotFound
    case fetchLeaderboardFailure
    case wrongLeaderboardID
    case cacheFailure(String)
}

final class LeaderboardRepository: LeaderboardRepositoryProtocol {
    
    // Enables to fetch leaderboard from the GameKit API
    private let service: GKLeaderboardService
    
    // Cache Leaderboard if possible
    private let cacheManager: LeaderboardCacheManager
    
    // So we can use stable ID
    private let userRepo: UserRepository
    
    init(
        service: GKLeaderboardService = .init(),
        cacheManager: LeaderboardCacheManager = .init(),
        userRepo: UserRepository = .init()
    ) {
        self.service = service
        self.cacheManager = cacheManager
        self.userRepo = userRepo
    }
    
    func fetchLeaderboard(leaderboardID: LeaderboardID) async throws -> Leaderboard {
//        if let cachedLeaderboard = try? await cacheManager.load(leaderboardID: leaderboardID), isCacheValid(for: cachedLeaderboard) {
//            return cachedLeaderboard
//        }
//        
//        
        return try await fetchAndCacheLeaderboard(leaderboardID: leaderboardID)
    }
    
    private func isCacheValid(for leaderboard: Leaderboard) -> Bool {
        return Date.now.timeIntervalSince(leaderboard.updateDate) <= 300
    }
    
    private func fetchAndCacheLeaderboard(leaderboardID: LeaderboardID) async throws -> Leaderboard {
           let set = try await loadSet(.normal)

        let gkLeaderboard: GKLeaderboard = try await withCheckedThrowingContinuation { continuation in
              set.loadLeaderboards { leaderboards, error in
                  if let error = error {
                      continuation.resume(throwing: error)
                  } else if let leaderboard = leaderboards?.first(where: { $0.baseLeaderboardID == leaderboardID.rawValue }) {
                      continuation.resume(returning: leaderboard)
                  } else {
                      continuation.resume(throwing: LeaderboardRepositoryError.fetchLeaderboardFailure)
                  }
              }
          }

           let (localEntry, top50Entries, count) = try await self.service.loadEntries(
               from: gkLeaderboard,
               for: .global,
               timeScope: .allTime,
               startRank: 1,
               length: 50
           )

           let leaderboard = Leaderboard(leaderboardID: leaderboardID)
           leaderboard.topPlayers = try await getUsers(from: top50Entries)
               .map { (entry, user) in
                   LeaderboardEntry(from: entry, user: user)
               }

           try await cacheManager.save(leaderboard: leaderboard)
           return leaderboard
       }
    
    private func processLocalPlayerEntry(
        _ entry: GKLeaderboard.Entry,
        gkLeaderboard: GKLeaderboard
    ) async throws -> LeaderboardEntry {
        
        let user = try await userRepo.fetchAnyUser(by: entry.player.teamPlayerID)
        return LeaderboardEntry(from: entry, user: user)
    }
    
    private func getUsers(from entries: [GKLeaderboard.Entry]) async throws -> [(GKLeaderboard.Entry, User)] {
        return try await withThrowingTaskGroup(of: (GKLeaderboard.Entry, User).self) { group in
            // Extracting player IDs after checking for persistence
            let playerIDs: [String] = entries.map { entry in
                return "\(entry.context)"
            }
            
            // Fetch users from the repository using player IDs
            let users = try await userRepo.fetchManyUser(by: playerIDs)
            
            // Dictionary to map gamePlayerIDs to fetched Users for quick lookup
            let usersDictionary = Dictionary(uniqueKeysWithValues: zip(playerIDs, users))
            
            // Loop through entries and add corresponding user to the task group
            for entry in entries {
                guard let user = usersDictionary["\(entry.context)"] else {
                    throw NSError(domain: "UserFetchError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found for ID: \(entry.player.gamePlayerID)"])
                }
                
                // Add a task for each user-entry pair
                group.addTask {
                    return (entry, user)
                }
            }

            // Collect all results from the group
            var results: [(GKLeaderboard.Entry, User)] = []
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
    
    private func getUser(from entry: GKLeaderboard.Entry) async throws -> User {
        return try await userRepo.fetchAnyUser(by: entry.player.gamePlayerID)
    }
    
    private func loadSet(_ setID: LeaderboardSetID) async throws -> GKLeaderboardSet {
        let set = try await service.loadLeaderboardSets()
            .first(where: { $0.identifier == setID.rawValue })
        guard let set = set else { throw LeaderboardRepositoryError.setNotFound }
        return set
    }
    
    func submitScore(
        score: Int,
        context: Int,
        leaderboardIDs: [LeaderboardID]
    ) async throws -> ([Leaderboard], [LeaderboardID]) {
        try await service.submitScore(
            score,
            context: context,
            player: GKLocalPlayer.local,
            leaderboardIDs: leaderboardIDs.map({ ID in ID.rawValue })
        )
        
        var leaderboards: [Leaderboard] = []
        var errors: [LeaderboardID] = []
        
        // Use an async loop instead of forEach
        for leaderboardID in leaderboardIDs {
            do {
                let ldb = try await fetchAndCacheLeaderboard(leaderboardID: leaderboardID)
                leaderboards.append(ldb)
            } catch {
                errors.append(leaderboardID)
            }
        }
        
        return (leaderboards, errors)
    }
    
    func submitScore(
        score: Int,
        context: Int,
        leaderboardID: LeaderboardID
    ) async throws -> Leaderboard {
        try await service.submitScore(
            score,
            context: context,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID.rawValue]
        )
        return try await fetchAndCacheLeaderboard(leaderboardID: leaderboardID)
    }
}

// MARK: - Cache Manager
class LeaderboardCacheManager {
    private var storages: [LeaderboardID: FileStorage<Leaderboard>]
    
    init() {
        self.storages = [
            .experience: FileStorage(fileName: "experience.data"),
            .allTimeStars: FileStorage(fileName: "allTimeStars.data"),
            .currentStars: FileStorage(fileName: "allTimeAchievements.data")
        ]
    }
    
    func load(leaderboardID: LeaderboardID) async throws -> Leaderboard {
        guard let storage = storages[leaderboardID] else {
            throw LeaderboardRepositoryError.cacheFailure("No storage found for \(leaderboardID)")
        }
        return try await storage.load()
    }
    
    func save(leaderboard: Leaderboard) async throws {
        guard let storage = storages[leaderboard.leaderboardID] else {
            throw LeaderboardRepositoryError.cacheFailure("No storage found for \(leaderboard.leaderboardID)")
        }
        try await storage.save(data: leaderboard)
    }
}
