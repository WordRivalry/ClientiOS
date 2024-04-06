//
//  TopPlayers.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import Foundation
import os.log

@Observable final class LeaderboardService: Service {
    var isReady: Bool = false
    
    var players: [Profile] = []
    private let logger = Logger(subsystem: "com.WordRivalry", category: "TopPlayers")
    private var timer: Timer?
    
    init() {
        self.logger.info("*** LeaderboardService STARTED ***")
        fetchAndUpdatePlayers()
    }
    
    func fetchAndUpdatePlayers() {
        Task {
            do {
                let players = try await PublicDatabase.shared.fetchTopPlayersRankedByElo(limit: 50)
                self.players = players
                self.logger.info("TopPlayers updated.")
            } catch {
                self.logger.error("Failed to fetch top players: \(error.localizedDescription)")
                self.players = []
            }
            self.logger.info("*** LeaderboardService COMPLETED ***")
            self.isReady = true
        }
    }
    
    func startPeriodicUpdate() {
        // Invalidate existing timer if any
        timer?.invalidate()
        
        // Set up a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.fetchAndUpdatePlayers()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    static var preview: LeaderboardService {
        let leaderboard = LeaderboardService()
        leaderboard.players = [
            Profile.preview,
            Profile(userRecordID: "234234234", playerName: "Player 1"),
            Profile(userRecordID: "234234234", playerName: "Player 2"),
            Profile(userRecordID: "234234234", playerName: "Player 3"),
            Profile(userRecordID: "234234234", playerName: "Player 4"),
            Profile(userRecordID: "234234234", playerName: "Player 5"),
        ]
        return leaderboard
    }
}
