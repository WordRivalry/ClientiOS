//
//  CloudKitServices.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit

// Constants for CloudKit record types and keys
struct CloudKitConstants {
    static let userInfoRecordType = "UserInfo"
    static let usernameKey = "username"
    static let uuidKey = "uuid"
    static let themePreferenceKey = "themePreference"
}

enum ThemeConstants: String {
    case dark = "dark"
    case light = "light"
    case system = "system"

    init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
    var stringValue: String {
        return self.rawValue
    }
}

/// `CloudKitService` is a class responsible for handling CloudKit operations.
/// It provides functionalities to save user information to the private iCloud database.
class CloudKitService {
    // MARK: - Properties
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    
    // MARK: - Initialization
    init() {}
}

extension CloudKitService {
    
    // MARK: - CloudKit Operations
    func createUserRecord(username: String) async throws -> CKRecord {
        
        // Guard: Check if username is already in use
        let isUsernameTaken = try await isUsernameInPublicDatabase(username: username)
        guard !isUsernameTaken else {
            throw NSError(domain: "CloudKitService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Username is already taken."])
        }
        
        let newRecord = CKRecord(recordType: CloudKitConstants.userInfoRecordType)
        newRecord[CloudKitConstants.usernameKey] = username
        newRecord[CloudKitConstants.uuidKey] = UUID().uuidString
        newRecord[CloudKitConstants.themePreferenceKey] = ThemeConstants.system.stringValue
        
        do {
            let savedRecord = try await privateDatabase.save(newRecord)
            return savedRecord
        } catch {
            let errorMessage = self.handleCloudKitError(error)
            throw NSError(domain: "CloudKitService", code: -4, userInfo: [NSLocalizedDescriptionKey: errorMessage]);
        }
    }

    // Function to fetch the username for the current iCloud user
    func fetchUsername() async throws -> String {
        let userRecord = try await fetchCurrentUserRecord()
        guard let username = userRecord[CloudKitConstants.usernameKey] as? String else {
            throw NSError(domain: "CloudKitService", code: -7, userInfo: [NSLocalizedDescriptionKey: "Username not found."])
        }
        return username
    }

    // Function to fetch the UUID for the current iCloud user
    func fetchUUID() async throws -> String {
        let userRecord = try await fetchCurrentUserRecord()
        guard let uuid = userRecord[CloudKitConstants.uuidKey] as? String else {
            throw NSError(domain: "CloudKitService", code: -8, userInfo: [NSLocalizedDescriptionKey: "UUID not found."])
        }
        return uuid
    }

    // Function to fetch the theme preference for the current iCloud user
    func fetchThemePreference() async throws -> ThemeConstants {
        let userRecord = try await fetchCurrentUserRecord()
        guard let themePreferenceString = userRecord[CloudKitConstants.themePreferenceKey] as? String,
              let themePreference = ThemeConstants(rawValue: themePreferenceString) else {
            throw NSError(domain: "CloudKitService", code: -9, userInfo: [NSLocalizedDescriptionKey: "Theme preference not found."])
        }
        return themePreference
    }

    
    // Function to update the username for the current iCloud user
    func updateUsernameRecord(username: String) async throws -> CKRecord {
        
        // Guard: Check if new username is already in use
        let isUsernameTaken = try await isUsernameInPublicDatabase(username: username)
        guard !isUsernameTaken else {
            throw NSError(domain: "CloudKitService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Username is already taken."])
        }
        
        let userRecordID = try await fetchCurrentUserRecordID()
        let record = try await privateDatabase.record(for: userRecordID)
        record[CloudKitConstants.usernameKey] = username
        return try await privateDatabase.save(record)
    }
    
    // Function to update the theme preference for the current iCloud user
    func updateThemePreferenceRecord(themePreference: ThemeConstants) async throws -> CKRecord {
        let userRecordID = try await fetchCurrentUserRecordID()
        let record = try await privateDatabase.record(for: userRecordID)
        record[CloudKitConstants.themePreferenceKey] = themePreference.stringValue
        return try await privateDatabase.save(record)
    }

}

extension CloudKitService {
    // MARK: - CloudKit Helpers
    private func isUsernameInPublicDatabase(username: String) async throws -> Bool {
        let predicate = NSPredicate(format: "\(CloudKitConstants.usernameKey) == %@", username)
        let query = CKQuery(recordType: CloudKitConstants.userInfoRecordType, predicate: predicate)
        
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
    
    // Function to fetch the iCloud user's unique identifier
    private func fetchCurrentUserRecord() async throws -> CKRecord {
        let userRecordID = try await fetchCurrentUserRecordID()
        return try await privateDatabase.record(for: userRecordID)
    }
    
    // Helper function to fetch the current user record
    private func fetchCurrentUserRecordID() async throws -> CKRecord.ID {
        return try await CKContainer.default().userRecordID()
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
}
