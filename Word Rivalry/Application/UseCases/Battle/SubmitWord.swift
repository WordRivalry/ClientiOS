//
//  SubmitWord.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-21.
//

import Foundation

struct SubmitWordRequest {
    let wordPath: WordPath
    let battleSocket: BattleSocketService
}

final class SubmitWord: UseCaseProtocol {
    typealias Request = SubmitWordRequest
    typealias Response = Void
    
    func execute(request: Request) async throws -> Void {
        let battleSocket = request.battleSocket
        let wordPath = request.wordPath
        battleSocket.sendScoreUpdate(wordPath: wordPath)
    }
}
