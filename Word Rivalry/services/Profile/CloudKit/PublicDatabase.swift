//
//  CKPublicDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit

struct PublicProfile { // In another file
    let userRecordID: CKRecord.Reference // Stable identifier
    let playerName: String
    let eloRating: Int64
    let title: Int64
    let banner: Int64
    let profileImage: Int64
    
    private init( // Default provided define a new public profile values
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

extension PublicProfile { // For database interaction
    
    static var RecordType = "PublicProfile"
    
    static func new(userRecordID: CKRecord.Reference, playerName: String) -> PublicProfile {
        self.init(userRecordID: userRecordID, playerName: playerName)
    }
    
    init?(from ckRecord: CKRecord) {
        guard let userRecordID = ckRecord[PublicProfile.forKey(.userRecordID)] as? CKRecord.Reference,
              let playerName = ckRecord[PublicProfile.forKey(.playerName)] as? String,
              let eloRating = ckRecord[PublicProfile.forKey(.eloRating)] as? Int64,
              let title = ckRecord[PublicProfile.forKey(.title)] as? Int64,
              let banner = ckRecord[PublicProfile.forKey(.banner)] as? Int64,
              let profileImage = ckRecord[PublicProfile.forKey(.profileImage)] as? Int64 else {
            return nil
        }
        self.init(userRecordID: userRecordID, playerName: playerName, eloRating: eloRating, title: title, banner: banner, profileImage: profileImage)
    }
        
    // Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
    
    enum Key: String {
        case userRecordID, playerName, eloRating, title, banner, profileImage
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: PublicProfile.RecordType)
        record[PublicProfile.forKey(.userRecordID)] = userRecordID
        record[PublicProfile.forKey(.playerName)] = playerName
        record[PublicProfile.forKey(.eloRating)] = eloRating
        record[PublicProfile.forKey(.title)] = title
        record[PublicProfile.forKey(.banner)] = banner
        record[PublicProfile.forKey(.profileImage)] = profileImage
        return record
    }
}

class PublicDatabase {
    
    private let CKManager: CloudKitManager
    
    init(ckManager: CloudKitManager) {
        self.CKManager = ckManager
    }
    
    enum DatabaseError: Error {
        case playerNameAlreadyExists
        case multipleProfileFound
        case publicProfileNotFound
        case forbiddenUpdate
        case forbiddenSubscription
        case invalidDataType
        case ProfileInitFailed
    }
}

// MARK: - Players Public Profiles
extension PublicDatabase {
    
    // MARK: - Fetch
    
