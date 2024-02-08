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
    var timerStatus: String = "60"
    
    // Delegate
    var roundNumber: Int = 0
    var gameDuration: Int = 0
    var opponentUsername: String = ""
    
    @ObservationIgnored
    var timer: Timer?
    
    @ObservationIgnored
    var timeLeft: Int = 60
    
    @ObservationIgnored
    var timerCancellable: AnyCancellable?
    
    @ObservationIgnored
  //  private let letterScores: [Character: Int]
    
    @ObservationIgnored
    private let vowels: [Character] = ["A", "E", "I", "O", "U"]
    
    @ObservationIgnored
    private let numberOfVowelsToInclude: Int
    
    @ObservationIgnored
    private var alreadyDoneWords: [String] = []
    
    @ObservationIgnored
    private var ws: WebSocketService
    
    // MARK: INIT
    
    init() {
       
        self.ws = WebSocketService()
        super.init(board: Board(rows: 4, cols: 4, initialValue: LetterTile(letter: "", score: 0, letterMultiplier: 1, wordMultiplier: 1)))
        setupDelegates()
    }
    
    func setupDelegates() {
        self.swipeDelegate = self
        self.tapDelegate = self
        self.ws.gameDelegate = self
    }
    
    // MARK: GAME START
    
    func startGame() {
      //  populateBoard()
        gameStatus = .ongoing
      //  startTimer()
    }
    
//    func populateBoard() {
//        var vowelCount = 0
//        
//        for row in 0..<board.rows {
//            for col in 0..<board.cols {
//                var tile: LetterTile
//                let isVowelTurn = vowelCount < numberOfVowelsToInclude
//                
//                let letterPool: [Character] = isVowelTurn ? vowels : Array(letterScores.keys.filter { !vowels.contains($0) })
//                guard let randomLetter = letterPool.randomElement(),
//                      let score = letterScores[randomLetter] else { continue }
//                
//                tile = LetterTile(
//                    letter: String(randomLetter),
//                    score: score,
//                    letterMultiplier: 1,
//                    wordMultiplier: 1
//                )
//                
//                // Set the cell on the board to the new LetterTile
//                board.setCell(row, col, value: tile)
//                
//                // Update vowel count if necessary
//                if isVowelTurn { vowelCount += 1 }
//            }
//        }
//        
//        shuffleBoard()
//    }
    
    func shuffleBoard() {
        var tiles = board.getAllCells().shuffled()
        for row in 0..<board.rows {
            for col in 0..<board.cols {
                board.setCell(row, col, value: tiles.removeFirst())
            }
        }
    }
    
    func startTimer() {
        timeLeft = 60 // Reset timer to 60 seconds
        timerStatus = "60"
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.timeLeft -= 1
                self.timerStatus = "\(self.timeLeft)"
                
                if self.timeLeft <= 0 {
                    self.timerCancellable?.cancel() // Stop the timer
                    self.gameTimesUp()
                }
            }
    }
    
    // MARK: GAME ACTION
    
    func evalWord(path: [(Int, Int)]) {
        do {
            let score = try attemptWord(path: path)
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
        var wordMultiplier = 1
        
        for position in path {
            let cell = board.getCell(position.0, position.1)
            score += (letterScores[Character(cell.letter.uppercased())] ?? 0) * cell.letterMultiplier
            wordMultiplier *= cell.wordMultiplier
            
        }
        
        score *= wordMultiplier
        return score
    }
    
    // Record a word as found
    func markWordAsDone(word: String) {
        alreadyDoneWords.append(word)
    }
    
    // MARK: GAME FINISHED
    
    
    func gameTimesUp() {
        gameStatus = .finished
        timerStatus = "Time's up!"
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
        let path = cellsInDragPath.map { ($0.i, $0.j) }
        evalWord(path: path)
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

// MARK: SENT VIA WS
extension GameModel {
    
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
        
    }
    
    func didEndRound(round: Int, playerScore: Int, opponentScore: Int, winner: String) {
        
    }
    
    func didUpdateOpponentScore(_ score: Int) {
        
    }
    
    func didReceiveGameEnd(winners: [String], winnerStatus: String) {
        
    }
    
    func didReceiveOpponentUsername(opponentUsername: String) {
        DispatchQueue.main.async {
            self.opponentUsername = opponentUsername
        }
    }
}
