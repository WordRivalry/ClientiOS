//
//  LeaderboardService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

@Observable final class LeaderboardService: JITData {
    var players: [PublicProfile] = []
      
    @MainActor
    override func fetchData() async {
        do {
            self.players = try await fetchPlayers()
            Logger.dataServices.info("Leaderboard updated")
        } catch {
            Logger.dataServices.error("Failed to fetch top players: \(error.localizedDescription)")
        }
    }
    
    override func isDataAvailable() -> Bool {
        if players.isEmpty {
            return false
        }
        return true
    }
    
    private func fetchPlayers() async throws -> [PublicProfile] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        return try await PublicDatabase.shared.fetchLeaderboard(limit: 50)
    }
    
    static var preview: LeaderboardService {
        let leaderboardService = LeaderboardService()
        leaderboardService.players = [
            PublicProfile(userRecordID: "", playerName: "Darkfeu", eloRating: 1892, title: "Word Conqueror",profileImage: "PI_15"),
            PublicProfile(userRecordID: "", playerName: "Feudala", eloRating: 1832, title: "Word Smith", profileImage: "PI_2"),
            PublicProfile(userRecordID: "", playerName: "Osamodas", eloRating: 1745, title: "Word Conqueror", profileImage: "PI_14"),
            PublicProfile(userRecordID: "", playerName: "Enutrof", eloRating: 1691, title: "Word Smith", profileImage: "PI_4"),
            PublicProfile(userRecordID: "", playerName: "Cra", eloRating: 1689, title: "New Leaf", profileImage: "PI_5"),
            PublicProfile(userRecordID: "", playerName: "Dartagnan", eloRating: 1676, title: "New Leaf", profileImage: "PI_12"),
            PublicProfile(userRecordID: "", playerName: "Darkfeu", eloRating: 1645, title: "Word Conqueror",profileImage: "PI_15"),
            PublicProfile(userRecordID: "", playerName: "Feudala", eloRating: 1643, title: "Word Smith", profileImage: "PI_2"),
            PublicProfile(userRecordID: "", playerName: "Osamodas", eloRating: 1623, title: "Word Conqueror", profileImage: "PI_14"),
            PublicProfile(userRecordID: "", playerName: "Enutrof", eloRating: 1621, title: "Word Smith", profileImage: "PI_4"),
            PublicProfile(userRecordID: "", playerName: "Cra", eloRating: 1615, title: "New Leaf", profileImage: "PI_5"),
            PublicProfile(userRecordID: "", playerName: "Dartagnan", eloRating: 1613, title: "New Leaf", profileImage: "PI_12"),
            PublicProfile(userRecordID: "", playerName: "Darkfeu", eloRating: 1609, title: "Word Conqueror",profileImage: "PI_15"),
            PublicProfile(userRecordID: "", playerName: "Feudala", eloRating: 1578, title: "Word Smith", profileImage: "PI_2"),
            PublicProfile(userRecordID: "", playerName: "Osamodas", eloRating: 1545, title: "Word Conqueror", profileImage: "PI_14"),
            PublicProfile(userRecordID: "", playerName: "Enutrof", eloRating: 1531, title: "Word Smith", profileImage: "PI_4"),
            PublicProfile(userRecordID: "", playerName: "Cra", eloRating: 1529, title: "New Leaf", profileImage: "PI_5"),
            PublicProfile(userRecordID: "", playerName: "Dartagnan", eloRating: 1526, title: "New Leaf", profileImage: "PI_12"),
            PublicProfile(userRecordID: "", playerName: "Darkfeu", eloRating: 1522, title: "Word Conqueror",profileImage: "PI_15"),
            PublicProfile(userRecordID: "", playerName: "Feudala", eloRating: 1512, title: "Word Smith", profileImage: "PI_2"),
            PublicProfile(userRecordID: "", playerName: "Osamodas", eloRating: 1445, title: "Word Conqueror", profileImage: "PI_14"),
            PublicProfile(userRecordID: "", playerName: "Enutrof", eloRating: 1391, title: "Word Smith", profileImage: "PI_4"),
            PublicProfile(userRecordID: "", playerName: "Cra", eloRating: 1289, title: "New Leaf", profileImage: "PI_5"),
            PublicProfile(userRecordID: "", playerName: "Dartagnan", eloRating: 1276, title: "New Leaf", profileImage: "PI_12"),
            PublicProfile.preview,
        ]
        return leaderboardService
    }
}
