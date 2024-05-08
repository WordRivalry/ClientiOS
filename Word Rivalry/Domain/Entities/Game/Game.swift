//
//  GameSession.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-22.
//

import Foundation
import OSLog

private extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let game = Logger(subsystem: subsystem, category: "Game")
}

/// Errors that could be encountered during the word submission process.
enum WordSubmitError: Error {
    
    /// The submitted word is not in the list of valid words.
    case wordNotInList
    
    /// The submitted word contains duplicated coordinated
    case duplicateCoordinates
    
    //// The submitted word is not from a continuous path
    case notContinuousPath
    
    /// The word has already been submitted in this game session.
    case wordAlreadyFound
    
    /// The attempt to submit a word occurred before the game had started or after the game had ended.
    case gameIsNotActive
}

/// Result types for word submission attempts.
enum WordSubmitStatus {
    
    /// The submission failed for a specified reason.
    case failed(WordSubmitError)
    
    /// The submission succeeded with the resulting score being returned.
    case success(Int)
}

/// Manages the state and logic for a single game session.
final class Game {
    
    /// Scores are accessible externally but only mutable internally within the class.
    private(set) var localScore: Int = 0
    /// Tracks all successfully submitted words.
    private(set) var wordsFound: Set<String> = []
    /// The game board containing letter tiles.
    private(set) var board: Board<Letter>
    /// Set of words that are considered valid for submission.
    private(set) var validWords: Set<String>
    
    // Defines the timeframe in which the game can be played.
    private var timeProvider: TimeProviding
    private var startTime: Date
    private var endTime: Date
    
    /// Initializes a new game with specified start and end times, valid words, board, and optionally a custom time provider.
    /// - Parameters:
    ///   - startTime: The start time of the game session.
    ///   - endTime: The end time of the game session.
    ///   - validWords: The set of words considered valid for submission in this game.
    ///   - board: The board containing letter tiles used in the game.
    ///   - timeProvider: The provider used to fetch the current date and time. Default is system time.
    init(
        startTime: Date,
        endTime: Date,
        validWords: Set<String>,
        board: Board<Letter>,
        timeProvider: TimeProviding = SystemTimeProvider()
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.validWords = validWords
        self.board = board
        self.timeProvider = timeProvider
        
        Logger.game.info("Game initialized with start time: \(self.startTime) and end time: \(self.endTime).")
    }
    
    /// Attempts to add a word to the game by its path on the board.
    /// - Parameter wordPath: The sequence of positions on the board that forms the word.
    /// - Returns: A status indicating whether the word was successfully added or failed with an error.
    @discardableResult
    func addWord(_ wordPath: WordPath) -> WordSubmitStatus {
        
        guard isGameActive() else {
            Logger.game.error("Attempt to add word while the game is not active.")
            return .failed(.gameIsNotActive)
        }
        
        // Ensure the word path contains unique coordinates
        guard areCoordinatesUnique(wordPath) else {
            Logger.game.error("Attempt to add word with duplicate coordinates.")
            return .failed(.duplicateCoordinates)
        }
        
        // Check if the word path is continuous
        guard isPathContinuous(wordPath) else {
            Logger.game.error("Attempt to add word with non-continuous path.")
            return .failed(.notContinuousPath)
        }
        
        let word = constructWord(from: wordPath)
        
        guard validWords.contains(word) else {
            Logger.game.error("Attempt to add invalid word: \(word).")
            return .failed(.wordNotInList)
        }
        
        if wordsFound.insert(word).inserted {
            let wordScore = calculateScore(for: wordPath)
            localScore += wordScore
            Logger.game.info("Word '\(word)' added successfully with score: \(wordScore). New total score: \(self.localScore).")
            return .success(wordScore)
        } else {
            Logger.game.warning("Attempt to add a word already found: \(word).")
            return .failed(.wordAlreadyFound)
        }
    }
    
    /// Checks if the game is currently active based on the current time.
    /// - Returns: True if the game is active, meaning the current time is after the start time and before the end time.
    func isGameActive() -> Bool {
        let currentDate = timeProvider.currentDate()
        let active = currentDate >= startTime && currentDate < endTime
        Logger.game.debug("Game activity checked: \(active ? "Active" : "Inactive").")
        return active
    }
    
    /// Checks if all coordinates in a word path are unique.
    /// - Parameter wordPath: The sequence of positions representing the word.
    /// - Returns: True if all coordinates are unique, else false.
    private func areCoordinatesUnique(_ wordPath: WordPath) -> Bool {
        let hashabledWordPath = wordPath.map( { coordinate in
            "\(coordinate.0),\(coordinate.1)"
        })
        
        let setOfPositions = Set(hashabledWordPath)
        return setOfPositions.count == wordPath.count
    }
    
    /// Validates that the path is continuous.
    /// - Parameter wordPath: The sequence of positions representing the word.
    /// - Returns: True if the path is continuous, else false.
    private func isPathContinuous(_ wordPath: WordPath) -> Bool {
        for i in 0..<wordPath.count - 1 {
            if !isAdjacent(wordPath[i], wordPath[i + 1]) {
                return false
            }
        }
        return true
    }
    
    /// Checks if two positions are adjacent on the board.
    /// - Parameters:
    ///   - first: The first position.
    ///   - second: The second position.
    /// - Returns: True if the positions are adjacent, else false.
    private func isAdjacent(_ first: (Int, Int), _ second: (Int, Int)) -> Bool {
        let rowDiff = abs(first.0 - second.0)
        let colDiff = abs(first.1 - second.1)
        return (rowDiff <= 1 && colDiff <= 1) && !(rowDiff == 0 && colDiff == 0)
    }
    
