////
////  PrivateDatabase.swift
////  Word Rivalry
////
////  Created by benoit barbier on 2024-04-13.
////
//
//import Foundation
//import CloudKit
//import os.log
//
//// MARK: - Match Historic
//
//extension Match: CloudKitConvertible { // For database interaction
//    
//    static var recordType: String {
//        "GameHistory"
//    }
//    
//    // Public field
//    enum Key: String {
//        case ownScore, opponentRecordID, opponentScore, wasForfeited
//    }
//    
//    // Function to get the string value for a given key
//    static func forKey(_ key: Key) -> String {
//        return key.rawValue
//    }
//    
//    convenience init?(from ckRecord: CKRecord) {
//        guard let ownScore = ckRecord[Match.forKey(.ownScore)] as? Int,
//              let opponentRecordID = ckRecord[Match.forKey(.opponentRecordID)] as? String,
//              let opponentScore = ckRecord[Match.forKey(.opponentScore)] as? Int,
//              let wasForfeited = ckRecord[Match.forKey(.wasForfeited)] as? Bool else {
//            return nil
//        }
//    
//        self.init(
//            ownScore: ownScore,
//            opponentRecordID: opponentRecordID,
//            opponentScore: opponentScore,
//            wasForfeited: wasForfeited
//        )
//    }
//    
//    var record: CKRecord {
//        let record = CKRecord(recordType: Match.recordType)
//        record[Match.forKey(.ownScore)] = ownScore
//        record[Match.forKey(.opponentRecordID)] = opponentRecordID
//        record[Match.forKey(.opponentScore)] = opponentScore
//        record[Match.forKey(.wasForfeited)] = wasForfeited
//        return record
//    }
//}
//
//class PrivateDatabase {
//    
//    static let shared = PrivateDatabase()
//    private let logger = Logger(subsystem: "CloudKit", category: "PrivateDatabase")
//    
//    private let CKManager = CloudKitManager(
//        containerIdentifier: "iCloud.WordRivalryContainer",
//        databaseScope: .private)
//    
//    private init() {}
//    
//    enum DatabaseError: Error {
//        case GameHistoricInitFailed
//    }
//}
//
//
//extension PrivateDatabase {
//    // MARK: - Fetch
//
//    func fetchGamesHistoric(limit: Int) async throws -> [Match] {
//          let predicate = NSPredicate(value: true) // To fetch all records
//          let query = CKQuery(recordType: Match.recordType, predicate: predicate)
//          query.sortDescriptors = [NSSortDescriptor(key: "createdTimestamp", ascending: false)] // Sort by date in descending order
//          let (ckRecords, _) = try await CKManager.findRecords(matching: query, resultsLimit: limit)
//          let gamesHistoric = ckRecords.compactMap { ckRecord -> Match? in
//              return Match(from: ckRecord)
//          }
//          guard gamesHistoric.count == ckRecords.count else {
//              throw DatabaseError.GameHistoricInitFailed
//          }
//          
//          logger.debug("Game historic fetched")
//          return gamesHistoric
//      }
//    
//    // MARK: - Add
//
//    func addPublicProfileRecord(for gameHistory: Match) async throws -> Match {
//        _ = try await CKManager.saveRecord(saving: gameHistory.record)
//        logger.debug("GameHistory saved to public databse")
//        return gameHistory
//    }
//    
//    // MARK: - Delete
//    
//    func deleteGameHsitorycRecord(by recordID: CKRecord.ID) async throws {
//        try await CKManager.deleteRecord(deleting: recordID)
//    }
//}
