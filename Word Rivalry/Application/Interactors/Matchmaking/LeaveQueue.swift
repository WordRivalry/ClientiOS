//
//  LeaveQueue.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

final class LeaveQueue: UseCaseProtocol {
    typealias Request = MatchmakingSocketService
    typealias Response = Void

    func execute(request: Request) throws -> Void {
        
        guard let status = request.status() else {
            throw MatchmakingUCError.statusUnavailable
        }
        
        switch status {
        case .connecting, .connected:
            request.disconnect()
        case .disconnected, .notConnected:
            throw MatchmakingUCError.disconnected
        }
    }
}
