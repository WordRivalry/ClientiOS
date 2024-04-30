//
//  EfficientWordChecker.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-17.
//

import Foundation
import OSLog

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the JIT Data events from the app
    static let wordChecker = Logger(subsystem: subsystem, category: "WordChecker")
}

@Observable class EfficientWordChecker {
    private var data: Data?
    private var wordOffsets: [Int] = []

    static var shared: EfficientWordChecker = EfficientWordChecker()
    
    private init() {}

    private func loadOrCreateIndexMapping(filename: String) throws {
         let fileManager = FileManager.default
         let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
         let offsetsFileURL = cacheDirectory.appendingPathComponent("\(filename).offsets")

         if fileManager.fileExists(atPath: offsetsFileURL.path) {
             Logger.wordChecker.info("Loading offsets from binary file")
             let offsetsData = try Data(contentsOf: offsetsFileURL)
             wordOffsets = offsetsData.withUnsafeBytes {
                 Array($0.bindMemory(to: Int.self))
             }
             Logger.wordChecker.info("Offsets loaded from binary file")
         } else {
             Logger.wordChecker.info("Creating offsets binary file")
             try mapFile(filename: filename)
             let data = Data(buffer: UnsafeBufferPointer(start: &wordOffsets, count: wordOffsets.count))
             try data.write(to: offsetsFileURL)
             Logger.wordChecker.info("Offsets binary file created")
         }

         Logger.wordChecker.notice("Load the actual file data as a memory-mapped file")
         // Load the actual file data as a memory-mapped file
         guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt") else {
             throw NSError(domain: "EfficientWordChecker", code: 1, userInfo: [NSLocalizedDescriptionKey: "File not found"])
         }
         data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
         Logger.wordChecker.notice("File mapped into memory")
     }

      private func mapFile(filename: String) throws {
          guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "txt") else {
              throw NSError(domain: "EfficientWordChecker", code: 1, userInfo: [NSLocalizedDescriptionKey: "File not found"])
          }
          
          Logger.wordChecker.info("Mapping file")
          
          let fileData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
          self.data = fileData

          // Generate the index of line offsets to facilitate binary search
          var offset = 0
          while offset < fileData.count {
              wordOffsets.append(offset)
              if let lineEnd = fileData[offset...].firstIndex(of: 10) { // Newline character in ASCII
                  offset = lineEnd + 1
              } else {
                  break // Reach the end of file
              }
          }
      }

    func checkWordExists(_ searchWord: String) -> Bool {
        guard data != nil else {
            Logger.wordChecker.fault("Data not loaded")
            return false
        }

        var lowerBound = 0
        var upperBound = wordOffsets.count - 1
        
        while lowerBound <= upperBound {
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            let midWord = getWord(at: midIndex)
            
            if midWord == searchWord {
                return true
            } else if midWord < searchWord {
                lowerBound = midIndex + 1
            } else {
                upperBound = midIndex - 1
            }
        }
        
        return false
    }

    private func getWord(at index: Int) -> String {
        guard let data = data else { return "" }
        
        let start = wordOffsets[index]
        let end = index + 1 < wordOffsets.count ? wordOffsets[index + 1] : data.count
        let range = Range(uncheckedBounds: (lower: start, upper: end))
        
        return String(decoding: data.subdata(in: range), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension EfficientWordChecker: AppService {

    var isHealthy: Bool {
        get {data != nil}
        set {}
    }
    
    var identifier: String {
        "EfficientWordChecker"
    }
    
    var startPriority: ServiceStartPriority {
        .nonCritical(.max)
    }
    
    func start() async throws -> String {

        try self.loadOrCreateIndexMapping(filename: "processed_words")
        
        return "Load take place on demande"
    }
    
    func handleAppBecomingActive() {}
    func handleAppGoingInactive() {}
    func handleAppInBackground() {}
}
