//
//  WordLinkGameModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import Foundation
import Combine

// Assuming a structure to represent a letter's properties on the board
struct LetterTile: Equatable, Hashable {
    let letter: String
    let score: Int
    var letterMultiplier: Int
    var wordMultiplier: Int
    
    init(letter: String, score: Int, letterMultiplier: Int = 1, wordMultiplier: Int = 1) {
        self.letter = letter
        self.score = score
        self.letterMultiplier = letterMultiplier
        self.wordMultiplier = wordMultiplier
    }
}

enum GameError: Error {
    case notOngoing
    case invalidMove
    case invalidWord
}

enum GameStatus {
    case notStarted
    case ongoing
    case finished
}

@Observable class GameModel: BoardViewModel<LetterTile> {
    
    // MARK: OBSERVED PROPERTIES
    
    var currentScore: Int = 0
    var currentPathScore: Int = 0
    var message: String = ""
    var gameStatus: GameStatus = .notStarted
    
    
    // Delegate
    var timeLeft: String = ""
    var roundNumber: Int = 0
    var gameDuration: Int = 0
    var opponentUsername: String = ""
    var opponentRecentScore: Int = 0
    
    @ObservationIgnored
    private var alreadyDoneWords: [String] = []

    // MARK: INIT
    
    init() {
        super.init(
            board: Board(
                rows: 4,
                cols: 4,
                initialValue: LetterTile(
                    letter: "",
                    score: 0,
                    letterMultiplier: 1,
                    wordMultiplier: 1)
            )
        )
        
        setupDelegates()
    }
    
    func setupDelegates() {
        self.swipeDelegate = self
        self.tapDelegate = self
        WebSocketService.shared.setGameDelegate(self)
    }
    
    // MARK: GAME START
    
    func startGame() {
        gameStatus = .ongoing
    }
    
    func shuffleBoard() {
        var tiles = board.getAllCells().shuffled()
        for row in 0..<board.rows {
            for col in 0..<board.cols {
                board.setCell(row, col, value: tiles.removeFirst())
            }
        }
    }
    
    
    // MARK: GAME ACTION
    
    func evalWord(path: [(Int, Int)]) -> Int {
        var score: Int = 0
        do {
            score = try attemptWord(path: path)
            currentScore += score
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
        guard gameStatus == .ongoing else {
            throw GameError.notOngoing
        }
        
        print("going the length")
        
        let word = path.compactMap { position -> String? in
            let cell = board.getCell(position.0, position.1)
            return cell.letter
        }.joined().lowercased()
        
        print(word)
        
        guard WordChecker.shared.wordExists(word) else {
            throw GameError.invalidWord
        }
        
        guard !alreadyDoneWords.contains(word) else {
            throw GameError.invalidMove
        }
        
        let score = calculateScore(forPath: path)
        alreadyDoneWords.append(word)
        return score
    }
    
    // Calculate the score for a given word path
    func calculateScore(forPath path: [(Int, Int)]) -> Int {
        var score = 0
        var wordMultipliers: [Int] = []
        
        for position in path {
            let cell = board.getCell(position.0, position.1)
            score += cell.score * cell.letterMultiplier
            if (cell.wordMultiplier > 1) {
                wordMultipliers.append(cell.wordMultiplier)
            }
        }
        
        for wordMultiplier in wordMultipliers {
            score *= wordMultiplier
        }
        
        return score
    }
    
    // Record a word as found
    func markWordAsDone(word: String) {
        alreadyDoneWords.append(word)
    }
    
    // MARK: GAME FINISHED
    
    
    func gameTimesUp() {
        gameStatus = .finished
        timeLeft = "Time's up!"
    }
    
}


//MARK: SWIPE DELAGATE
extension GameModel: Board_OnSwipe_Delegate {
    
    func onCellHoverEntered(_ cellIndex: CellIndex) {
        
        let cellScore = scoreForTile(at: cellIndex)
        currentPathScore += cellScore
    }
    
    
    func onCellHoverStayed(_ cellIndex: CellIndex) {
        
    }
    
    func onCellHoverBacktracked(_ cellIndex: CellIndex) {
        let cellScore = scoreForTile(at: cellIndex)
        currentPathScore -= cellScore
    }
    
    
    func onSwipeProcessed() {
        // Attempt to form and score the word based on the final path
        let path = cellsInDragPath.map { [$0.i, $0.j] }
        let path2 = cellsInDragPath.map { ($0.i, $0.j) }
        
        let wordScore = evalWord(path: path2)
        if (wordScore > 0) {
            WebSocketService.shared.sendScoreUpdate(wordPath: path)
        }
    
        // Clear the path and reset path score for the next attempt
        cellsInDragPath.removeAll()
        currentPathScore = 0
    }
    
    
    private func scoreForTile(at cellIndex: CellIndex) -> Int {
        print(cellIndex)
        
        let tile = board.getCell(cellIndex.i, cellIndex.j)
        return tile.score * tile.letterMultiplier // You might also consider word multipliers here
    }
    
}

//MARK: TAP DELAGATE
extension GameModel: Board_OnTap_Delegate {
    func onTapGesture(_ cellIndex: CellIndex) {
        // Example implementation
        let tappedCell = getCell(cellIndex.i, cellIndex.j)
        // Process the tap on the cell, e.g., select the cell, start a word, etc.
        print("Tapped cell at \(cellIndex.i), \(cellIndex.j) with letter \(tappedCell.letter)")
    }
}

// MARK: WS DELEGATE
extension GameModel: WebSocket_GameDelegate {
    
    func didReceiveRoundStart(roundNumber: Int, duration: Int, grid: [[LetterTile]]) {
        DispatchQueue.main.async {
            self.roundNumber = roundNumber
            self.gameDuration = duration
            self.board = Board(grid: grid)
        }
    }
    
    func didUpdateTime(_ remainingTime: Int) {
        DispatchQueue.main.async {
            self.timeLeft = String(remainingTime)
        }
    }
    
    func didEndRound(round: Int, playerScore: Int, opponentScore: Int, winner: String) {
        DispatchQueue.main.async {
            
            if (self.gameStatus == .finished) { return }
            
            // Update the UI with round results
            self.currentScore = playerScore
            self.opponentRecentScore = opponentScore
            self.message = "Round \(round) ended. Winner: \(winner)"
            
            // You might want to check if the game continues or if additional actions are needed
            // For example, you could update the game status to a waiting state if there are more rounds
            // Or you could trigger any UI updates necessary to reflect these changes
        }
    }
    
    func didReceiveGameEnd(winners: [String], winnerStatus: String) {
        DispatchQueue.main.async {
            // Update the game status to finished
            self.gameStatus = .finished
            
            // Update the message to show the winner(s)
            let winnersStr = winners.joined(separator: ", ")
            self.message = "Game ended. Winner(s): \(winnersStr) with status: \(winnerStatus)"
            
            // Here, you could also perform any necessary cleanup or setup for a new game
            // This might include resetting the board, scores, and other properties
        }
    }
    
    
    func didUpdateOpponentScore(_ score: Int) {
        DispatchQueue.main.async {
            self.opponentRecentScore = score
        }
    }
    
    
    func didReceiveOpponentUsername(opponentUsername: String) {
        DispatchQueue.main.async {
            self.opponentUsername = opponentUsername
        }
    }
}
