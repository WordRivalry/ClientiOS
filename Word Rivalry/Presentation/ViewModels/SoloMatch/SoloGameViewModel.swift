//
//  GameSession.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation
import OSLog
import GameKit



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
        vm.game = .preview
        return vm
    }()
    
    // Network layer
    private let battleSocket: BattleSocketService
    
    // Game
    private(set) var game: Game?
    
    // Interactors
    private let forfeit = Forfeit()
    private let submitWord = SubmitWord()
    
    // Observabled states
    private(set) var boardInteractor: BoardInteractor<Letter>?
    private(set) var timeRemaining: Double = 0.0
    private(set) var adversaryScore: Int = 0
    private(set) var gameResults: GameResults?
    
    // Private states
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
            username: GKLocalPlayer.local.displayName
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
    
    func onCellHoverEntered(_ cellIndex: CellIndex) {}
    
    func onCellHoverStayed(_ cellIndex: CellIndex) {}
    
    func onCellHoverBacktracked(_ cellIndex: CellIndex) {}
    
    // MARK: evaluate and submit word
    
    func onSwipeProcessed() {
        Task { // Work
            do {
                guard let interactor = self.boardInteractor else {
                    throw GameViewModelError.boardInteractorNotSet
                }
                
                guard let game = self.game else {
                    throw GameViewModelError.gameModelNotSet
                }
                
                let path = interactor.getIndexesForCurrentSwipe()
                let result = game.addWord(path)
                
                switch result {
                case .failed(let wordSubmitError): break
                    // DO NOTHING
                case .success(let int):
                    // SEND TO ADVERSARY
                    let request = SubmitWordRequest(
                        wordPath: path,
                        battleSocket: self.battleSocket
                    )
                    try await self.submitWord.execute(request: request)
                }
             
            } catch {
                Logger.match.fault("onSwipeProcessed error: \(error.localizedDescription)")
            }
        }
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
        grid: [[Letter]],
        valid_words: [String],
        stats: GridStats
    ) {
        Task {
            // Work
            let duration = endTime.timeIntervalSince(startTime).rounded(.toNearestOrAwayFromZero)
            let board = Board(grid: grid)
            let validWordsSet = Set(valid_words)
        
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
                self.game = .init(
                    startTime: startTime,
                    endTime: endTime,
                    validWords: validWordsSet,
                    board: board
                )
                self.timeRemaining = duration
            }
        }
    }
    
    func didReceiveOpponentScore(_ score: Int) {
        Task { @MainActor in // UI
            self.adversaryScore = score
        }
    }
}
