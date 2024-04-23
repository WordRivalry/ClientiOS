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

@Observable class BoardViewModel<T> where T: Equatable {
    var board: Board<T>
    
    weak var swipeDelegate: Board_OnSwipe_Delegate?
    weak var tapDelegate: Board_OnTap_Delegate?
    
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
