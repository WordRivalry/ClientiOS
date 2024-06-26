//
//  ProfileLeaderboardCoordinator.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-07.
//

import Foundation

/// This class assumes the responsability to coordinate the user data and score submission to leaderboard.
///  - Experience
///  - AllTimeStars
///  - CurrentStars
final class UserAndLeaderboardCoordinator {
    
    private let leaderboardRepo: LeaderboardRepositoryProtocol
    private let localUser: LocalUser
    
    init(
        leaderboardRepo: LeaderboardRepositoryProtocol = LeaderboardRepository(),
        localUser: LocalUser = .shared // Default
    ) {
        self.leaderboardRepo = leaderboardRepo
        self.localUser = localUser
    }
    
    func decreaseStars(_ stars: Int) async throws {
        let result = await localUser.decreaseStars(by: stars)
        
        switch result {
        case .success(let successType):
            debugPrint("Decrease successfull")
        case .failure(let userModificationError):
            throw userModificationError
        }
    }
    
    func updateSoloGame(won didWin: Bool, stars: Int) async throws {
        let result = await localUser.playedSoloMatch(didWin: didWin, stars: stars)
        
        switch result {
        case .success(let user):
            
            // Most sensitive update
            // no correction possible on failure
            
            _ = try await leaderboardRepo.submitScore(
                score: user.currentStars,
                context: Int(user.userID)!,
                leaderboardID: .currentStars
            )
            
            // Those two can auto correct on the next update.
            
            _ = try await leaderboardRepo.submitScore(
                score: user.experience,
                context: Int(user.userID)!,
                leaderboardID: .experience
            )
            
            _ = try await leaderboardRepo.submitScore(
                score: user.allTimeStars,
                context: Int(user.userID)!,
                leaderboardID: .allTimeStars
            )
            
        case .failure(let userModificationError):
            debugPrint("Bad error occured")
        }
    }
    
    func updateTeamGame(won didWin: Bool, stars: Int) async throws {
        let result = await localUser.playedTeamMatch(didWin: didWin, stars: stars)
        
        switch result {
        case .success(let user):
            
            // Most sensitive update
            // no correction possible on failure
            
            _ = try await leaderboardRepo.submitScore(
                score: user.currentStars,
                context: Int(user.userID)!,
                leaderboardID: .currentStars
            )
            
            // Those two can auto correct on the next update.
            
            _ = try await leaderboardRepo.submitScore(
                score: user.experience,
                context: Int(user.userID)!,
                leaderboardID: .experience
            )
            
            _ = try await leaderboardRepo.submitScore(
                score: user.allTimeStars,
                context: Int(user.userID)!,
                leaderboardID: .allTimeStars
            )
            
        case .failure(let userModificationError):
            debugPrint("Bad error occured")
        }
    }
}
