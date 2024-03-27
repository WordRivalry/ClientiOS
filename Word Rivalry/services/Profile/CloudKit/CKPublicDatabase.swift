//
//  CKPublicDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit

struct PublicPlayer { // In another file
    let userRecordID: CKRecord.Reference // Stable identifier
    let playerName: String
    let eloRating: Int64
    let title: Int64
    let banner: Int64
    let profileImage: Int64
    
    private init( // Defined here is a new player field behavior
        userRecordID: CKRecord.Reference,
        playerName: String,
        eloRating: Int64 = 800,
        title: Int64 = 0,
        banner: Int64 = 0,
        profileImage: Int64 = 0
    ) {
        self.userRecordID = userRecordID
        self.playerName = playerName
        self.eloRating = eloRating
        self.title = title
        self.banner = banner
        self.profileImage = profileImage
    }
}

extension PublicPlayer { // For database interaction
    
    static func new ( userRecordID: CKRecord.Reference, playerName: String) -> PublicPlayer {
        self.init(userRecordID: userRecordID, playerName: playerName)
    }
    
    static func build (
        userRecordID: CKRecord.Reference,
        playerName: String,
        eloRating: Int64,
        title: Int64,
        banner: Int64,
        profileImage: Int64
    ) -> PublicPlayer {
        self.init(userRecordID: userRecordID, playerName: playerName, eloRating: eloRating, title: title, banner: banner, profileImage: profileImage)
    }
    
    static let userRecordIDKey = "userRecordID"
    static let playerNameKey = "playerName"
    static let eloRatingKey = "eloRating"
    static let titleKey = "title"
    static let bannerKey = "banner"
    static let profileImageKey = "profileImage"
    
    // Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        switch key {
        case .userRecordID:
            return PublicPlayer.userRecordIDKey
        case .playerName:
            return PublicPlayer.playerNameKey
        case .eloRating:
            return PublicPlayer.eloRatingKey
        case .title:
            return PublicPlayer.titleKey
        case .banner:
            return PublicPlayer.bannerKey
        case .profileImage:
            return PublicPlayer.profileImageKey
        }
    }
    
    enum Key {
        case userRecordID, playerName, eloRating, title, banner, profileImage
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: CKPublicDatabase.RecordType.player)
        record[PublicPlayer.userRecordIDKey] = userRecordID
        record[PublicPlayer.playerNameKey] = playerName
        record[PublicPlayer.eloRatingKey] = eloRating
        record[PublicPlayer.titleKey] = title
        record[PublicPlayer.bannerKey] = banner
        record[PublicPlayer.profileImageKey] = profileImage
        return record
    }
}

class CKPublicDatabase {
    
    private let CKManager: CloudKitManager
  
    init(ckManager: CloudKitManager) {
        self.CKManager = ckManager
    }
    
    struct RecordType {
        static let player = "Player"
    }
        
    enum DatabaseError: Error {
        case playerNotFound
        case forbiddenUpdate
        case forbiddenSubscription
        case invalidDataType
        case invalidEloRating
    }
}

// MARK: - Players Public Profiles
extension CKPublicDatabase {
    
    // MARK: - Fetch
 
    func fetchPlayer() async throws -> PublicPlayer {
        let ckRecord = try await fetchPlayerRecord()
        
        // Construct a publicPlayer from CKRecord
        let publicPlayer = PublicPlayer.build(
            userRecordID: ckRecord[PublicPlayer.userRecordIDKey] as! CKRecord.Reference,
            playerName: ckRecord[PublicPlayer.playerNameKey] as! String,
            eloRating: ckRecord[PublicPlayer.eloRatingKey] as! Int64,
            title: ckRecord[PublicPlayer.titleKey] as! Int64,
            banner: ckRecord[PublicPlayer.bannerKey] as! Int64,
            profileImage: ckRecord[PublicPlayer.profileImageKey] as! Int64
        )
        
        return publicPlayer
    }
    
    func fetchPlayers(forUserRecordID userRecordID: CKRecord.ID) async throws -> [PublicPlayer] {
        let ckRecords = try await fetchPlayerRecords(forUserRecordID: userRecordID)
        
        // map to PlayerRecords and return
    }
    
    private func fetchPlayerRecords(forUserRecordID userRecordID: CKRecord.ID) async throws -> [CKRecord] {
        let predicate = NSPredicate(format: "%K == %@", PublicPlayer.userRecordIDKey, userRecordID)
        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        let (records, _) = try await CKManager.findRecords(matching: query)
        return records
    }
    
    
    private func fetchPlayerRecord() async throws -> CKRecord {
        let userRecordID = try await CKManager.userRecordID()
        let playerRecords = try await fetchPlayerRecords(forUserRecordID: userRecordID)
        guard let playerRecord = playerRecords.first else { throw DatabaseError.playerNotFound }
        return playerRecord
    }
    
