//
//  CloudKitServices.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit
import SwiftUI

enum UserProfilFlag: String {
    case needsPublicRecordCreation
}

/// `CloudKitService` is a class responsible for handling CloudKit operations.
/// It provides functionalities to save user information to the private iCloud database.
class CloudKitService {
    private let privateDatabase = CKContainer(identifier: "iCloud.WordRivalryContainer").privateCloudDatabase
    private let publicDatabase = CKContainer(identifier: "iCloud.WordRivalryContainer").publicCloudDatabase
    init() {}
}

extension CloudKitService {

    func isUserNew() async throws -> Bool {
        // Attempt to fetch any existing private user info records
        let existingRecords = try await fetchPrivateRecords(ofType: ProfilRecordKey.privateUserInfoRecordType)
        
        // If no records are found, the user is considered new
        return existingRecords.isEmpty
    }
}


// MARK: - Profil creation
extension CloudKitService {
    
    func createUserRecord(username: String) async throws -> Void {
        
        // RECOVERY - If needed handle pending creation of public record
        if UserDefaults.standard.bool(forKey: UserProfilFlag.needsPublicRecordCreation.rawValue) {
            
            // Create public user record
            let existingPrivateUserInfoRecord = try await fetchPrivateUserInfoRecord()
            
            let publicRecord = try await createPublicUserInfoRecord(
                username: existingPrivateUserInfoRecord[ProfilRecordKey.username],
                uuid: existingPrivateUserInfoRecord[ProfilRecordKey.uuid]
            )
            
            // Save
            try await savePublicRecord(publicRecord)
            
            // Mark recovery as resolved
            UserDefaults.standard.set(false, forKey: UserProfilFlag.needsPublicRecordCreation.rawValue)
            
            // Early retun
            return
        }
        
        // Guard: Check if a UserInfo record already exists in the private database
        let existingRecords = try await fetchPrivateRecords(ofType: ProfilRecordKey.privateUserInfoRecordType)
        guard existingRecords.isEmpty else {
            throw NSError(domain: "CloudKitService", code: -6, userInfo: [NSLocalizedDescriptionKey: "User profile already exists."])
        }
        
        // Guard: Check if username is already in use
        let isUsernameTaken = try await isUsernameInPublicDatabase(username: username)
        guard !isUsernameTaken else {
            throw NSError(domain: "CloudKitService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Username is already taken."])
        }
        
        // Create new UUID for the user
        let userUUID = UUID().uuidString
        
        let profil = Profil(
            uuid: userUUID,
            username: username,
            friendsUUIDs: ["Hi"]
        )
        
        UserDefaultsManager.shared.setUsername(username)
        UserDefaultsManager.shared.setUserUUID(userUUID)
        
        // Save
        try await savePrivateRecord(profil.privateRecord)
        try await savePublicRecord(profil.publicRecord)
    }
    
    private func createPublicUserInfoRecord(username: Any?, uuid: Any?) async throws -> CKRecord {
        let record = CKRecord(recordType: ProfilRecordKey.publicUserInfoRecordType)
        if let username = username as? String, let uuid = uuid as? String {
            record[ProfilRecordKey.username] = username
            record[ProfilRecordKey.uuid] = uuid
        } else {
            // Data is corrupted, delete the private UserInfo Record
            try await deletePrivateUserInfoRecord()
            
            throw NSError(domain: "CloudKitService", code: -11, userInfo: [NSLocalizedDescriptionKey: "Data corrupted, private user record deleted."])
        }
        return record
    }
    
    private func savePrivateRecord(_ record: CKRecord) async throws -> Void {
        do {
            _ = try await privateDatabase.save(record)
        } catch {
            throw NSError(domain: "CloudKitService", code: -9, userInfo: [NSLocalizedDescriptionKey: "Failed to create private user record."])
        }
    }
    
    private func savePublicRecord(_ record: CKRecord) async throws -> Void {
        do {
            _ = try await publicDatabase.save(record)
        } catch {
            UserDefaults.standard.set(true, forKey: UserProfilFlag.needsPublicRecordCreation.rawValue)
            throw NSError(domain: "CloudKitService", code: -8, userInfo: [NSLocalizedDescriptionKey: "Failed to create public user record. Please try again."])
        }
    }
    
    private func deletePrivateUserInfoRecord() async throws {
        let existingRecord = try await fetchPrivateUserInfoRecord()
        do {
            _ = try await privateDatabase.deleteRecord(withID: existingRecord.recordID)
            UserDefaults.standard.set(false, forKey: UserProfilFlag.needsPublicRecordCreation.rawValue)
        } catch {
            throw NSError(domain: "CloudKitService", code: -12, userInfo: [NSLocalizedDescriptionKey: "Failed to delete corrupted private user record."])
        }
    }
}

// MARK: - Getters and Setters
extension CloudKitService {
    
    // Function to fetch the UUID for the current iCloud user
    func fetchUUID() async throws -> String {
        let userRecord = try await fetchPrivateUserInfoRecord()
        guard let uuid = userRecord[ProfilRecordKey.uuid] as? String else {
            throw NSError(domain: "CloudKitService", code: -8, userInfo: [NSLocalizedDescriptionKey: "UUID not found."])
        }
        return uuid
    }
    
    // Function to fetch the username for the current iCloud user
    func fetchUsername() async throws -> String {
        let userRecord = try await fetchPrivateUserInfoRecord()
        guard let username = userRecord[ProfilRecordKey.username] as? String else {
            throw NSError(domain: "CloudKitService", code: -7, userInfo: [NSLocalizedDescriptionKey: "Username not found."])
        }
        return username
    }
    
