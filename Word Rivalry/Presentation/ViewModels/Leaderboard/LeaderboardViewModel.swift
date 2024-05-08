//
//  LeaderboardService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

// MARK: JITLeaderboard
@Observable class LeaderboardViewModel: JITData {
    var leaderboard: Leaderboard?
    private let leaderboardID: LeaderboardID
    
    // Use case
    private let fetchLeaderboard = LeaderboardFetcher()
    
    init(leaderboardID: LeaderboardID) {
        self.leaderboardID = leaderboardID
    }
    
    override func fetchData() async throws {
    
        // Work
        let leaderboard = try await fetchLeaderboard.fetchLeaderboard(with: self.leaderboardID)
        
        // UI
        await MainActor.run {
            self.leaderboard = leaderboard
            Logger.dataServices.info("Leaderboard \(self.leaderboardID.rawValue) updated")
        }
    }
    
    override func isDataAvailable() -> Bool {
        if leaderboard == nil {
            return false
        }
        return true
    }

    static func previewLeaderboard(id: LeaderboardID) -> Leaderboard {
        let leaderboard = Leaderboard(leaderboardID: id)
        leaderboard.top50 = (1...50).map { rank in
            LeaderboardEntry.mockEntry(rank: rank, leaderboardID: id)
        }
        leaderboard.top50 = leaderboard.top50.sorted { entry1, entry2 in
            entry1.rank < entry2.rank
        }
        return leaderboard
    }
}

extension LeaderboardEntry {
    static func mockEntry(rank: Int, leaderboardID: LeaderboardID) -> LeaderboardEntry {
        return LeaderboardEntry(
            gamePlayerID: "Player\(rank)",
            displayName: "Player \(rank)",
            user: User.mockUser(rank: rank),
            context: rank * 100,
            date: Date(),
            formattedScore: "\(rank * 1000)",
            rank: rank,
            score: rank * 1000
        )
    }
}

extension User {
    static func mockUser(rank: Int) -> User {
        return User(
            userID: "U00\(rank)",
            country: .america,
            title: .newLeaf,
            avatar: .newLeaf,
            primaryColor: "#\(rank * 100000)",
            avatarFrame: .none,
            profileEffect: .none,
            accent: "#\(rank * 100000)",
            allTimePoints: rank * 1000,
            experience: rank * 100,
            currentPoints: rank * 500,
            soloMatch: rank * 10,
            soloWin: rank * 5,
            teamMatch: rank * 3,
            teamWin: rank * 2
        )
    }
}
