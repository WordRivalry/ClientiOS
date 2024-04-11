//
//  CKPublicDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit
import os.log


extension PublicProfile: CloudKitConvertible { // For database interaction
    
    static var recordType: String {
        "PublicProfile"
    }
    
    // Public field
    enum Key: String {
        case userRecordID, playerName, eloRating, title, banner, profileImage, unlockedAchievementIDs, matchPlayed, matchWon
    }
    
    // Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
    
    convenience init?(from ckRecord: CKRecord) {
        guard let userRecordID = ckRecord[PublicProfile.forKey(.userRecordID)] as? String,
              let playerName = ckRecord[PublicProfile.forKey(.playerName)] as? String,
              let eloRating = ckRecord[PublicProfile.forKey(.eloRating)] as? Int,
              let title = ckRecord[PublicProfile.forKey(.title)] as? String,
              let banner = ckRecord[PublicProfile.forKey(.banner)] as? String,
              let matchPlayer = ckRecord[PublicProfile.forKey(.matchPlayed)] as? Int,
              let matchWon = ckRecord[PublicProfile.forKey(.matchWon)] as? Int,
              let profileImage = ckRecord[PublicProfile.forKey(.profileImage)] as? String else {
            return nil
        }

        // Handle unlockedAchievementIDs separately to allow for an empty array
        let unlockedAchievementIDs = ckRecord[PublicProfile.forKey(.unlockedAchievementIDs)] as? [String] ?? []
        
        self.init(
            userRecordID: userRecordID,
            playerName: playerName,
            eloRating: eloRating,
            title: title,
            banner: banner,
            profileImage: profileImage,
            unlockedAchievementIDs: unlockedAchievementIDs,
            matchPlayed: matchPlayer,
            matchWon: matchWon
        )
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: PublicProfile.recordType)
        record[PublicProfile.forKey(.userRecordID)] = userRecordID
        record[PublicProfile.forKey(.playerName)] = playerName
        record[PublicProfile.forKey(.eloRating)] = eloRating
        record[PublicProfile.forKey(.title)] = title
        record[PublicProfile.forKey(.banner)] = banner
        record[PublicProfile.forKey(.profileImage)] = profileImage
        record[PublicProfile.forKey(.unlockedAchievementIDs)] = unlockedAchievementIDs
        record[PublicProfile.forKey(.matchPlayed)] = matchPlayed
        record[PublicProfile.forKey(.matchWon)] = matchWon
        return record
    }
}

class PublicDatabase {
    
    static let shared = PublicDatabase()
    private let logger = Logger(subsystem: "CloudKit", category: "PublicDatabase")
    
    private let CKManager = CloudKitManager(
        containerIdentifier: "iCloud.WordRivalryContainer",
        databaseScope: .public)
    
    private init() {}
    
    enum DatabaseError: Error {
        case playerNameAlreadyExists
        case multiplePublicProfileFound
        case publicPublicProfileNotFound
        case forbiddenUpdate
        case forbiddenSubscription
        case invalidDataType
        case PublicProfileInitFailed
    }
}

// MARK: - Players Public PublicProfiles
extension PublicDatabase {
    
    func iCloudAccountStatus() async throws -> CKAccountStatus {
        try await self.CKManager.getICloudAccountStatus()
    }
    
    func fetchOwnPublicProfileIfExist() async throws -> PublicProfile? {
        let userRecordID = try await CKManager.userRecordID()
        do { // If succeed, then user is not new
            return try await fetchPublicProfile(forUserRecordID: userRecordID)
        } catch {
            logger.debug("PublicProfile do not exist")
            return nil
        }
    }
    
    // MARK: - Fetch
    
