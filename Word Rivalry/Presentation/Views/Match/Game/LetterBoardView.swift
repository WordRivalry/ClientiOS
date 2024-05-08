//
//  LetterBoardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LetterBoardView: View {
    
    var viewModel: BoardInteractor<Letter>
    
    var body: some View {
        BoardView(viewModel: viewModel) { value, row, col in
            LetterCellView(
                letter: value,
                row: row,
                col: col,
                isHighlighted: viewModel.cellsInDragPath.contains(CellIndex(i: row, j: col))
            )
        }
    }
}

#Preview {
    
    let viewModel = BoardInteractor(board: Board(grid: [
        [
            Letter(letter: "n", value: 1),
            Letter(letter: "s", value: 2, letterMultiplier: 2),
            Letter(letter: "m", value: 3),
            Letter(letter: "u", value: 1)
        ],
        [
            Letter(letter: "e", value: 1),
            Letter(letter: "l", value: 1),
            Letter(letter: "m", value: 3),
            Letter(letter: "s", value: 2, letterMultiplier: 2)
        ],
        [
            Letter(letter: "o", value: 1),
            Letter(letter: "c", value: 1, wordMultiplier: 2),
            Letter(letter: "a", value: 1, wordMultiplier: 3),
            Letter(letter: "i", value: 1)
        ],
        [
            Letter(letter: "t", value: 1, wordMultiplier: 3),
            Letter(letter: "u", value: 2, letterMultiplier: 2),
            Letter(letter: "r", value: 1),
            Letter(letter: "l", value: 1)
        ]
    ]))
    
    return LetterBoardView(viewModel: viewModel)
}
