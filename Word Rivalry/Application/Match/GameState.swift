//
//  GameEngine.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation

struct LetterTile: Equatable, Hashable, Codable {
    let letter: String
    let value: Int
    var letterMultiplier: Int
    var wordMultiplier: Int
    
    init(letter: String, value: Int, letterMultiplier: Int = 1, wordMultiplier: Int = 1) {
        self.letter = letter
        self.value = value
        self.letterMultiplier = letterMultiplier
        self.wordMultiplier = wordMultiplier
    }
}

enum GameError: Error {
    case notOngoing
    case invalidMove
    case invalidWord
    case gameFinished
}

struct GameResults {
    var winner: String
    var playerResults: [PlayerResult]
 
    // Follow null pattern
    init(winner: String, playerResults: [PlayerResult]) {
        self.winner = winner
        self.playerResults = playerResults
    }
}

@Observable class GameState {
    
    // MARK: States
    
    var myScore: Int = 0
    var pathScore: Int = 0
    var wordFound: [String] = []
    var startTime: Date
    var endTime: Date
    var board: Board<LetterTile>
    var stats: GridStats
    var valid_words: [String]
    var message: String = ""
    var opponentName: String = ""
    var opponentScore: Int = 0
    var gameResults: GameResults?
 

    // MARK: INIT
    
    init(
        startTime: Date,
        endTime: Date,
        board: Board<LetterTile>,
        valid_words: [String],
        stats: GridStats
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.board = board
        self.valid_words = valid_words
        self.stats = stats
    }

    // MARK: Word Evaluation
    
    func tryWord(path: [(Int, Int)]) -> Int {
        var score: Int = 0
        do {
            score = try attemptWord(path: path)
            myScore += score
            message = "Word Accepted: +\(score) points"
        } catch GameError.notOngoing {
            message = "The game is not currently ongoing."
        } catch GameError.invalidWord {
            message = "That is not a valid word."
        } catch GameError.invalidMove {
            message = "This word has already been used."
        } catch {
            message = "An unknown error occurred."
        }
        
        return score
    }
    
    func attemptWord(path: [(Int, Int)]) throws -> Int {
        guard gameResults == nil else {
            throw GameError.gameFinished
        }
        
        let word = path.compactMap { position -> String? in
            let cell = board.getCell(position.0, position.1)
            return cell.letter
        }.joined().lowercased()
        
        guard EfficientWordChecker.shared.checkWordExists(word) else {
            throw GameError.invalidWord
        }
        
        guard !wordFound.contains(word) else {
            throw GameError.invalidMove
        }
        
        let score = calculateScore(forPath: path)
        
        wordFound.append(word)
        
        return score
    }
    
    // Calculate the score for a given word path
    func calculateScore(forPath path: [(Int, Int)]) -> Int {
        var score = 0
        var wordMultipliers: [Int] = []
        
        for position in path {
            let cell = board.getCell(position.0, position.1)
            score += cell.value * cell.letterMultiplier
            if (cell.wordMultiplier > 1) {
                wordMultipliers.append(cell.wordMultiplier)
            }
        }
        
        for wordMultiplier in wordMultipliers {
            score *= wordMultiplier
        }
        
        return score
    }
}
