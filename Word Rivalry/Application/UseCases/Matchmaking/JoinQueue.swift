//
//  JoinQueue.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

struct JoinQueueRequest {
    let user: User
    let matchmakingSocket: MatchmakingSocketService
}

final class JoinQueue: UseCaseProtocol {
    typealias Request = JoinQueueRequest
    typealias Response = Void

    func execute(request: Request) async throws -> Void {
        let matchmakingSocket = request.matchmakingSocket
        let user = request.user
        
        guard let status = matchmakingSocket.status() else {
            throw MatchmakingUCError.statusUnavailable
        }
        
        if status == .disconnected || status == .notConnected {
            matchmakingSocket.connect(playerID: user.recordName, playerName: user.playerName)
        }
        
        if status == .connecting || status == .connected {
            try matchmakingSocket.findMatch(gameMode: .RANK, modeType: .NORMAL, eloRating: user.eloRating)
        } else {
            throw MatchmakingUCError.matchmakingUnavailable
        }
    }
}