    /// Constructs a word from a sequence of positions on the board.
    /// - Parameter wordPath: The path through the board that spells out the word.
    /// - Returns: The constructed word as a string.
    private func constructWord(from wordPath: WordPath) -> String {
        return wordPath.reduce("") { result, position in
            let tile = board.getCell(position.0, position.1)
            return result + tile.letter
        }
    }
    
    /// Calculates the score for a word based on the letter values and multipliers found in its path.
    /// - Parameter wordPath: The path through the board that spells out the word.
    /// - Returns: The total score for the word, accounting for any multipliers.
    private func calculateScore(for wordPath: WordPath) -> Int {
        var wordMultiplier = 1
        let wordScore = wordPath.reduce(0) { total, position in
            let tile = board.getCell(position.0, position.1)
            wordMultiplier *= tile.wordMultiplier
            return total + tile.getValue()
        }
        return wordScore * wordMultiplier
    }
}

extension Game: DataPreview {
    static var preview: Game {
        get {
            .init(
                startTime: Date.now,
                endTime: Date().addingTimeInterval(60),
                validWords: [
                    "a",
                    "ace",
                    "aces",
                    "ai",
                    "ail",
                    "air",
                    "ais",
                    "ale",
                    "ales",
                    "aloes",
                    "ami",
                    "amis",
                    "arc",
                    "as",
                    "au",
                    "auto",
                    "ca",
                    "cal",
                    "cale",
                    "cales",
                    "calmi",
                    "calmir",
                    "calmis",
                    "calo",
                    "calot",
                    "cals",
                    "camus",
                    "car",
                    "cari",
                    "caris",
                    "cas",
                    "cauri",
                    "cauris",
                    "ce",
                    "cela",
                    "celai",
                    "celais",
                    "celas",
                    "cens",
                    "ces",
                    "cl",
                    "clair",
                    "clam",
                    "clams",
                    "clamse",
                    "cle",
                    "cles",
                    "clot",
                    "clotura",
                    "cloturai",
                    "cloturais",
                    "cloturas",
                    "clou",
                    "cloua",
                    "clouai",
                    "clouais",
                    "clouas",
                    "cm",
                    "col",
                    "cola",
                    "cols",
                    "cou",
                    "cour",
                    "courais",
                    "courlis",
                    "cout",
                    "cramse",
                    "cri",
                    "cria",
                    "crias",
                    "cris",
                    "cru",
                    "crut",
                    "cura",
                    "curai",
                    "curais",
                    "curas",
                    "curial",
                    "curiale",
                    "curiales",
                    "eclair",
                    "eclot",
                    "ecot",
                    "ecris",
                    "ecru",
                    "ecu",
                    "ecura",
                    "ecurai",
                    "ecurais",
                    "ecuras",
                    "en",
                    "es",
                    "il",
                    "ira",
                    "iras",
                    "la",
                    "lac",
                    "lace",
                    "laces",
                    "lai",
                    "lais",
                    "las",
                    "le",
                    "les",
                    "li",
                    "lia",
                    "lias",
                    "lima",
                    "limace",
                    "limaces",
                    "limas",
                    "lira",
                    "liras",
                    "lis",
                    "local",
                    "lot",
                    "loua",
                    "louai",
                    "louais",
                    "louas",
                    "loura",
                    "lourai",
                    "lourais",
                    "louras",
                    "ma",
                    "mac",
                    "macle",
                    "macles",
                    "mai",
                    "mail",
                    "mais",
                    "mal",
                    "male",
                    "males",
                    "mali",
                    "malis",
                    "marc",
                    "mari",
                    "maris",
                    "marli",
                    "marlis",
                    "mi",
                    "mil",
                    "mir",
                    "mira",
                    "miracle",
                    "miracles",
                    "miras",
                    "mis",
                    "misa",
                    "ms",
                    "mu",
                    "mus",
                    "musa",
                    "musai",
                    "ne",
                    "neo",
                    "nes",
                    "oc",
                    "ocra",
                    "ocrai",
                    "ocrais",
                    "ocras",
                    "ole",
                    "ou",
                    "ouais",
                    "ourla",
                    "ourlai",
                    "ourlais",
                    "ourlas",
                    "out",
                    "ra",
                    "race",
                    "races",
                    "racle",
                    "racles",
                    "racole",
                    "racoles",
                    "rai",
                    "rail",
                    "rais",
                    "rale",
                    "rales",
                    "rami",
                    "ramis",
                    "ras",
                    "ri",
                    "ria",
                    "rial",
                    "rials",
                    "rias",
                    "rima",
                    "rimas",
                    "ris",
                    "ru",
                    "rua",
                    "ruai",
                    "ruais",
                    "ruas",
                    "rut",
                    "sa",
                    "sac",
                    "sai",
                    "sale",
                    "sales",
                    "sali",
                    "salir",
                    "salse",
                    "sarcle",
                    "sarcles",
                    "sari",
                    "sauce",
                    "sauces",
                    "saur",
                    "sauri",
                    "saut",
                    "se",
                    "sec",
                    "secoua",
                    "secouai",
                    "secouais",
                    "secouas",
                    "secourais",
                    "securisa",
                    "sel",
                    "sen",
                    "si",
                    "sial",
                    "sil",
                    "sima",
                    "sir",
                    "su",
                    "sumac",
                    "toc",
                    "tole",
                    "toles",
                    "toua",
                    "touai",
                    "touais",
                    "touas",
                    "tour",
                    "tu",
                    "tua",
                    "tuai",
                    "tuais",
                    "tuas",
                    "turc",
                    "turco",
                    "us",
                    "usa",
                    "usai",
                    "ut"
                ],
                board: Board(grid: [
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
            )
        }
        set {
            //
        }
    }
}
