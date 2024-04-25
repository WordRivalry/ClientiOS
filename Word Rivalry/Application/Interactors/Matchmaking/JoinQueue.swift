//
//  JoinQueue.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

final class JoinQueue: UseCaseProtocol {
    typealias Request = MatchmakingSocketService
    typealias Response = Void

    let userRepository: UserRepository = UserRepository()
    
    func execute(request: Request) async throws -> Void {
        
        guard let status = request.status() else {
            throw MatchmakingUCError.statusUnavailable
        }
        
        // Fetch user to ensure freshness
        let user: User = try await userRepository.fetchUser()
        
        if status == .disconnected || status == .notConnected {
            request.connect(playerID: user.recordName, playerName: user.playerName)
        }
        
        if status == .connecting || status == .connected {
            try request.findMatch(gameMode: .RANK, modeType: .NORMAL, eloRating: user.eloRating)
        } else {
            throw MatchmakingUCError.matchmakingUnavailable
        }
    }
}