    func isPlayerNameAlreadyInDatabase(_ playerName: String) async throws -> Bool {
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.playerName), playerName)
        let records = try await fetchProfiles(predicate: predicate)
        return !records.isEmpty
    }
    
    func fetchProfile(forUserRecordID userRecordID: CKRecord.ID) async throws -> PublicProfile {
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.userRecordID), userRecordID)
        let records = try await fetchProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        guard let publicProfile = PublicProfile(from: ckRecord) else { throw DatabaseError.invalidDataType }
        return publicProfile
    }
    
    private func fetchLocalProfile() async throws -> CKRecord {
        let userRecordID = try await CKManager.userRecordID()
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.userRecordID), userRecordID)
        let records = try await fetchProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        return ckRecord
    }
    
    private func validateSingleRecord(records: [CKRecord]) throws -> CKRecord {
        guard let ckRecord = records.first else { throw DatabaseError.publicProfileNotFound }
        guard records.count == 1 else { throw DatabaseError.multipleProfileFound }
        return ckRecord
    }
    
    private func fetchProfiles(predicate: NSPredicate) async throws -> [CKRecord] {
        let query = CKQuery(recordType: PublicProfile.RecordType, predicate: predicate)
        let (records, _) = try await CKManager.findRecords(matching: query)
        return records
    }

    func fetchManyProfiles(forUserRecordIDs userRecordIDs: [CKRecord.ID]) async throws -> [PublicProfile] {
        let predicate = NSPredicate(format: "%K IN %@", PublicProfile.forKey(.userRecordID), userRecordIDs)
        return try await fetchManyProfiles(using: predicate)
    }

    func fetchManyProfiles(forPlayerNames playerNames: [String]) async throws -> [PublicProfile] {
        let predicate = NSPredicate(format: "%K IN %@", PublicProfile.forKey(.playerName), playerNames)
        return try await fetchManyProfiles(using: predicate)
    }
    
    private func fetchManyProfiles(using predicate: NSPredicate) async throws -> [PublicProfile] {
        let ckRecords = try await fetchProfiles(predicate: predicate)
        return try ckRecords.map { ckRecord in
            guard let publicProfile = PublicProfile(from: ckRecord) else {
                throw DatabaseError.ProfileInitFailed
            }
            return publicProfile
        }
    }
 
    // MARK: - Add
    
    func addPublicProfileRecord(playerName: String) async throws -> PublicProfile {
        let nameExists = try await isPlayerNameAlreadyInDatabase(playerName)
          guard !nameExists else {
              throw DatabaseError.playerNameAlreadyExists
          }
        let userRecordID = try await CKManager.userRecordID()
        let publicPlayer = PublicProfile.new(
            userRecordID: CKRecord.Reference(recordID: userRecordID, action: .none),
            playerName: playerName
        )
        _ = try await CKManager.saveRecord(saving: publicPlayer.record)
        return publicPlayer
    }
    
    // MARK: - Update
    
    func updatePlayerName(saving newPlayerName: String) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .playerName, with: newPlayerName)
    }
    
    func updatePlayerEloRating(saving newEloRating: Int64) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .eloRating, with: newEloRating)
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
        try await self.updatePublicProfileRecord(field: .title, with: newTitle.rawValue)
    }
    
    func updateBanner(saving newBanner: Banner) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .banner, with: newBanner.rawValue)
    }
    
    func updateProfileImage(saving newProfileImage: ProfileImage) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .profileImage, with: newProfileImage.rawValue)
    }
    
    // Generalized update function
    private func updatePublicProfileRecord<T>(field: PublicProfile.Key, with newValue: T) async throws -> CKRecord {
        let ckRecord = try await self.fetchLocalProfile()
        
        switch field {
        case .playerName, .eloRating, .title, .banner, .profileImage:
            if let value = newValue as? CKRecordValue {
                ckRecord[PublicProfile.forKey(field)] = value
            } else {
                throw DatabaseError.invalidDataType
            }
        case .userRecordID:
            throw DatabaseError.forbiddenUpdate
        }
        
        return try await CKManager.saveRecord(saving: ckRecord)
    }
    
    // MARK: - Delete
    
    func deletePublicProfileRecord() async throws {
        let ckRecord = try await fetchLocalProfile()
        try await CKManager.deleteRecord(deleting: ckRecord.recordID)
    }
    
    // MARK: - Subscriptions
    
    func subscribeToChanges() async throws {
        try await self.subscribeToChanges(for: .playerName)
        try await self.subscribeToChanges(for: .eloRating)
        try await self.subscribeToChanges(for: .title)
        try await self.subscribeToChanges(for: .banner)
        try await self.subscribeToChanges(for: .profileImage)
    }
    
    func subscribeToChanges(for key: PublicProfile.Key) async throws {
        switch key {
        case .playerName, .eloRating, .title, .banner, .profileImage:
            let userRecordID = try await CKManager.userRecordID()
            
            let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.userRecordID), CKRecord.Reference(recordID: userRecordID, action: .none))
            let subscriptionID = "\(PublicProfile.forKey(key))-updates-\(userRecordID.recordName)"
            
            let subscription = CKQuerySubscription(
                recordType: PublicProfile.RecordType,
                predicate: predicate,
                subscriptionID: subscriptionID,
                options: [.firesOnRecordUpdate]
            )
            
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            notificationInfo.desiredKeys = [PublicProfile.forKey(key)]
            subscription.notificationInfo = notificationInfo
            _ = try await CKManager.saveSubscription(saving: subscription)
        case .userRecordID:
            throw DatabaseError.forbiddenSubscription
        }
    }
}

// MARK: - Leaderboards

extension PublicDatabase {
    func fetchLeaderboard(limit: Int = 50) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PublicProfile.RecordType, predicate: predicate)
        
        // Sort by eloRating in descending order
        let sortDescriptor = NSSortDescriptor(key: PublicProfile.forKey(.eloRating), ascending: false)
        query.sortDescriptors = [sortDescriptor]
        
        // Fetch records
        let (records, _) = try await CKManager.findRecords(matching: query, resultsLimit: limit)
        return records
    }
}

