//
//  JoinQueue.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation
import GameKit

struct JoinQueueRequest {
    let network: MatchmakingSocketService
    let stake: Int
}

final class JoinQueue: UseCaseProtocol {
    typealias Request = JoinQueueRequest
    typealias Response = Void

    let userRepository: UserRepository = UserRepository()
    
    func execute(request: Request) async throws -> Void {
        let network = request.network
        let stake = request.stake
        
        guard let status = network.status() else {
            throw MatchmakingUCError.statusUnavailable
        }
        
        // Fetch user to ensure freshness
        let user: User = try await userRepository.fetchLocalUser()
        
        if status == .disconnected || status == .notConnected {
            network.connect(userID: user.userID, username: GKLocalPlayer.local.displayName)
        }
        
        if status == .connecting || status == .connected {
            try network.findMatch(stake: stake)
        } else {
            throw MatchmakingUCError.matchmakingUnavailable
        }
    }
}
