//
//  LetterBoardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LetterBoardView: View {
    
    var viewModel: GameModel
    
    var body: some View {
        BoardView(viewModel: viewModel) { value, row, col in
            AnyView(
                LetterCellView(
                    letter: value.letter,
                    row: row,
                    col: col,
                    isHighlighted: viewModel.cellsInDragPath.contains(CellIndex(i: row, j: col))
                )
            )
        }
    }
}

#Preview {
    LetterBoardView(viewModel: GameModel())
}
