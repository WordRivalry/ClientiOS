//
//  BoardView.swift
//  PixelsAnima
//
//  Created by benoit barbier on 2023-07-01.
//

import SwiftUI


import UIKit

extension View {
    /// Check if the current device is an iPhone.
    var isiPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

struct CellIndex: Equatable, Hashable {
    let i: Int
    let j: Int
}

struct BoardView<T, K: View>: View where T: Hashable {
    var viewModel: BoardInteractor<T>
    var cellContent: (T, Int, Int) -> K
    
    @State private var cellFrames: [CellIndex: CGRect] = [:]
    
    var cornerInset: CGFloat = 25 // the size of the triangle corners to exclude
    
    var body: some View {
        LazyVGrid(
            columns: [GridItem](
                repeating: GridItem(.flexible(minimum: 20, maximum: 140), spacing: 0),
                count: viewModel.cols
            )
        ) {
            ForEach(0 ..< viewModel.rows *  viewModel.cols, id: \.self) { i in
                let (x, y) = indexToCoordinate(index: i, gridWidth: viewModel.rows)
                
                GeometryReader { geometry in
                    cellContent(viewModel.getCell(x, y), x, y)
                        .padding(3)  // Creates visual gaps but retains the touch area
                        .background(viewModel.cellsInDragPath.contains(CellIndex(i: x, j: y)) ? Color.gray.opacity(0.5) : Color.clear)
                        .cornerRadius(5) // Apply corner radius to the padded content
                        .onAppear {
                            // Set the touchable frame to the actual bounds without padding
                            cellFrames[CellIndex(i: x, j: y)] = geometry.frame(in: .named("screen"))
                        }
                       
                }
                .aspectRatio(1, contentMode: .fit) // Enforce square cells
                .border(Color.debug)
            }
        }
        .coordinateSpace(name: "screen")
        .gesture(
            DragGesture(coordinateSpace: .named("screen"))
                .onChanged { gesture in
                    detectCell(for: gesture.location)
                }
                .onEnded { _ in
                    viewModel.processSwipeOrDragCompletion()
                }
        )
        .padding(.horizontal, isiPhone ? 20 : 0) // Conditional padding for iPhone
    }
    
    private func detectCell(for location: CGPoint) {
        let foundIndex = cellFrames.first { key, rect in
            isPointWithinModifiedFrame(point: location, frame: rect)
        }?.key
        
        if let index = foundIndex {
            viewModel.handleCellHover(index.i, index.j)
        }
    }
    
    private func isPointWithinModifiedFrame(point: CGPoint, frame: CGRect) -> Bool {
        // Define the exclusion zones (triangles in the corners)
        let cornerRects = [
            CGRect(x: frame.minX, y: frame.minY, width: cornerInset, height: cornerInset),
            CGRect(x: frame.maxX - cornerInset, y: frame.minY, width: cornerInset, height: cornerInset),
            CGRect(x: frame.minX, y: frame.maxY - cornerInset, width: cornerInset, height: cornerInset),
            CGRect(x: frame.maxX - cornerInset, y: frame.maxY - cornerInset, width: cornerInset, height: cornerInset)
        ]
        // Check if point is in the main frame but not in any of the corners
        return frame.contains(point) && !cornerRects.contains(where: { $0.contains(point) })
    }
    
    
    private func indexToCoordinate(index: Int, gridWidth: Int) -> (x: Int, y: Int) {
        let x = index % gridWidth
        let y = index / gridWidth
        return (x, y)
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
    
    return BoardView(
        viewModel: viewModel,
        cellContent:  { value, row, col in
            AnyView(
                LetterCellView(
                    letter: value,
                    row: row,
                    col: col,
                    isHighlighted: viewModel.cellsInDragPath.contains(CellIndex(i: row, j: col))
                )
            )
        }
    )
}
