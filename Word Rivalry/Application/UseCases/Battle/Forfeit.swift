//
//  Forfeit.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation


struct ForfeitRequest {
    let battleSocket: BattleSocketService
}

final class Forfeit: UseCaseProtocol {
    typealias Request = ForfeitRequest
    typealias Response = Void
    
    func execute(request: Request) async throws -> Void {
        request.battleSocket.leaveGame()
    }
}
