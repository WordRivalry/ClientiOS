//
//  LetterTests.swift
//  Word RivalryTests
//
//  Created by benoit barbier on 2024-05-04.
//

import XCTest
@testable import Word_Rivalry

final class LetterTests: XCTestCase {

    // Testing the initialization and property access
     func testLetterTileInitialization() throws {
         let tile = Letter(letter: "A", value: 2, letterMultiplier: 2, wordMultiplier: 3)
         
         XCTAssertEqual(tile.letter, "A", "The letter should be set correctly.")
         XCTAssertEqual(tile.letterMultiplier, 2, "The letterMultiplier should be set correctly")
         XCTAssertEqual(tile.getValue(), 4, "The value should be calculated correctly as value * letterMultiplier.")
         XCTAssertEqual(tile.wordMultiplier, 3, "The wordMultiplier should be set correctly.")
     }
     
     // Testing the value computation
     func testLetterTileValueComputation() throws {
         let tile = Letter(letter: "B", value: 3, letterMultiplier: 3)
         XCTAssertEqual(tile.getValue(), 9, "The value should be 9 (3 * 3).")
     }
     
     // Testing equality of LetterTiles
     func testLetterTileEquality() throws {
         let tile1 = Letter(letter: "C", value: 3, letterMultiplier: 1)
         let tile2 = Letter(letter: "C", value: 3, letterMultiplier: 1)
         
         XCTAssertEqual(tile1, tile2, "Two tiles with the same letter, value, and multipliers should be equal.")
     }
     
     // Testing hashability by inserting into a Set
     func testLetterTileHashability() throws {
         let tile1 = Letter(letter: "D", value: 2)
         let tile2 = Letter(letter: "E", value: 3)
         
         var set = Set<Letter>()
         set.insert(tile1)
         set.insert(tile2)
         
         XCTAssertTrue(set.contains(tile1), "The set should contain tile1.")
         XCTAssertTrue(set.contains(tile2), "The set should contain tile2.")
     }
}
