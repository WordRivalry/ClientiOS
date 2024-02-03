//
//  GenericBoard.swift
//  PixelsAnima
//
//  Created by benoit barbier on 2023-07-01.
//

import Foundation
import Observation

enum BoardError: Error {
    case outOfBounds
    case invalideMove
}

@Observable class Board<T> {
    let rows: Int
    let cols: Int
    var grid: [[T]] = []
    
    init(rows: Int, cols: Int, initialValue: T) {
        self.rows = rows
        self.cols = cols
        self.grid = Array(repeating: Array(repeating: initialValue, count: cols), count: rows)
    }

    init(dimension: Int, initialValue: T) {
        self.rows = dimension
        self.cols = dimension
        self.grid = Array(repeating: Array(repeating: initialValue, count: cols), count: rows)
    }
    
    func getCell(_ row: Int, _ col: Int) -> T {
        guard isWithinBound(row, col) else { fatalError("Board getCell OutOfBound") }
        return grid[row][col]
    }
    
    func setCell(_ row: Int, _ col: Int, value: T) {
        guard isWithinBound(row, col) else { return }
        grid[row][col] = value
    }
    
    func resetBoard(to value: T) {
        for row in 0..<rows {
            for col in 0..<cols {
                grid[row][col] = value
            }
        }
    }
    
    func getNeighboringCells(_ row: Int, _ col: Int) -> [(Int, Int)] {
        let offsets = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)]
        var neighbors = [(Int, Int)]()
        for offset in offsets {
            let newRow = row + offset.0
            let newCol = col + offset.1
            if isWithinBound(newRow, newCol) {
                neighbors.append((newRow, newCol))
            }
        }
        return neighbors
    }
    
    func getRow(at index: Int) -> [T?] {
        return grid[index]
    }

    func getColumn(at index: Int) -> [T?] {
        return grid.map { $0[index] }
    }
    
    /// This function will return a list of all the cells in the board.
    func getAllCellsIndex() -> [(Int, Int)] {
        var allCells = [(Int, Int)]()
        for row in 0..<rows {
            for col in 0..<cols {
                allCells.append((row, col))
            }
        }
        return allCells
    }
    
    func getAllCells() -> [T] {
        var allCells: [T] = []
        for row in 0..<rows {
            for col in 0..<cols {
                allCells.append(getCell(row, col))
            }
        }
        return allCells
    }
    
    /// This function will apply a given function to all cells in the board.
    /// This is useful when you want to perform the same operation on all cells
    /// (e.g., reset them, calculate their value, etc.)
    func applyFunctionToCells(function: (T) -> T) {
        for row in 0..<rows {
            for col in 0..<cols {
                grid[row][col] = function(grid[row][col])
            }
        }
    }

    /// This function counts the number of cells satisfying a certain condition.
    func count(where predicate: (T?) -> Bool) -> Int {
        return grid.joined().filter(predicate).count
    }

    /// This function returns a Boolean value indicating whether every cell of the board satisfies the given predicate.
    func allSatisfy(_ predicate: (T?) -> Bool) -> Bool {
        return grid.joined().allSatisfy(predicate)
    }

    /// This function returns a Boolean value indicating whether the board contains an element that satisfies the given predicate.
    func contains(where predicate: (T?) -> Bool) -> Bool {
        return grid.joined().contains(where: predicate)
    }
    
    func isWithinBound(_ row: Int, _ col: Int) -> Bool {
        return row >= 0 && row < rows && col >= 0 && col < cols
    }
}