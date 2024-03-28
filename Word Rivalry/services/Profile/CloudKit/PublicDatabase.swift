//
//  CKPublicDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit


extension Profile: CloudKitConvertible { // For database interaction
    
    static var recordType: String {
        "Profile"
    }
    
    // Public field
    enum Key: String {
        case userRecordID, playerName, eloRating, title, banner, profileImage
    }
    
    // Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
    
    convenience init?(from ckRecord: CKRecord) {
        guard let userRecordID = ckRecord[Profile.forKey(.userRecordID)] as? String,
              let playerName = ckRecord[Profile.forKey(.playerName)] as? String,
              let eloRating = ckRecord[Profile.forKey(.eloRating)] as? Int,
              let title = ckRecord[Profile.forKey(.title)] as? Int,
              let banner = ckRecord[Profile.forKey(.banner)] as? Int,
              let profileImage = ckRecord[Profile.forKey(.profileImage)] as? Int else {
            return nil
        }
        self.init(userRecordID: userRecordID, playerName: playerName, eloRating: eloRating, title: title, banner: banner, profileImage: profileImage)
    }
    
    convenience init?(forNew // Default provided define a new public profile values
                      userRecordID: String,
                      playerName: String,
                      eloRating: Int = 800,
                      title: Int = 0,
                      banner: Int = 0,
                      profileImage: Int = 0
    ) {
        self.init(userRecordID: userRecordID, playerName: playerName, eloRating: eloRating, title: title, banner: banner, profileImage: profileImage)
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: Profile.recordType)
        record[Profile.forKey(.userRecordID)] = userRecordID
        record[Profile.forKey(.playerName)] = playerName
        record[Profile.forKey(.eloRating)] = eloRating
        record[Profile.forKey(.title)] = title
        record[Profile.forKey(.banner)] = banner
        record[Profile.forKey(.profileImage)] = profileImage
        return record
    }
}

class PublicDatabase {
    
    static let shared = PublicDatabase()
    
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
            return nil
        }
    }
    
    // MARK: - Fetch
    
    func fetchProfile(forUserRecordID userRecordID: CKRecord.ID) async throws -> Profile {
        let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.userRecordID), userRecordID.recordName)
        let records = try await fetchProfiles(predicate: predicate)
        let ckRecord = try validateSingleRecord(records: records)
        guard let publicProfile = Profile(from: ckRecord) else { throw DatabaseError.invalidDataType }
        return publicProfile
    }
    
    func fetchLocalProfile() async throws -> CKRecord {
        let userRecordID = try await CKManager.userRecordID()
        let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.userRecordID), userRecordID.recordName)
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
        let query = CKQuery(recordType: Profile.recordType, predicate: predicate)
        let (records, _) = try await CKManager.findRecords(matching: query)
        return records
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
        print("\(playerName) is unique")
        let userRecordID = try await CKManager.userRecordID()
        let profile = Profile(forNew:
                                userRecordID.recordName,
                              playerName: playerName
        )
        guard let profile = profile else { throw DatabaseError.ProfileInitFailed }
        _ = try await CKManager.saveRecord(saving: profile.record)
        print("Profile saved to public databse")
        return profile
    }
    
    private func checkIfPlayerNameAlreadyInDatabase(_ playerName: String) async throws -> Void {
        let predicate = NSPredicate(format: "%K == %@", Profile.forKey(.playerName), playerName)
        let records = try await fetchProfiles(predicate: predicate)
        let nameExists = !records.isEmpty
        guard nameExists == false else {
            throw DatabaseError.playerNameAlreadyExists
        }
    }
    
    // MARK: - Update
    
    func updatePlayerName(saving newPlayerName: String) async throws -> CKRecord {
        try await checkIfPlayerNameAlreadyInDatabase(newPlayerName)
        return try await self.updateProfileRecord(field: .playerName, with: newPlayerName)
    }
    
    func updatePlayerEloRating(saving newEloRating: Int) async throws -> CKRecord {
        try await self.updateProfileRecord(field: .eloRating, with: newEloRating)
    }
    
    enum Title: Int {
        case defaultTitle = 0
        // other titles
    }
    
    enum Banner: Int {
        case defaultBanner = 0
        // other banners
    }
    
    enum ProfileImage: Int {
        case defaultImage = 0
        // other images
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
    
    // Generalized update function
    private func updateProfileRecord<T>(field: Profile.Key, with newValue: T) async throws -> CKRecord {
        let ckRecord = try await self.fetchLocalProfile()
        
        switch field {
        case .playerName, .eloRating, .title, .banner, .profileImage:
            if let value = newValue as? CKRecordValue {
                ckRecord[Profile.forKey(field)] = value
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
        case .playerName, .eloRating, .title, .banner, .profileImage:
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