    // Function to update the username for the current iCloud user
    func updateUsernameRecord(username: String) async throws -> Void {
        
        // Guard: Check if new username is already in use
        let isUsernameTaken = try await isUsernameInPublicDatabase(username: username)
        guard !isUsernameTaken else {
            throw NSError(domain: "CloudKitService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Username is already taken."])
        }
        
        let record = try await fetchPrivateUserInfoRecord()
        record[ProfilRecordKey.username] = username
        try await privateDatabase.save(record)
        UserDefaultsManager.shared.setUsername(username)
    }
}

extension CloudKitService {

    // MARK: Add Friend
    func addFriend(byUsername friendUsername: String) async throws {
        let friendPublicRecord = try await searchPublicUser(byUsername: friendUsername)
        
        guard let friendUUID = friendPublicRecord?[ProfilRecordKey.uuid] as? String else {
            throw NSError(domain: "CloudKitService", code: -14, userInfo: [NSLocalizedDescriptionKey: "Unable to find friend's UUID."])
        }
        
        let userPrivateRecord = try await fetchPrivateUserInfoRecord()
        
        var friendsUUIDs = userPrivateRecord[ProfilRecordKey.friendsUUIDs] as? [String] ?? []
        if !friendsUUIDs.contains(friendUUID) {
            friendsUUIDs.append(friendUUID)
            userPrivateRecord[ProfilRecordKey.friendsUUIDs] = friendsUUIDs
            
            _ = try await privateDatabase.save(userPrivateRecord)
        }
    }

    // MARK: Remove Friend
    func removeFriend(friendUUID: String) async throws {
        let userPrivateRecord = try await fetchPrivateUserInfoRecord()
        
        var friendsUUIDs = userPrivateRecord[ProfilRecordKey.friendsUUIDs] as? [String] ?? []
        friendsUUIDs.removeAll(where: { $0 == friendUUID })
        userPrivateRecord[ProfilRecordKey.friendsUUIDs] = friendsUUIDs
        
        _ = try await privateDatabase.save(userPrivateRecord)
    }

    // MARK: Search Friend by Username
    func searchPublicUser(byUsername username: String) async throws -> CKRecord? {
        let predicate = NSPredicate(format: "\(ProfilRecordKey.username) == %@", username)
        let query = CKQuery(recordType: ProfilRecordKey.publicUserInfoRecordType, predicate: predicate)

        // Using the new fetch method with async/await
        return try await withCheckedThrowingContinuation { continuation in
            self.publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
                switch result {
                case .success(let (matchResults, _)):
                    // Assuming you're interested only in the first record
                    let firstRecordResult = matchResults.first?.1
                    switch firstRecordResult {
                    case .success(let record):
                        continuation.resume(returning: record)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    case .none:
                        continuation.resume(returning: nil)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }


    // MARK: Fetch Public Profile
}


// MARK: - CloudKit Helpers
extension CloudKitService {

    private func isUsernameInPublicDatabase(username: String) async throws -> Bool {
        let predicate = NSPredicate(format: "\(ProfilRecordKey.username) == %@", username)
        let query = CKQuery(recordType: ProfilRecordKey.privateUserInfoRecordType, predicate: predicate)
        
        return try await withCheckedThrowingContinuation { continuation in
            publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
                switch result {
                case .success(let (matchResults, _)):
                    // If there is at least one matching result, the username is taken
                    continuation.resume(returning: !matchResults.isEmpty)
                    
                case .failure(let error):
                    let errorMessage = self.handleCloudKitError(error)
                    continuation.resume(throwing: NSError(domain: "CloudKitService", code: -4, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
        }
    }
    
    // Function to handle multiple CK erros
    private func handleCloudKitError(_ error: Error) -> String {
        if let ckError = error as? CKError {
            switch ckError.code {
            case .networkUnavailable, .networkFailure:
                return "Network error occurred. Please check your internet connection."
            case .quotaExceeded:
                return "You have exceeded your iCloud quota."
            case .notAuthenticated:
                return "You are not logged into iCloud. Please log in and try again."
            default:
                return "An unknown error occurred: \(ckError.localizedDescription)"
            }
        } else {
            return "A non-CloudKit error occurred: \(error.localizedDescription)"
        }
    }
    
    private func fetchPrivateUserInfoRecord() async throws -> CKRecord {
        
        let existingRecords = try await fetchPrivateRecords(ofType: ProfilRecordKey.privateUserInfoRecordType)
        
        
        // Guard: Check UserInfo record integrity
        guard existingRecords.count == 1 else {
            if existingRecords.isEmpty {
                throw NSError(domain: "CloudKitService", code: -7, userInfo: [NSLocalizedDescriptionKey: "User profile not found."])
            } else {
                
                // TODO: Enter recovery mode. // Send notification for mannual handling
                
                throw NSError(domain: "CloudKitService", code: -6, userInfo: [NSLocalizedDescriptionKey: "Multiple user profiles found."])
            }
        }
        
        // Safe to use existingRecords[0] as we've guarded against empty array and multiple records
        return existingRecords[0]
    }
    
    // Generic function to fetch all records of a specified type
    private func fetchPrivateRecords(ofType recordType: String) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true) // Fetches all records of the specified type
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        return try await withCheckedThrowingContinuation { continuation in
            privateDatabase.fetch(withQuery: query, inZoneWith: nil) { result in
                switch result {
                case .success(let (matchResults, _)):
                    let records = matchResults.compactMap { try? $0.1.get() }
                    continuation.resume(returning: records)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

