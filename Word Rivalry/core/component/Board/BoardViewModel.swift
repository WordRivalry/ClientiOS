//
//  BoardViewModel.swift
//  PixelsAnima
//
//  Created by benoit barbier on 2023-07-01.
//

import Foundation
import Observation

protocol Board_OnSwipe_Delegate: AnyObject {
    func onCellHoverEntered(_ cellIndex: CellIndex)
    func onCellHoverStayed(_ cellIndex: CellIndex)
    func onCellHoverBacktracked(_ cellIndex: CellIndex)
    func onSwipeProcessed()
}

protocol Board_OnTap_Delegate: AnyObject {
    func onTapGesture(_ cellIndex: CellIndex)
}

protocol Board_GameState_Delegate: AnyObject {
    func onGameStarted()
    func onGamePaused()
    func onGameResumed()
    func onGameEnded(result: GameResult) // GameResult could be an enum representing win/loss/etc.
}

protocol Board_Score_Delegate: AnyObject {
    func onScoreIncreased(points: Int)
    func onScoreDecreased(points: Int)
    func onScoreReset()
}

protocol Board_Error_Delegate: AnyObject {
    func onErrorOccurred(error: BoardError) // BoardError could be an enum listing possible errors
}

protocol Board_Animation_Delegate: AnyObject {
    func onCellHighlightAnimationStarted(_ cellIndex: CellIndex)
    func onCellHighlightAnimationEnded(_ cellIndex: CellIndex)
    func onCustomAnimationTriggered(animation: BoardAnimation) // BoardAnimation could define animation types
}

enum GameResult {
    case win(score: Int)
    case lose(reason: String)
    case timeUp(score: Int)
    
    var description: String {
        switch self {
        case .win(let score):
            return "Congratulations! You've won with a score of \(score)."
        case .lose(let reason):
            return "Game Over. \(reason)"
        case .timeUp(let score):
            return "Time's up! Final score: \(score)."
        }
    }
}

enum BoardAnimation {
    case tileSelected(cellIndex: CellIndex)
    case wordFormed(word: String, path: [CellIndex])
    case tilesCleared(path: [CellIndex])

    var animationName: String {
        switch self {
        case .tileSelected:
            return "tileSelectedAnimation"
        case .wordFormed:
            return "wordFormedAnimation"
        case .tilesCleared:
            return "tilesClearedAnimation"
        }
    }
}

@Observable class BoardViewModel<T> where T: Equatable {
    var board: Board<T>
    
    weak var swipeDelegate: Board_OnSwipe_Delegate?
    weak var tapDelegate: Board_OnTap_Delegate?
    weak var animationDelegate: Board_Animation_Delegate?
    
    var rows: Int {
        board.rows
    }
    
    var cols: Int {
        board.cols
    }
    
    init(board: Board<T>) {
        self.board = board
    }
    
    func getCell(_ row: Int, _ col: Int) -> T {
        return board.getCell(row, col)
    }
    
    // MARK: OnTap Delegation
    
    func handleTap(_ row: Int, _ col: Int) {
        tapDelegate?.onTapGesture(CellIndex(i: row, j: col))
    }
    
    // MARK: OnSwipe Delegation
    
    // Additional properties to track drag/swipe interactions
    var cellsInDragPath: [CellIndex] = []
    private var currentCell: CellIndex?
    private var lastCell: CellIndex?
    
    // Updated method to handle cell hover with hooks
    func handleCellHover(_ row: Int, _ col: Int) {
        let cellIndex = CellIndex(i: row, j: col)
        
        if cellIndex == currentCell {
            swipeDelegate?.onCellHoverStayed(cellIndex) // Call hook for staying in the same cell
            return
        }
        
        if let existingIndex = cellsInDragPath.firstIndex(of: cellIndex) {
            if existingIndex < cellsInDragPath.count - 1 {
                cellsInDragPath = Array(cellsInDragPath.prefix(upTo: existingIndex + 1))
                swipeDelegate?.onCellHoverBacktracked(cellIndex) // Call hook for backtracking
            }
        } else {
            cellsInDragPath.append(cellIndex)
            swipeDelegate?.onCellHoverEntered(cellIndex) // Call hook for entering a new cell
          
        }
        
        currentCell = cellIndex
    }
    
    func processSwipeOrDragCompletion() {
        swipeDelegate?.onSwipeProcessed() // Call hook for onSwipe processing
        
        // Reset tracking properties
        cellsInDragPath.removeAll()
        currentCell = nil
        lastCell = nil
    }
}
