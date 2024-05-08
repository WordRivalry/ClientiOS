//
//  EvaluateWord.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-24.
//

import Foundation

typealias EvalWordPath = [(Int, Int)]
typealias Score = Int

struct EvaluateWordRequest {
    let wordPath: EvalWordPath
    let board: Board<Letter>
}

final class EvaluateWord: UseCaseProtocol {
    typealias Request = EvaluateWordRequest
    typealias Response = Score
    
    func execute(request: Request) -> Response {
        return evaluate(request.wordPath, board: request.board)
    }
    
    private func evaluate(_ path: EvalWordPath, board: Board<Letter>) -> Int {
        
        let word = path.compactMap { position -> String? in
            let cell = board.getCell(position.0, position.1)
            return cell.letter
        }.joined().lowercased()
        
        guard EfficientWordChecker.shared.checkWordExists(word) else {
            return 0
        }
        
        return calculateScore(for: path, within: board)
    }
        
    private func calculateScore(for path: EvalWordPath, within board: Board<Letter>) -> Int {
        var score = 0
        var wordMultipliers: [Int] = []
        
        for position in path {
            let cell = board.getCell(position.0, position.1)
            score += cell.getValue()
            if cell.wordMultiplier > 1 {
                wordMultipliers.append(cell.wordMultiplier)
            }
        }
        
        for wordMultiplier in wordMultipliers {
            score *= wordMultiplier
        }
        
        return score
    }
}
