//
//  OverallLeaderboardViewModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-07.
//

import Foundation


@Observable final class OverallLeaderboardViewModel: LeaderboardViewModel {
    
    override init(leaderboardID: LeaderboardID) {
        super.init(leaderboardID: leaderboardID)
    }
    
    
}

//
////
////  LeaderboardService.swift
////  Word Rivalry
////
////  Created by benoit barbier on 2024-04-09.
////
//
//import Foundation
//import OSLog
//
//// MARK: JITLeaderboard
//@Observable class LeaderboardViewModel: JITData, DataPreview {
//    var allTimeStars: Leaderboard?
//    var allTimeAchievement: Leaderboard?
//    var experience: Leaderboard?
//    
//    // Use case
//    private let fetchLeaderboard = LeaderboardUC()
//    
//    override func fetchData() async throws {
//    
//        // Work
//        let experience = try await fetchLeaderboard.fetchLeaderboard(with: .experience)
//        let allTimeAchievement = try await fetchLeaderboard.fetchLeaderboard(with: .allTimeAchievements)
//        let allTimeStars = try await fetchLeaderboard.fetchLeaderboard(with: .allTimeStars)
//        
//        // UI
//        await MainActor.run {
//            self.experience = experience
//            self.allTimeAchievement = allTimeAchievement
//            self.allTimeStars = allTimeStars
//            Logger.dataServices.info("Leaderboard updated")
//        }
//    }
//    
//    override func isDataAvailable() -> Bool {
//        if allTimeStars == nil || allTimeAchievement == nil || experience == nil {
//            return false
//        }
//        return true
//    }
//    
//    // MARK: DataPreview
//    
//    static var preview: LeaderboardViewModel = {
//        let previewModel = LeaderboardViewModel()
//        previewModel.allTimeStars = Leaderboard.previewLeaderboard(
//            id: .allTimeStars
//        )
//        previewModel.allTimeAchievement = Leaderboard.previewLeaderboard(
//            id: .allTimeAchievements
//        )
//        previewModel.experience = Leaderboard.previewLeaderboard(
//            id: .experience
//        )
//        return previewModel
//    }()
//}
//
//extension Leaderboard {
//    static func previewLeaderboard(id: LeaderboardID) -> Leaderboard {
//        let leaderboard = Leaderboard(leaderboardID: id)
//        leaderboard.top50 = (1...50).map { rank in
//            LeaderboardEntry.mockEntry(rank: rank, leaderboardID: id)
//        }
//        
//        return leaderboard
//    }
//}
//
//extension LeaderboardEntry {
//    static func mockEntry(rank: Int, leaderboardID: LeaderboardID) -> LeaderboardEntry {
//        return LeaderboardEntry(
//            gamePlayerID: "Player\(rank)",
//            displayName: "Player \(rank)",
//            user: User.mockUser(rank: rank),
//            context: rank * 100,
//            date: Date(),
//            formattedScore: "\(rank * 1000)",
//            rank: rank,
//            score: rank * 1000
//        )
//    }
//}
//
//extension User {
//    static func mockUser(rank: Int) -> User {
//        return User(
//            userID: "U00\(rank)",
//            country: .america,
//            title: .newLeaf,
//            avatar: .newLeaf,
//            primaryColor: "#\(rank * 100000)",
//            avatarFrame: .none,
//            profileEffect: .none,
//            accent: "#\(rank * 100000)",
//            allTimePoints: rank * 1000,
//            experience: rank * 100,
//            currentPoints: rank * 500,
//            soloMatch: rank * 10,
//            soloWin: rank * 5,
//            teamMatch: rank * 3,
//            teamWin: rank * 2
//        )
//    }
//}
