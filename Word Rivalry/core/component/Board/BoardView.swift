//
//  BoardView.swift
//  PixelsAnima
//
//  Created by benoit barbier on 2023-07-01.
//

import SwiftUI


struct CellIndex: Equatable, Hashable {
    let i: Int
    let j: Int
}

import SwiftUI

struct BoardView<T>: View where T: Hashable {
    var viewModel: BoardViewModel<T>
    var cellContent: (T, Int, Int) -> AnyView
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = geometry.size.width / CGFloat(viewModel.cols)
            Grid {
                ForEach(0..<viewModel.rows, id: \.self) { row in
                    GridRow {
                        ForEach(0..<viewModel.cols, id: \.self) { col in
                            cellContent(viewModel.getCell(row, col), row, col)
                            .onTapGesture {
                                self.viewModel.handleTap(row, col)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(self.viewModel.cellsInDragPath.contains(CellIndex(i: row, j: col)) ? Color.gray.opacity(0.5) : Color.clear)
                            .id(CellIndex(i: row, j: col))
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let colIndex = Int(gesture.location.x / cellSize)
                        let rowIndex = Int(gesture.location.y / cellSize)
                        viewModel.handleCellHover(rowIndex, colIndex)
                    }
                    .onEnded { _ in
                        viewModel.processSwipeOrDragCompletion()
                    }
            )
            .aspectRatio(1, contentMode: .fit)
            .padding()
        }
    }
}
