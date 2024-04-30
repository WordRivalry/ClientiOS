//
//  GameSession.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation
import OSLog

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

enum GameViewModelError: Error {
    case gameModelNotSet
    case boardInteractorNotSet
}

@Observable final class SoloGameViewModel: DataPreview {
    
    static var preview: SoloGameViewModel = {
         let vm = SoloGameViewModel(
            gameID: "",
            localUser: .preview,
            adversary: .previewOther,
            battleSocket: BattleSocketService()
        )
        vm.board =  Board(
            rows: 4,
            cols: 4,
            initialValue: LetterTile(
                letter: "A",
                value: 1,
                letterMultiplier: 1,
                wordMultiplier: 1)
        )
        return vm
    }()
    
    // Network layer
    private let battleSocket: BattleSocketService
    
    // Interactors

    private let forfeit = Forfeit()
    private let wordEvaluator = EvaluateWord()
    private let submitWord = SubmitWord()
    
    // Observabled states
    private(set) var boardInteractor: BoardInteractor<LetterTile>?
    private(set) var timer: Double = 0.0
    private(set) var localScore: Int = 0
    private(set) var adversaryScore: Int = 0
    private(set) var wordFound: [String] = []
    private(set) var board: Board<LetterTile>?
    private(set) var gameResults: GameResults?
    
    // Private states
    private var startTime: Date?
    private var endTime: Date?
    private var valid_words: [String]?
    private var stats: GridStats?
    private let iCloudStatus = iCloudService.shared.iCloudStatus
    
    init(
        gameID: String,
        localUser: User,
        adversary: User,
        battleSocket: BattleSocketService = BattleSocketService()
    ) {
        self.battleSocket = battleSocket
        self.battleSocket.setInGameDelegate(self)
    
        self.battleSocket.connect(
            gameID: gameID,
            userID: localUser.userID,
            username: localUser.username
        )
    }

    
    // MARK: Forfeit
    func forfeit() async throws -> Void {
        let request = ForfeitRequest(battleSocket: self.battleSocket)
        try await self.forfeit.execute(request: request)
    }
}


//MARK: SWIPE DELAGATE
extension SoloGameViewModel: Board_OnSwipe_Delegate {
    
    func onCellHoverEntered(_ cellIndex: CellIndex) {
    }
    
    func onCellHoverStayed(_ cellIndex: CellIndex) {
    }
    
    func onCellHoverBacktracked(_ cellIndex: CellIndex) {
    }
    
    // MARK: evaluate and submit word
    
    func onSwipeProcessed() {
        Task { // Work
            do {
                guard let interactor = self.boardInteractor else {
                    throw GameViewModelError.boardInteractorNotSet
                }
                
                let path = interactor.getIndexesForCurrentSwipe()
                
                let wordEvalRequest = EvaluateWordRequest(
                    wordPath: path,
                    board: interactor.board
                )
                
                let score = wordEvaluator.execute(request: wordEvalRequest)
                
                // SEND TO ADVERSARY
                let wordPath: WordPath = path.map { element in
                    return [element.0, element.1]
                }
                let request = SubmitWordRequest(
                    wordPath: wordPath,
                    battleSocket: self.battleSocket
                )
                try await self.submitWord.execute(request: request)
                
                // UI
                await MainActor.run {
                    self.localScore += score
                }
            } catch {
                Logger.match.fault("onSwipeProcessed error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scoreForTile(at cellIndex: CellIndex) -> Int {
        //        let tile = board.getCell(cellIndex.i, cellIndex.j)
        //        return tile.value * tile.letterMultiplier // You might also consider word multipliers here
        return 0
    }
}

//MARK: TAP DELAGATE
extension SoloGameViewModel: Board_OnTap_Delegate {
    func onTapGesture(_ cellIndex: CellIndex) {
        // let tappedCell = getCell(cellIndex.i, cellIndex.j)
        // Process the tap on the cell, e.g., select the cell, start a word, etc.
        // print("Tapped cell at \(cellIndex.i), \(cellIndex.j) with letter \(tappedCell.letter)")
    }
}

// MARK: WebSocket_GameDelegate
extension SoloGameViewModel: BattleSocketService_InGame_Delegate {
    
    func didReceiveGameInformation(
        startTime: Date,
        endTime: Date,
        grid: [[LetterTile]],
        valid_words: [String],
        stats: GridStats
    ) {
        Task {
            // Work
            let duration = endTime.timeIntervalSince(startTime).rounded(.toNearestOrAwayFromZero)
            let board = Board(grid: grid)
            
            self.startTime = startTime
            self.endTime = endTime
            self.valid_words = valid_words
            self.stats = stats
            
            self.boardInteractor = BoardInteractor(board: board)
            guard let boardInteractor = boardInteractor else {
                Logger.match.fault("BoardViewModel is not initiated when it should have been!")
                return
            }
            
            // MARK: Board delegate set
            boardInteractor.swipeDelegate = self
            boardInteractor.tapDelegate = self
            
            // UI
            await MainActor.run {
                self.board = board
                self.timer = duration
            }
        }
    }
    
    func didReceiveOpponentScore(_ score: Int) {
        Task { @MainActor in // UI
            self.adversaryScore = score
        }
    }
}
