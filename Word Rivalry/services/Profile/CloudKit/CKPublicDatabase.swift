//
//  CKPublicDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit

class CKPublicDatabase {
    
    private let CKManager: CloudKitManager
    
    init() {
        self.CKManager = CloudKitManager(containerIdentifier: "iCloud.WordRivalryContainer", databaseScope: .public)
    }
    
    struct RecordType {
        static let player = "Player"
        static let leaderboard = "Leaderboard"
    }
    
    struct PlayerRecordKey {
        static let userRecordID = "userRecordID"
        static let playerName = "playerName"
        static let eloRating = "eloRating"
    }
    
    // MARK: - Fetch
    
    func fetchPlayerRecord() async throws -> CKRecord {
        let userRecordID = try await CKManager.userRecordID()
        let playerRecords = try await fetchPlayerRecords(forUserRecordID: userRecordID)
        guard let playerRecord = playerRecords.first else { throw NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Player not found."]) }
        return playerRecord
    }
    
    func fetchPlayerRecords(forUserRecordID userRecordID: CKRecord.ID) async throws -> [CKRecord] {
        let predicate = NSPredicate(format: "%K == %@", PlayerRecordKey.userRecordID, userRecordID)
        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        let (records, _) = try await CKManager.findRecords(matching: query)
        return records
    }
    
    // MARK: - Add

    func addPlayerRecord(playerName: String) async throws -> CKRecord {
        let userRecordID = try await CKManager.userRecordID()
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[PlayerRecordKey.playerName] = playerName
        playerRecord[PlayerRecordKey.eloRating] = 800 // Default Elo Rating
        playerRecord[PlayerRecordKey.userRecordID] = CKRecord.Reference(recordID: userRecordID, action: .none)
        return try await CKManager.saveRecord(saving: playerRecord)
    }
    
    // MARK: - Update
  
    func updatePlayerName(newPlayerName: String) async throws -> CKRecord {
        let playerRecord = try await self.fetchPlayerRecord()
        playerRecord[PlayerRecordKey.playerName] = newPlayerName
        return try await CKManager.saveRecord(saving: playerRecord)
    }
    
    func updatePlayerEloRating(newEloRating: Int) async throws -> CKRecord {
        let playerRecord = try await self.fetchPlayerRecord()
        playerRecord[PlayerRecordKey.eloRating] = newEloRating
        return try await CKManager.saveRecord(saving: playerRecord)
    }
    
    // MARK: - Delete

    func deletePlayerRecord() async throws {
        let userRecordID = try await CKManager.userRecordID()
        let playerRecords = try await fetchPlayerRecords(forUserRecordID: userRecordID)
        guard let playerRecord = playerRecords.first else { return }
        try await CKManager.deleteRecord(deleting: playerRecord.recordID)
    }
    
    // MARK: - Subscriptions
    
    func subscribeToPlayerNameChanges() async throws {
        let userRecordID = try await CKManager.userRecordID()
        
        // Create a predicate that filters records
        let predicate = NSPredicate(format: "%K == %@", PlayerRecordKey.userRecordID, CKRecord.Reference(recordID: userRecordID, action: .none))
        let subscriptionID = "\(PlayerRecordKey.playerName)-updates-\(userRecordID.recordName)"
        
        let subscription = CKQuerySubscription(
            recordType: RecordType.player,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = [PlayerRecordKey.playerName]
        subscription.notificationInfo = notificationInfo
        _ = try await CKManager.saveSubscription(saving: subscription)
    }
 }
