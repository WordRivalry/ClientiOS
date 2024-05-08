//
//  GameTests.swift
//  Word RivalryTests
//
//  Created by benoit barbier on 2024-05-03.
//

import XCTest
@testable import Word_Rivalry

class MockTimeProvider: TimeProviding {
    var fixedDate: Date?
    
    func currentDate() -> Date {
        return fixedDate ?? Date()
    }
}

struct MockGameData {
    static let board = Board(grid: [
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
    ])
    
    struct MockWord {
        let word: String
        let wordPath: WordPath
        let wordScore: Int
    }
    
    static let validWords = [
        MockWord(word: "mais", wordPath: [(1, 2), (2, 2), (2, 3), (1, 3)], wordScore: 27),
        MockWord(word: "mal", wordPath: [(1, 2), (2, 2), (1, 1)], wordScore: 15),
        MockWord(word: "male", wordPath: [(1, 2), (2, 2), (1, 1), (1, 0)], wordScore: 18),
        MockWord(word: "mail", wordPath: [(1, 2), (2, 2), (2, 3), (3, 3)], wordScore: 18),
        MockWord(word: "sum", wordPath: [(1, 3), (0, 3), (1, 2)], wordScore: 8),
        MockWord(word: "cut", wordPath: [(2, 1), (3, 1), (3, 0)], wordScore: 36),
        
        
        // Word Boundary Test
        MockWord(word: "mum", wordPath: [(1, 2), (0, 3), (0, 2)], wordScore: 7),
        MockWord(word: "nsmu", wordPath: [(0, 0), (0, 1), (0, 2), (0,3)], wordScore: 9),
        MockWord(word: "nlal", wordPath: [(0, 0), (1, 1), (2, 2), (3,3)], wordScore: 12),
        MockWord(word: "nsmusilrutoe", wordPath: [
            (0, 0), (0, 1), (0, 2), (0,3), // nsmu
            (1, 3), // s
            (2, 3), // i
            (3, 3), (3, 2), (3, 1), (3, 0), // lrut
            (2, 0), // o
            (1, 0)  // e
           
        ], wordScore: 69),
    ]
    
    /// Function to get the word set from validWords
    static var validWordsSet: Set<String> {
        Set(validWords.map { $0.word })
    }
    
    // Mock data for specific invalid word scenarios
    
    /// Valid word but the path contains duplicate coordinates
    static let duplicateCoordinates = MockWord(
        word: "mum",
        wordPath: [(1, 2), (0, 3), (1, 2)],
        wordScore: 7
    )
    
    /// Valid word but the path is not continuous, should fail path continuity checks
    static let invalidPath = MockWord(
        word: "mais",
        wordPath: [(1, 2), (2, 2), (2, 3), (0, 1)],
        wordScore: 27
    )
    
    /// Word not present in the valid word list, should fail validation check for word existence
    static let wordNotInList = MockWord(
        word: "mails",
        wordPath: [(1, 2), (2, 2), (2, 3), (3, 3), (3, 2)],
        wordScore: 0
    )
}

final class GameTests: XCTestCase {
    
    var game: Game!
    
    var mockTimeProvider: MockTimeProvider! // TimeProvider injection
    
    var board: Board<Letter> = MockGameData.board
    
    let START_TIME = TimeInterval(-300)         // Start time is 5 minutes before now
    let END_TIME = TimeInterval(300)            // End time is 5 minutes after now
    let BEFORE_START_TIME = TimeInterval(-600)  // time is 10 minutes after now
    let AFTER_END_TIME = TimeInterval(600)      // Time is 10 minutes after now
    
    override func setUpWithError() throws {
        
        // Define game times for the game
        let startTime = Date().addingTimeInterval(START_TIME)
        let endTime = Date().addingTimeInterval(END_TIME)
        mockTimeProvider = MockTimeProvider()
        
        game = Game(
            startTime: startTime,
            endTime: endTime,
            validWords: MockGameData.validWordsSet,
            board: board,
            timeProvider: mockTimeProvider
        )
        
        XCTAssertTrue(game.isGameActive(), "Game should be active.")
    }
    
    override func tearDownWithError() throws {
        game = nil
    }
    
    // MARK: - Additional Tests for New Features or Edge Cases
    
    // Tests for empty word path, invalid indices, non-linear paths, etc.
}

// MARK: - Gameplay Tests
extension GameTests {
    
    func testAddWord_ValidWords_ScoreAndWordsFoundCorrectly() throws {
        // Iterate through each valid word mock data
        for wordData in MockGameData.validWords {
            // Setup
            let wordPath: WordPath = wordData.wordPath
            let expectedScore = wordData.wordScore
            let expectedWord = wordData.word

            // Execute
            let result = game.addWord(wordPath)

            // Verify both score and wordsFound update correctly
            switch result {
            case .success(let score):
                XCTAssertEqual(score, expectedScore, "Score should match expected for '\(expectedWord)'")
                XCTAssertTrue(game.wordsFound.contains(expectedWord), "The word '\(expectedWord)' should be in the wordsFound set")
            default:
                XCTFail("Expected successful addition of '\(expectedWord)' but received another result: \(result)")
            }
        }
    }
    
