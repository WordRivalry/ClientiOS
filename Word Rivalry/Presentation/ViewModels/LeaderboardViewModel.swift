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
            User(
                userID: "U001",
                username: "Darkfeu",
                country: .america,
                title: .newLeaf,
                avatar: .newLeaf,
                primaryColor: "#FFF",
                avatarFrame: .none,
                profileEffect: .none,
                accent: "#FFF",
                allTimePoints: 2999,
                experience: 742,
                currentPoints: 1230,
                soloMatch: 134,
                soloWin: 50,
                teamMatch: 34,
                teamWin: 22
            ),
            User(
                userID: "U002",
                username: "BrightStar",
                country: .europeAfrica,
                title: .veteran,
                avatar: .veteran,
                primaryColor: "#000",
                avatarFrame: .silver,
                profileEffect: .glitter,
                accent: "#FFD700",
                allTimePoints: 2120,
                experience: 680,
                currentPoints: 1100,
                soloMatch: 120,
                soloWin: 40,
                teamMatch: 45,
                teamWin: 25
            ),
            User(
                userID: "U003",
                username: "LeafRider",
                country: .asiaAustralia,
                title: .explorer,
                avatar: .explorer,
                primaryColor: "#008000",
                avatarFrame: .gold,
                profileEffect: .sparkle,
                accent: "#FA8072",
                allTimePoints: 1500, 
                experience: 550,
                currentPoints: 900,
                soloMatch: 150,
                soloWin: 70,
                teamMatch: 50,
                teamWin: 30
            ),
            User(
                userID: "U004",
                username: "NightWatcher",
                country: .australia,
                title: .guardian,
                avatar: .guardian,
                primaryColor: "#483D8B",
                avatarFrame: .bronze,
                profileEffect: .shine,
                accent: "#00BFFF",
                allTimePoints: 1750,
                experience: 800,
                currentPoints: 950,
                soloMatch: 90,
                soloWin: 35,
                teamMatch: 20,
                teamWin: 10
            ),
            User(
                userID: "U005",
                username: "SkySailor",
                country: .america,
                title: .pioneer,
                avatar: .pioneer,
                primaryColor: "#4682B4",
                avatarFrame: .none,
                profileEffect: .none,
                accent: "#DA70D6",
                allTimePoints: 3200,
                experience: 920,
                currentPoints: 1500,
                soloMatch: 160,
                soloWin: 80,
                teamMatch: 60,
                teamWin: 35
            )
        ]
        return leaderboardService
    }()
}
