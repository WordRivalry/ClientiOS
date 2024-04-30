//
//  LevelCalculatorService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-26.
//

import Foundation

typealias Level = Int

class UserLeveCalculator {
    // Define your XP table here
    let xpTable: [Int: Level] = [
        0: 1,
        100: 2,
        200: 3,
        500: 4,
        1000: 5,
        1500: 6,
        2000: 7,
        2500: 8,
        3000: 9,
        3500: 10,
        4000: 11
    ]
    
    func levelForExperience(_ experience: Int) -> Level {
        // Find the highest XP threshold that is less than or equal to the input experience
        let threshold = xpTable.keys.filter { $0 <= experience }.max() ?? 0
        
        // Return the level corresponding to the found threshold
        return xpTable[threshold] ?? 1
    }
}