    func isUsernameTaken(_ playerName: String) async throws -> Bool {
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.playerName), playerName)
        let records = try await fetchPublicProfiles(predicate: predicate)
        let nameExists = !records.isEmpty
        guard nameExists == false else {
            return true
        }
        return false
    }
    
    func fetchPublicProfile(forUserRecordID userRecordID: String) async throws -> PublicProfile {
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.userRecordID), userRecordID)
        let records = try await fetchPublicProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        guard let publicPublicProfile = PublicProfile(from: ckRecord) else { throw DatabaseError.invalidDataType }
        logger.debug("PublicProfile fetched by userRecordID")
        return publicPublicProfile
    }
    
    func fetchPublicProfile(forUserRecordID userRecordID: CKRecord.ID) async throws -> PublicProfile {
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.userRecordID), userRecordID.recordName)
        let records = try await fetchPublicProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        guard let publicPublicProfile = PublicProfile(from: ckRecord) else { throw DatabaseError.invalidDataType }
        logger.debug("PublicProfile fetched by userRecordID")
        return publicPublicProfile
    }
    
    func fetchPublicProfile(forPlayerName playerName: String) async throws -> PublicProfile {
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.playerName), playerName)
        let records = try await fetchPublicProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        guard let publicPublicProfile = PublicProfile(from: ckRecord) else { throw DatabaseError.invalidDataType }
        logger.debug("PublicProfile fetched by playerName: \(playerName)")
        return publicPublicProfile
    }
    
    func fetchOwnPublicProfile() async throws -> CKRecord {
        let userRecordID = try await CKManager.userRecordID()
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.userRecordID), userRecordID.recordName)
        let records = try await fetchPublicProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        logger.debug("Own PublicProfile fetched")
        return ckRecord
    }
    
    func fetchLeaderboard(limit: Int) async throws -> [PublicProfile] {
          let predicate = NSPredicate(value: true) // To fetch all records, because we sort them by eloRating
          let query = CKQuery(recordType: PublicProfile.recordType, predicate: predicate)
          query.sortDescriptors = [NSSortDescriptor(key: PublicProfile.forKey(.eloRating), ascending: false)] // Sort by eloRating in descending order
          let (ckRecords, _) = try await CKManager.findRecords(matching: query, resultsLimit: limit)
          let publicProfiles = ckRecords.compactMap { ckRecord -> PublicProfile? in
              return PublicProfile(from: ckRecord)
          }
          guard publicProfiles.count == ckRecords.count else {
              throw DatabaseError.PublicProfileInitFailed
          }
          
          logger.debug("Leaderboard fetched")
          return publicProfiles
      }
    
    private func validateSingleRecord(records: [CKRecord]) throws -> CKRecord {
        guard let ckRecord = records.first else { throw DatabaseError.publicPublicProfileNotFound }
        guard records.count == 1 else { throw DatabaseError.multiplePublicProfileFound }
        return ckRecord
    }
    
    func fetchManyPublicProfiles(forUserRecordIDs userRecordIDs: [String]) async throws -> [PublicProfile] {
        let predicate = NSPredicate(format: "%K IN %@", PublicProfile.forKey(.userRecordID), userRecordIDs)
        return try await fetchManyPublicProfiles(using: predicate)
    }
    
    func fetchManyPublicProfiles(forUserRecordIDs userRecordIDs: [CKRecord.ID]) async throws -> [PublicProfile] {
        let predicate = NSPredicate(format: "%K IN %@", PublicProfile.forKey(.userRecordID), userRecordIDs.map({ recordIDs in
            return recordIDs.recordName
        }))
        return try await fetchManyPublicProfiles(using: predicate)
    }
    
    func fetchManyPublicProfiles(forPlayerNames playerNames: [String]) async throws -> [PublicProfile] {
        let predicate = NSPredicate(format: "%K IN %@", PublicProfile.forKey(.playerName), playerNames)
        return try await fetchManyPublicProfiles(using: predicate)
    }
    
    private func fetchManyPublicProfiles(using predicate: NSPredicate) async throws -> [PublicProfile] {
        let ckRecords = try await fetchPublicProfiles(predicate: predicate)
        return try ckRecords.map { ckRecord in
            guard let publicPublicProfile = PublicProfile(from: ckRecord) else {
                throw DatabaseError.PublicProfileInitFailed
            }
            return publicPublicProfile
        }
    }
    
    private func fetchPublicProfiles(predicate: NSPredicate) async throws -> [CKRecord] {
        let query = CKQuery(recordType: PublicProfile.recordType, predicate: predicate)
        let (records, _) = try await CKManager.findRecords(matching: query)
        return records
    }
    
    // MARK: - Add
    
    func addPublicProfileRecord(playerName: String) async throws -> PublicProfile {
        try await checkIfPlayerNameAlreadyInDatabase(playerName)
        let userRecordID = try await CKManager.userRecordID()
        let publicProfile = PublicProfile(userRecordID: userRecordID.recordName, playerName: playerName)
        _ = try await CKManager.saveRecord(saving: publicProfile.record)
        logger.debug("PublicProfile saved to public databse")
        return publicProfile
    }
    
    private func checkIfPlayerNameAlreadyInDatabase(_ playerName: String) async throws -> Void {
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.playerName), playerName)
        let records = try await fetchPublicProfiles(predicate: predicate)
        let nameExists = !records.isEmpty
        guard nameExists == false else {
            throw DatabaseError.playerNameAlreadyExists
        }
        logger.debug("\(playerName) is unique")
    }
    
    func addPublicProfileRecord(for profile: PublicProfile) async throws -> PublicProfile {
        try await checkIfPlayerNameAlreadyInDatabase(profile.playerName)
        let userRecordID = try await CKManager.userRecordID()
        _ = try await CKManager.saveRecord(saving: profile.record)
        logger.debug("PublicProfile saved to public databse")
        return profile
    }
    
    
    // MARK: - Update
    
    func updatePlayerName(saving newPlayerName: String) async throws -> CKRecord {
        try await checkIfPlayerNameAlreadyInDatabase(newPlayerName)
        return try await self.updatePublicProfileRecord(field: .playerName, with: newPlayerName)
    }
    
    func updatePlayerEloRating(saving newEloRating: Int) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .eloRating, with: newEloRating)
    }
    
    func updatePlayerMatchPlayed(saving newMatchedPlayed: Int) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .matchPlayed, with: newMatchedPlayed)
    }
    
    func updatePlayerMatchWon(saving newMatchedWon: Int) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .matchWon, with: newMatchedWon)
    }
    
    func updateTitle(saving newTitle: Title) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .title, with: newTitle.rawValue)
    }
    
    func updateBanner(saving newBanner: Banner) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .banner, with: newBanner.rawValue)
    }
    
    func updatePublicProfileImage(saving newPublicProfileImage: ProfileImage) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .profileImage, with: newPublicProfileImage.rawValue)
    }
    
    func updateAchievementIDs(adding achievemntID: String) async throws -> CKRecord {
        try await self.updatePublicProfileRecord(field: .unlockedAchievementIDs, with: achievemntID)
    }
    
    // Generalized update function
    private func updatePublicProfileRecord<T>(field: PublicProfile.Key, with newValue: T) async throws -> CKRecord {
        let ckRecord = try await self.fetchOwnPublicProfile()
        
        switch field {
        case .playerName, .eloRating, .title, .banner, .profileImage, .matchPlayed, .matchWon:
            if let value = newValue as? CKRecordValue {
                ckRecord[PublicProfile.forKey(field)] = value
                logger.debug("PublicProfile updated for \(field.rawValue)")
            } else {
                throw DatabaseError.invalidDataType
            }
        case .unlockedAchievementIDs:
            if let newID = newValue as? String {
                // Ensure we are working with an array of Strings
                var existingIDs = ckRecord[PublicProfile.forKey(field)] as? [String] ?? []
                // Append the new value if it's not already present to prevent duplicates
                if !existingIDs.contains(newID) {
                    existingIDs.append(newID)
                    ckRecord[PublicProfile.forKey(field)] = existingIDs
                    logger.debug("PublicProfile achievement ids updated with \(newID)")
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
    
    func deletePublicProfileRecord() async throws {
        let ckRecord = try await fetchOwnPublicProfile()
        try await CKManager.deleteRecord(deleting: ckRecord.recordID)
    }
    
    // MARK: - Subscriptions
    
    func subscribeToChanges() async throws {
        // Only proceed if you need to create the subscription.
        guard !UserDefaults.standard.bool(forKey: "didCreatePublicProfileSubscription") else { return }
        
        let userRecordID = try await CKManager.userRecordID()
        
        let predicate = NSPredicate(format: "%K == %@", PublicProfile.forKey(.userRecordID), userRecordID.recordName)
        let subscriptionID = "PublicProfile-updates-\(userRecordID.recordName)"
        
        let subscription = CKQuerySubscription(
            recordType: PublicProfile.recordType,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        _ = try await CKManager.saveSubscription(saving: subscription)
        
        // Set the flag to indicate that the subscription has been created.
        UserDefaults.standard.set(true, forKey: "didCreateQuerySubscription")
    }
}

// MARK: - Leaderboards

extension PublicDatabase {
//    func fetchLeaderboard(limit: Int = 50) async throws -> [CKRecord] {
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: PublicProfile.recordType, predicate: predicate)
//        
//        // Sort by eloRating in descending order
//        let sortDescriptor = NSSortDescriptor(key: PublicProfile.forKey(.eloRating), ascending: false)
//        query.sortDescriptors = [sortDescriptor]
//        
//        // Fetch records
//        let (records, _) = try await CKManager.findRecords(matching: query, resultsLimit: limit)
//        return records
//    }
}

