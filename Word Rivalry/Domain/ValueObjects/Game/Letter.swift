//
//  Letter.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-03.
//

import Foundation

struct Letter: Equatable, Hashable, Codable {
    
    let letter: String
    var wordMultiplier: Int
    
    // Internals
    private let value: Int
    var letterMultiplier: Int
    
    init(
        letter: String,
        value: Int,
        letterMultiplier: Int = 1,
        wordMultiplier: Int = 1
    ) {
        self.letter = letter
        self.value = value
        self.letterMultiplier = letterMultiplier
        self.wordMultiplier = wordMultiplier
    }
    
    func getValue() -> Int {
        return value * letterMultiplier
    }
}