    // MARK: - Add
    
    func addPlayerRecord(playerName: String) async throws -> PublicPlayer {
        let userRecordID = try await CKManager.userRecordID()
        let publicPlayer = PublicPlayer.new(
            userRecordID: CKRecord.Reference(recordID: userRecordID, action: .none),
            playerName: playerName
        )
        _ = try await CKManager.saveRecord(saving: publicPlayer.record)
        return publicPlayer
    }
    
    // MARK: - Update
    
    func updatePlayerName(saving newPlayerName: String) async throws -> CKRecord {
        try await self.updatePlayerRecord(field: .playerName, with: newPlayerName)
    }
    
    func updatePlayerEloRating(saving newEloRating: Int64) async throws -> CKRecord {
        try await self.updatePlayerRecord(field: .eloRating, with: newEloRating)
    }
    
    enum Title: Int64 {
        case defaultTitle = 0
        // other titles
    }
    
    enum Banner: Int64 {
        case defaultBanner = 0
        // other banners
    }

    enum ProfileImage: Int64 {
        case defaultImage = 0
        // other images
    }
    
    func updateTitle(saving newTitle: Title) async throws -> CKRecord {
        try await self.updatePlayerRecord(field: .title, with: newTitle.rawValue)
    }
    
    func updateBanner(saving newBanner: Banner) async throws -> CKRecord {
        try await self.updatePlayerRecord(field: .banner, with: newBanner.rawValue)
    }
    
    func updateProfileImage(saving newProfileImage: ProfileImage) async throws -> CKRecord {
        try await self.updatePlayerRecord(field: .profileImage, with: newProfileImage.rawValue)
    }
        
    // Generalized update function
    private func updatePlayerRecord<T>(field: PublicPlayer.Key, with newValue: T) async throws -> CKRecord {
        let playerCKRecord = try await fetchPlayerRecord()
        
        switch field {
        case .playerName, .eloRating, .title, .banner, .profileImage:
            if let value = newValue as? CKRecordValue {
                playerCKRecord[PublicPlayer.forKey(field)] = value
            } else {
                throw DatabaseError.invalidDataType
            }
        case .userRecordID:
            throw DatabaseError.forbiddenUpdate
        }
        
        return try await CKManager.saveRecord(saving: playerCKRecord)
    }
    
    // MARK: - Delete
    
    func deletePlayerRecord() async throws {
        let userRecordID = try await CKManager.userRecordID()
        let playerRecord = try await fetchPlayerRecord()
        try await CKManager.deleteRecord(deleting: playerRecord.recordID)
    }
    
    // MARK: - Subscriptions
    
    func subscribeToChanges() async throws {
        try await self.subscribeToChanges(for: .playerName)
        try await self.subscribeToChanges(for: .eloRating)
        try await self.subscribeToChanges(for: .title)
        try await self.subscribeToChanges(for: .banner)
        try await self.subscribeToChanges(for: .profileImage)
    }
    
    func subscribeToChanges(for key: PublicPlayer.Key) async throws {
        switch key {
        case .playerName, .eloRating, .title, .banner, .profileImage:
            let userRecordID = try await CKManager.userRecordID()
            
            let predicate = NSPredicate(format: "%K == %@", PublicPlayer.userRecordIDKey, CKRecord.Reference(recordID: userRecordID, action: .none))
            let subscriptionID = "\(PublicPlayer.forKey(key))-updates-\(userRecordID.recordName)"
            
            let subscription = CKQuerySubscription(
                recordType: RecordType.player,
                predicate: predicate,
                subscriptionID: subscriptionID,
                options: [.firesOnRecordUpdate]
            )
            
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            notificationInfo.desiredKeys = [PublicPlayer.forKey(key)]
            subscription.notificationInfo = notificationInfo
            _ = try await CKManager.saveSubscription(saving: subscription)
        case .userRecordID:
            throw DatabaseError.forbiddenSubscription
        }
    }
}

// MARK: - Leaderboards

extension CKPublicDatabase {
    func fetchLeaderboard(limit: Int = 50) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true) // Fetch all players
        let query = CKQuery(recordType: RecordType.player, predicate: predicate)
        
        // Sort by eloRating in descending order
        let sortDescriptor = NSSortDescriptor(key: PublicPlayer.eloRatingKey, ascending: false)
        query.sortDescriptors = [sortDescriptor]
        
        // Fetch records
        let (records, _) = try await CKManager.findRecords(matching: query, resultsLimit: limit)
        return records
    }
}