    func testSequentialWordAdditions_AffectTotalScoreCorrectly() throws {
        let initialScore = game.localScore
        for wordData in MockGameData.validWords {
            let _ = game.addWord(wordData.wordPath)
        }
        let expectedScore = MockGameData.validWords.reduce(0) { $0 + $1.wordScore }
        XCTAssertEqual(game.localScore, initialScore + expectedScore, "Sequential word additions should correctly affect the total score.")
    }
    
    func testWordAlreadyFound() throws {
        // Retrieve the word path for the word 'mal' from the BoardDataMock
        guard let wordData = MockGameData.validWords.first(where: { $0.word == "mal" }) else {
            XCTFail("Test setup error: Valid word 'mal' not found in mock data")
            return
        }
        
        // Attempt to add the word twice
        _ = game.addWord(wordData.wordPath)
        let result = game.addWord(wordData.wordPath)
        
        // Verify that the second addition fails with the appropriate error
        switch result {
        case .failed(let error):
            XCTAssertEqual(error, .wordAlreadyFound, "Submitting the same word twice should result in a 'wordAlreadyFound' error")
        default:
            XCTFail("Submitting the same word twice should not succeed")
        }
    }
    
    func testWordWithDuplicateCoordinates() throws {
        // Testing for word 'mum' with duplicate coordinate 'm'
        let wordData = MockGameData.duplicateCoordinates
        
        // Attempt to add the word and expect failure due to duplicate coordinates
        let result = game.addWord(wordData.wordPath)
        
        // Verify failure due to duplicate coordinates
        switch result {
        case .failed(let error):
            XCTAssertEqual(error, .duplicateCoordinates, "path for 'mum' should fail with an 'duplicateCoordinates' error")
        default:
            XCTFail("Duplicate coordinates within path for 'mum' submission should return duplicateCoordinates instead of \(result)")
        }
    }
    
    func testWordInListButNonContinuousPath() throws {
        // Testing for word 'mais' with a non-continuous path
        let wordData = MockGameData.invalidPath
        
        // Attempt to add the word and expect failure due to path error
        let result = game.addWord(wordData.wordPath)
        
        // Verify failure due to non-continuous path
        switch result {
        case .failed(let error):
            XCTAssertEqual(error, .notContinuousPath, "Non-continuous path for 'mais' should fail with an 'invalidWord' error")
        default:
            XCTFail("Non-continuous path for 'mais' submission should not succeed")
        }
    }

    func testWordNotInList() throws {
        // Testing for word 'mails' not present in the valid word list
        let wordData = MockGameData.wordNotInList
        
        // Attempt to add the word and expect failure due to non-existence in the valid word list
        let result = game.addWord(wordData.wordPath)
        
        // Verify failure due to the word not being in the valid word list
        switch result {
        case .failed(let error):
            XCTAssertEqual(error, .wordNotInList, "Word 'mails' not in the valid list should fail with an 'invalidWord' error")
        default:
            XCTFail("Word 'mails' not in the valid list submission should not succeed")
        }
    }
}


// MARK: - Time-dependent Tests
extension GameTests {
    
    
    // MARK: Game Activity Status Tests
    
    func testIsGameActive_BeforeStartTime_ReturnsFalse() throws {
        // Setting the mock time before the game's scheduled start time
        mockTimeProvider.fixedDate = Date().addingTimeInterval(BEFORE_START_TIME)
        XCTAssertFalse(game.isGameActive(), "Game should not be active before the start time.")
    }
    
    func testIsGameActive_DuringGame_ReturnsTrue() throws {
        // No time adjustment needed, default mock time is during the game
        XCTAssertTrue(game.isGameActive(), "Game should be active during the scheduled game time.")
    }
    
    func testIsGameActive_AfterEndTime_ReturnsFalse() throws {
        // Setting the mock time after the game's scheduled end time
        mockTimeProvider.fixedDate = Date().addingTimeInterval(AFTER_END_TIME)
        XCTAssertFalse(game.isGameActive(), "Game should not be active after the end time.")
    }
    
    
    // MARK: Word Submission Time-based Tests
    
    func testAddWord_BeforeGameStarts_ReturnsNotActiveError() throws {
        // Setting the mock time before the game's scheduled start time
        mockTimeProvider.fixedDate = Date().addingTimeInterval(BEFORE_START_TIME)
        let wordPath: WordPath = [(0, 0), (0, 1)]  // Example word path
        
        let result = game.addWord(wordPath)
        if case .failed(let error) = result, case .gameIsNotActive = error {
            XCTAssertTrue(true, "Attempting to add a word before game starts should fail with 'gameIsNotActive' error.")
        } else {
            XCTFail("Attempting to add a word before game starts should not be successful.")
        }
    }
    
    func testAddWord_AfterGameEnds_ReturnsNotActiveError() throws {
        // Setting the mock time after the game's scheduled end time
        mockTimeProvider.fixedDate = Date().addingTimeInterval(AFTER_END_TIME)
        let wordPath: WordPath = [(0, 0), (0, 1)]
        
        let result = game.addWord(wordPath)
        if case .failed(let error) = result, case .gameIsNotActive = error {
            XCTAssertTrue(true, "Attempting to add a word after the game has ended should fail with 'gameIsNotActive' error.")
        } else {
            XCTFail("Attempting to add a word after the game has ended should not be successful.")
        }
    }
}
