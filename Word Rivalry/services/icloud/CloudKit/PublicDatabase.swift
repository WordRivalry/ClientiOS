//
//  CKPublicDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit
import os.log


extension Profile: CloudKitConvertible { // For database interaction
    
    static var recordType: String {
        "Profile"
    }
    
    // Public field
    enum Key: String {
        case userRecordID, playerName, eloRating, title, banner, profileImage, unlockedAchievementIDs
    }
    
    // Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
    
    convenience init?(from ckRecord: CKRecord) {
        guard let userRecordID = ckRecord[Profile.forKey(.userRecordID)] as? String,
              let playerName = ckRecord[Profile.forKey(.playerName)] as? String,
              let eloRating = ckRecord[Profile.forKey(.eloRating)] as? Int,
              let title = ckRecord[Profile.forKey(.title)] as? String,
              let banner = ckRecord[Profile.forKey(.banner)] as? String,
              let profileImage = ckRecord[Profile.forKey(.profileImage)] as? String,
              let unlockedAchievementIDs = ckRecord[Profile.forKey(.unlockedAchievementIDs)] as? [String] else {
            return nil
        }
        self.init(
            userRecordID: userRecordID,
            playerName: playerName,
            eloRating: eloRating,
            title: title,
            banner: banner,
            profileImage: profileImage,
            unlockedAchievementIDs: unlockedAchievementIDs
        )
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: Profile.recordType)
        record[Profile.forKey(.userRecordID)] = userRecordID
        record[Profile.forKey(.playerName)] = playerName
        record[Profile.forKey(.eloRating)] = eloRating
        record[Profile.forKey(.title)] = title
        record[Profile.forKey(.banner)] = banner
        record[Profile.forKey(.profileImage)] = profileImage
        record[Profile.forKey(.unlockedAchievementIDs)] = unlockedAchievementIDs
        return record
    }
}

class PublicDatabase {
    
    static let shared = PublicDatabase()
    private let logger = Logger(subsystem: "com.WordRivalry", category: "PublicDatabase")
    
    private let CKManager = CloudKitManager(
        containerIdentifier: "iCloud.WordRivalryContainer",
        databaseScope: .public)
    
    private init() {}
    
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
    
    func iCloudAccountStatus() async throws -> CKAccountStatus {
        try await self.CKManager.getICloudAccountStatus()
    }
    
    func fetchProfileIfExist() async throws -> Profile? {
        let userRecordID = try await CKManager.userRecordID()
        do { // If succeed, then user is not new
            return try await fetchProfile(forUserRecordID: userRecordID)
        } catch {
            logger.debug("Profile do not exist")
            return nil
        }
    }
    
    // MARK: - Fetch
    
