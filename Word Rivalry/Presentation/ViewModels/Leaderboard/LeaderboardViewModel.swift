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


    var leaderboard: Leaderboard?
    private let leaderboardID: LeaderboardID
    
    // Use case
    private let fetchLeaderboard = LeaderboardFetcher()
    
    init(leaderboardID: LeaderboardID) {
        self.leaderboardID = leaderboardID
    }
    
    override func fetchData() async throws {
    
        do {
            // Work
//            let leaderboard = try await fetchLeaderboard.fetchLeaderboard(
//                with: self.leaderboardID
//            )
            
            let leaderboard = LeaderboardViewModel.preview.leaderboard
            
            // UI
            await MainActor.run {
                self.leaderboard = leaderboard
                Logger.dataServices.info("Leaderboard \(self.leaderboardID.rawValue) updated")
            }
        } catch {
            Logger.dataServices.fault("Error occured fetching leaderboard. Error: \(error)")
            throw error
        }
    }
    
    override func isDataAvailable() -> Bool {
        if leaderboard == nil {
            return false
        }
        return true
    }
    
    static var preview: LeaderboardViewModel = {
        let leaderboard = Leaderboard(leaderboardID: .experience)
        leaderboard.topPlayers = (1...50).map { rank in
            LeaderboardEntry.mockEntry(rank: rank, leaderboardID: .experience)
        }
        leaderboard.topPlayers = leaderboard.topPlayers.sorted { entry1, entry2 in
            entry1.rank < entry2.rank
        }
        
        let viewModel = LeaderboardViewModel(leaderboardID: .experience)
        viewModel.leaderboard = leaderboard
        
        return viewModel
    }()
    
//
//    static var preview: SoloGameViewModel = {
//         let vm = SoloGameViewModel(
//            gameID: "",
//            localUser: .preview,
//            adversary: .previewOther,
//            battleSocket: BattleSocketService()
//        )
//        vm.game = .preview
//        return vm
//    }()
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
            country: .random(),
            title: .random(),
            avatar: .random(),
            primaryColor: "#\(rank * 100000)",
            avatarFrame: .random(),
            profileEffect: .random(),
            accent: "#\(rank * 100000)",
            allTimePoints: rank * 1000,
            experience: rank * 100,
            currentStars: rank * 500,
            soloMatch: rank * 10,
            soloWin: rank * 5,
            teamMatch: rank * 3,
            teamWin: rank * 2
        )
    }
}
