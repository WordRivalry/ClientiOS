//
//  LeaderboardService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

// MARK: JITLeaderboard
@Observable final class LeaderboardViewModel: JITData, DataPreview {
    var topPlayers: [User]?

    // Use case
    private let fetchLeaderboard = LeaderboardFetch()
      
    override func fetchData() async throws {
        
        // Work
        let players = try await fetchLeaderboard.execute(request: 50)
        
        // UI
        await MainActor.run {
            self.topPlayers = players
            Logger.dataServices.info("Leaderboard updated")
        }
    }
    
    override func isDataAvailable() -> Bool {
        if topPlayers == nil {
            return false
        }
        return true
    }
    
    // MARK: DataPreview
    
    static var preview: LeaderboardViewModel = {
        let leaderboardService = LeaderboardViewModel()
        leaderboardService.topPlayers = [
            User(playerName: "Darkfeu", eloRating: 1892, title: "Word Conqueror",profileImage: "PI_15"),
            User(playerName: "Feudala", eloRating: 1832, title: "Word Smith", profileImage: "PI_2"),
            User(playerName: "Osamodas", eloRating: 1745, title: "Word Conqueror", profileImage: "PI_14"),
            User(playerName: "Enutrof", eloRating: 1691, title: "Word Smith", profileImage: "PI_4"),
            User(playerName: "Cra", eloRating: 1689, title: "New Leaf", profileImage: "PI_5"),
            User(playerName: "Dartagnan", eloRating: 1676, title: "New Leaf", profileImage: "PI_12"),
            User(playerName: "Darkfeu", eloRating: 1645, title: "Word Conqueror",profileImage: "PI_15"),
            User(playerName: "Feudala", eloRating: 1643, title: "Word Smith", profileImage: "PI_2"),
            User(playerName: "Osamodas", eloRating: 1623, title: "Word Conqueror", profileImage: "PI_14"),
            User(playerName: "Enutrof", eloRating: 1621, title: "Word Smith", profileImage: "PI_4"),
            User(playerName: "Cra", eloRating: 1615, title: "New Leaf", profileImage: "PI_5"),
            User(playerName: "Dartagnan", eloRating: 1613, title: "New Leaf", profileImage: "PI_12"),
            User(playerName: "Darkfeu", eloRating: 1609, title: "Word Conqueror",profileImage: "PI_15"),
            User(playerName: "Feudala", eloRating: 1578, title: "Word Smith", profileImage: "PI_2"),
            User(playerName: "Osamodas", eloRating: 1545, title: "Word Conqueror", profileImage: "PI_14"),
            User(playerName: "Enutrof", eloRating: 1531, title: "Word Smith", profileImage: "PI_4"),
            User(playerName: "Cra", eloRating: 1529, title: "New Leaf", profileImage: "PI_5"),
            User(playerName: "Dartagnan", eloRating: 1526, title: "New Leaf", profileImage: "PI_12"),
            User(playerName: "Darkfeu", eloRating: 1522, title: "Word Conqueror",profileImage: "PI_15"),
            User(playerName: "Feudala", eloRating: 1512, title: "Word Smith", profileImage: "PI_2"),
            User(playerName: "Osamodas", eloRating: 1445, title: "Word Conqueror", profileImage: "PI_14"),
            User(playerName: "Enutrof", eloRating: 1391, title: "Word Smith", profileImage: "PI_4"),
            User(playerName: "Cra", eloRating: 1289, title: "New Leaf", profileImage: "PI_5"),
            User(playerName: "Dartagnan", eloRating: 1276, title: "New Leaf", profileImage: "PI_12"),
            User.preview,
        ]
        return leaderboardService
    }()
}
