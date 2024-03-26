//
//  CKUserRecord.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit


class CKUserRecord {
    private let privateDatabase = CKContainer(identifier: "iCloud.WordRivalryContainer").privateCloudDatabase
    init() {}
    
    // Fetches the current user's CKRecord and modifies it
    func updateUserRecord(playerName: String) async throws -> CKRecord {
        // Fetch the current user's record
        let userRecord = try await fetchCurrentUserRecord()
        
        // Modify the user's record with the new player name
        userRecord[ProfilRecordKey.playerName] = playerName
        
        // Save the modified record back to CloudKit
        return try await saveUserRecord(userRecord)
    }
    
    
    func fetchCurrentUserRecord() async throws -> CKRecord {
        return try await withCheckedThrowingContinuation { continuation in
            CKContainer.default().fetchUserRecordID { userRecordID, error in
                // Directly handle the callback pattern used by fetchUserRecordID
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let userRecordID = userRecordID else {
                    continuation.resume(throwing: NSError(domain: "CloudKitService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve userRecordID."]))
                    return
                }
                
                // Use the obtained userRecordID to fetch the user's CKRecord
                CKContainer.default().privateCloudDatabase.fetch(withRecordID: userRecordID) { record, error in
                    if let record = record {
                        continuation.resume(returning: record)
                    } else if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: NSError(domain: "CloudKitService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Unknown error fetching current user record."]))
                    }
                }
            }
        }
    }
    
    // Saves the provided CKRecord to CloudKit's private database
    private func saveUserRecord(_ record: CKRecord) async throws -> CKRecord {
        // Save the modified record back to CloudKit
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CKRecord, Error>) in
            CKContainer.default().privateCloudDatabase.save(record) { record, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let record = record {
                    continuation.resume(returning: record)
                } else {
                    continuation.resume(throwing: NSError(domain: "CloudKitService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save the user record, but no error was provided by CloudKit."]))
                }
            }
        }
    }
}
