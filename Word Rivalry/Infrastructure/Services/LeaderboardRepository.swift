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
        if let cachedLeaderboard = try? await cacheManager.load(leaderboardID: leaderboardID), isCacheValid(for: cachedLeaderboard) {
            return cachedLeaderboard
        }
        
        return try await fetchAndCacheLeaderboard(leaderboardID: leaderboardID)
    }
    
    private func isCacheValid(for leaderboard: Leaderboard) -> Bool {
        return Date.now.timeIntervalSince(leaderboard.updateDate) <= 300
    }
    
    private func fetchAndCacheLeaderboard(
        leaderboardID: LeaderboardID
    ) async throws -> Leaderboard {
        
        let set = try await loadSet(.normal)
        
        var gkLeaderboard: GKLeaderboard? = nil
        var error: Error? = nil
        
        set.loadLeaderboards { leaderboards, err in
            error = err
            gkLeaderboard = leaderboards?.first(where: {
                $0.baseLeaderboardID == leaderboardID.rawValue
            })
        }
        
        guard error == nil else {
            throw error!
        }
        
        guard let gkLeaderboard = gkLeaderboard else {
            throw LeaderboardRepositoryError.fetchLeaderboardFailure
        }
        
        let (localEntry, top50, count) = try await self.service.loadEntries(
            from: gkLeaderboard,
            for: .global,
            timeScope: .allTime,
            startRank: 1,
            length: 50
        )
        
        let leaderboard = Leaderboard(leaderboardID: leaderboardID)
        
        leaderboard.top50 = try await getUsers(from: top50)
            .map({ (entry, user) in
                LeaderboardEntry(from: entry, user: user)
            })
        
        if let localEntry = localEntry {
            
            let user = try await getUser(from: localEntry)
            
            leaderboard.localEntry = LeaderboardEntry(from: localEntry, user: user)
            var surrounding = try await service.loadScoresAroundEntry(
                from: gkLeaderboard,
                centeredOn: localEntry,
                range: 10
            )
            
            let surroundingUsers = try await getUsers(from: surrounding)
            
            leaderboard.entriesBeforeLocal = surroundingUsers
                .prefix(5)
                .map({ entry, user in
                    LeaderboardEntry(from: entry, user: user)
                })
            
            if surrounding.count > 5 {
                leaderboard.entriesAfterLocal = surroundingUsers
                    .suffix(from: 5)
                    .map({ entry, user in
                        LeaderboardEntry(from: entry, user: user)
                    })
            }
        }
        
        try await cacheManager.save(leaderboard: leaderboard)
        return leaderboard
    }
    
    private func processLocalPlayerEntry(
        _ entry: GKLeaderboard.Entry,
        gkLeaderboard: GKLeaderboard
    ) async throws -> LeaderboardEntry {
        
        let user = try await userRepo.fetchAnyUser(by: entry.player.gamePlayerID)
        return LeaderboardEntry(from: entry, user: user)
    }
    
    
    private func getUser(from entry: GKLeaderboard.Entry) async throws -> User {
        return try await userRepo.fetchAnyUser(by: entry.player.gamePlayerID)
    }
    
    private func getUsers(from entries: [GKLeaderboard.Entry]) async throws -> [(GKLeaderboard.Entry, User)] {
        return try await withThrowingTaskGroup(of: (GKLeaderboard.Entry, User).self) { group in
            for entry in entries {
                group.addTask {
                    let user = try await self.getUser(from: entry)
                    return (entry, user)
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
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
