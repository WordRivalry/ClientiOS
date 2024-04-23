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
              VStack {
                  Spacer()
                  HStack {
                      Spacer()
                      boardView(geometry: geometry)
                      Spacer()
                  }
                  Spacer()
              }
          }
    }
    
    private func boardView(geometry: GeometryProxy) -> some View {
        // Determine the maximum size the board can take
        let maxWidth =  max(1, geometry.size.width - 25)  // Adjust padding as needed
        let maxHeight = max(1, geometry.size.height - 25) // Adjust padding as needed
        let boardSize = min(maxWidth, maxHeight)
        
        let cellSize = boardSize / CGFloat(max(viewModel.cols, viewModel.rows))
        
        let tolerance: CGFloat = cellSize * 0.5 // Adjusted tolerance for swipe detection
        
        return VStack {
            ForEach(0..<viewModel.rows, id: \.self) { row in
                HStack {
                    ForEach(0..<viewModel.cols, id: \.self) { col in
                        cellContent(viewModel.getCell(row, col), row, col)
                            .frame(width: cellSize, height: cellSize)
                            .background(viewModel.cellsInDragPath.contains(CellIndex(i: row, j: col)) ? Color.gray.opacity(0.5) : Color.clear)
                            .cornerRadius(5) // Optional: Adds rounded corners for cell appearance
                    }
                }
            }
        }
        .gesture(
            combinedGesture(cellSize: cellSize, tolerance: tolerance)
        )
        .frame(width: boardSize, height: boardSize) // Constrain the VStack to fit within the screen
        .aspectRatio(1, contentMode: .fit)
    }

    
    private func combinedGesture(cellSize: CGFloat, tolerance: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                var colIndex = Int(gesture.location.x / cellSize)
                var rowIndex = Int(gesture.location.y / cellSize)
                
                // Clamp the colIndex and rowIndex to ensure they're within the grid's bounds
                colIndex = max(0, min(colIndex, viewModel.cols - 1))
                rowIndex = max(0, min(rowIndex, viewModel.rows - 1))
                
                let cellCenter = CGPoint(x: CGFloat(colIndex) * cellSize + cellSize / 2, y: CGFloat(rowIndex) * cellSize + cellSize / 2)
                let distanceFromCenter = sqrt(pow(gesture.location.x - cellCenter.x, 2) + pow(gesture.location.y - cellCenter.y, 2))
                
                if distanceFromCenter <= tolerance {
                    viewModel.handleCellHover(rowIndex, colIndex)
                }
            }
            .onEnded { _ in
                viewModel.processSwipeOrDragCompletion()
            }
    }
}