    func fetchProfile(forUserRecordID userRecordID: CKRecord.ID) async throws -> Profile {
        let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.userRecordID), userRecordID.recordName)
        let records = try await fetchProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        guard let publicProfile = Profile(from: ckRecord) else { throw DatabaseError.invalidDataType }
        logger.debug("Profile fetched by userRecordID")
        return publicProfile
    }
    
    func fetchProfile(forPlayerName playerName: String) async throws -> Profile {
        let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.playerName), playerName)
        let records = try await fetchProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        guard let publicProfile = Profile(from: ckRecord) else { throw DatabaseError.invalidDataType }
        logger.debug("Profile fetched by playerName: \(playerName)")
        return publicProfile
    }
    
    func fetchLocalProfile() async throws -> CKRecord {
        let userRecordID = try await CKManager.userRecordID()
        let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.userRecordID), userRecordID.recordName)
        let records = try await fetchProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        logger.debug("Local Profile fetched")
        return ckRecord
    }
    
    func fetchTopPlayersRankedByElo(limit: Int) async throws -> [Profile] {
          let predicate = NSPredicate(value: true) // To fetch all records, because we sort them by eloRating
          let query = CKQuery(recordType: Profile.recordType, predicate: predicate)
          query.sortDescriptors = [NSSortDescriptor(key: Profile.forKey(.eloRating), ascending: false)] // Sort by eloRating in descending order
          let (ckRecords, _) = try await CKManager.findRecords(matching: query, resultsLimit: limit)
          let profiles = ckRecords.compactMap { ckRecord -> Profile? in
              return Profile(from: ckRecord)
          }
          guard profiles.count == ckRecords.count else {
              throw DatabaseError.ProfileInitFailed
          }
          
          logger.debug("Top players fetched, ranked by Elo")
          return profiles
      }
    
    private func validateSingleRecord(records: [CKRecord]) throws -> CKRecord {
        guard let ckRecord = records.first else { throw DatabaseError.publicProfileNotFound }
        guard records.count == 1 else { throw DatabaseError.multipleProfileFound }
        return ckRecord
    }
    
    private func fetchProfiles(predicate: NSPredicate) async throws -> [CKRecord] {
        let query = CKQuery(recordType: Profile.recordType, predicate: predicate)
        let (records, _) = try await CKManager.findRecords(matching: query)
        return records
    }
    
    func fetchManyProfiles(forUserRecordIDs userRecordIDs: [String]) async throws -> [Profile] {
        let predicate = NSPredicate(format: "%K IN %@", Profile.forKey(.userRecordID), userRecordIDs)
        return try await fetchManyProfiles(using: predicate)
    }
    
    func fetchManyProfiles(forUserRecordIDs userRecordIDs: [CKRecord.ID]) async throws -> [Profile] {
        let predicate = NSPredicate(format: "%K IN %@", Profile.forKey(.userRecordID), userRecordIDs.map({ recordIDs in
            return recordIDs.recordName
        }))
        return try await fetchManyProfiles(using: predicate)
    }
    
    func fetchManyProfiles(forPlayerNames playerNames: [String]) async throws -> [Profile] {
        let predicate = NSPredicate(format: "%K IN %@", Profile.forKey(.playerName), playerNames)
        return try await fetchManyProfiles(using: predicate)
    }
    
    private func fetchManyProfiles(using predicate: NSPredicate) async throws -> [Profile] {
        let ckRecords = try await fetchProfiles(predicate: predicate)
        return try ckRecords.map { ckRecord in
            guard let publicProfile = Profile(from: ckRecord) else {
                throw DatabaseError.ProfileInitFailed
            }
            return publicProfile
        }
    }
    
    // MARK: - Add
    
    func addProfileRecord(playerName: String) async throws -> Profile {
        try await checkIfPlayerNameAlreadyInDatabase(playerName)
        let userRecordID = try await CKManager.userRecordID()
        let profile = Profile(userRecordID: userRecordID.recordName, playerName: playerName)
        _ = try await CKManager.saveRecord(saving: profile.record)
        logger.debug("Profile saved to public databse")
        return profile
    }
    
    private func checkIfPlayerNameAlreadyInDatabase(_ playerName: String) async throws -> Void {
        let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.playerName), playerName)
        let records = try await fetchProfiles(predicate: predicate)
        let nameExists = !records.isEmpty
        guard nameExists == false else {
            throw DatabaseError.playerNameAlreadyExists
        }
        logger.debug("\(playerName) is unique")
    }
    
    // MARK: - Update
    
    func updatePlayerName(saving newPlayerName: String) async throws -> CKRecord {
        try await checkIfPlayerNameAlreadyInDatabase(newPlayerName)
        return try await self.updateProfileRecord(field: .playerName, with: newPlayerName)
    }
    
    func updatePlayerEloRating(saving newEloRating: Int) async throws -> CKRecord {
        try await self.updateProfileRecord(field: .eloRating, with: newEloRating)
    }
    
    func updateTitle(saving newTitle: Title) async throws -> CKRecord {
        try await self.updateProfileRecord(field: .title, with: newTitle.rawValue)
    }
    
    func updateBanner(saving newBanner: Banner) async throws -> CKRecord {
        try await self.updateProfileRecord(field: .banner, with: newBanner.rawValue)
    }
    
    func updateProfileImage(saving newProfileImage: ProfileImage) async throws -> CKRecord {
        try await self.updateProfileRecord(field: .profileImage, with: newProfileImage.rawValue)
    }
    
    func updateAchievementIDs(adding achievemntID: String) async throws -> CKRecord {
        try await self.updateProfileRecord(field: .unlockedAchievementIDs, with: achievemntID)
    }
    
    // Generalized update function
    private func updateProfileRecord<T>(field: Profile.Key, with newValue: T) async throws -> CKRecord {
        let ckRecord = try await self.fetchLocalProfile()
        
        switch field {
        case .playerName, .eloRating, .title, .banner, .profileImage:
            if let value = newValue as? CKRecordValue {
                ckRecord[Profile.forKey(field)] = value
                logger.debug("Profile updated for \(field.rawValue)")
            } else {
                throw DatabaseError.invalidDataType
            }
        case .unlockedAchievementIDs:
            if let newID = newValue as? String {
                // Ensure we are working with an array of Strings
                var existingIDs = ckRecord[Profile.forKey(field)] as? [String] ?? []
                // Append the new value if it's not already present to prevent duplicates
                if !existingIDs.contains(newID) {
                    existingIDs.append(newID)
                    ckRecord[Profile.forKey(field)] = existingIDs
                    logger.debug("Profile achievement ids updated with \(newID)")
                }
            } else {
                throw DatabaseError.invalidDataType
            }
        case .userRecordID:
            throw DatabaseError.forbiddenUpdate
        }
        
        return try await CKManager.saveRecord(saving: ckRecord)
    }
    
    // MARK: - Delete
    
    func deleteProfileRecord() async throws {
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
    
    func subscribeToChanges(for key: Profile.Key) async throws {
        switch key {
        case .playerName, .eloRating, .title, .banner, .profileImage, .unlockedAchievementIDs:
            let userRecordID = try await CKManager.userRecordID()
            
            let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.userRecordID), userRecordID.recordName)
            let subscriptionID = "\(Profile.forKey(key))-updates-\(userRecordID.recordName)"
            
            let subscription = CKQuerySubscription(
                recordType: Profile.recordType,
                predicate: predicate,
                subscriptionID: subscriptionID,
                options: [.firesOnRecordUpdate]
            )
            
            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            notificationInfo.desiredKeys = [Profile.forKey(key)]
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
        let query = CKQuery(recordType: Profile.recordType, predicate: predicate)
        
        // Sort by eloRating in descending order
        let sortDescriptor = NSSortDescriptor(key: Profile.forKey(.eloRating), ascending: false)
        query.sortDescriptors = [sortDescriptor]
        
        // Fetch records
        let (records, _) = try await CKManager.findRecords(matching: query, resultsLimit: limit)
        return records
    }
}

