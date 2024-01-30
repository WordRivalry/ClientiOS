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
}

/// `CloudKitService` is a singleton class responsible for handling CloudKit operations.
/// It provides functionalities to save user information to the private iCloud database.
class CloudKitService {
    // MARK: - Properties
    static let shared = CloudKitService()
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    
    // MARK: - Initialization
    private init() {} // Private initializer to ensure singleton usage
}

extension CloudKitService {
    // MARK: - Public Methods
    func saveUserInfo(username: String, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        NetworkUtility.shared.isInternetAvailable { isConnected in
            if isConnected {
                self.handleUsernameRegistration(username: username, completion: completion)
            } else {
                completion(.failure(NSError(domain: "CloudKitService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No internet connection available."])))
            }
        }
    }
    
    // MARK: - Private Methods
    private func handleUsernameRegistration(username: String, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        checkUsernameInPublicDatabase(username: username) { [weak self] result in
            switch result {
            case .success(let isUnique):
                if isUnique {
                    self?.createOrUpdateUserRecord(username: username, completion: completion)
                } else {
                    completion(.failure(NSError(domain: "CloudKitService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Username already exists."])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func createOrUpdateUserRecord(username: String, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        // Define a predicate to search for an existing user record
        let predicate = NSPredicate(format: "\(CloudKitConstants.usernameKey) == %@", username)
        let query = CKQuery(recordType: CloudKitConstants.userInfoRecordType, predicate: predicate)

        executeQuery(query, in: privateDatabase) { [weak self] result in
            switch result {
            case .success(let records):
                if let existingRecord = records.first {
                    // Update the existing record
                    existingRecord[CloudKitConstants.usernameKey] = username
                    self?.privateDatabase.save(existingRecord, completionHandler: { (record, error) in
                        if let error = error {
                            completion(.failure(error))
                        } else if let record = record {
                            completion(.success(record))
                        }
                    })
                } else {
                    // Create a new record
                    let newRecord = CKRecord(recordType: CloudKitConstants.userInfoRecordType)
                    newRecord[CloudKitConstants.usernameKey] = username
                    let uniqueID = UUID().uuidString
                    newRecord[CloudKitConstants.uuidKey] = uniqueID

                    self?.privateDatabase.save(newRecord, completionHandler: { (record, error) in
                        if let error = error {
                            completion(.failure(error))
                        } else if let record = record {
                            completion(.success(record))
                        }
                    })
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func checkUsernameInPublicDatabase(username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let predicate = NSPredicate(format: "\(CloudKitConstants.usernameKey) == %@", username)
        let query = CKQuery(recordType: CloudKitConstants.userInfoRecordType, predicate: predicate)
        executeQuery(query, in: publicDatabase) { result in
            switch result {
            case .success(let records):
                completion(.success(records.isEmpty))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func executeQuery(_ query: CKQuery, in database: CKDatabase, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let queryOperation = CKQueryOperation(query: query)
        var fetchedRecords = [CKRecord]()

        queryOperation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                // Handle individual record error if necessary
                break
            }
        }

        queryOperation.queryResultBlock = { result in
            switch result {
            case .success(_):
                completion(.success(fetchedRecords))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        database.add(queryOperation)
    }

}
