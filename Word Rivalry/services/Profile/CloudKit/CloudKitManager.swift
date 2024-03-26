//
//  CloudKitManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit

class CloudKitManager {
    private let container: CKContainer
    private var database: CKDatabase
    
    init(containerIdentifier: String, databaseScope: CKDatabase.Scope) {
        self.container = CKContainer(identifier: containerIdentifier)
        switch databaseScope {
        case .private:
            self.database = container.privateCloudDatabase
        case .public:
            self.database = container.publicCloudDatabase
        case .shared:
            self.database = container.sharedCloudDatabase
        @unknown default:
            fatalError()
        }
    }
    
    // MARK: - Fetch User Record ID
    func userRecordID(completionHandler: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if let recordID = recordID {
                completionHandler(.success(recordID))
            } else if let error = error {
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    // Async version
    func userRecordID() async throws -> CKRecord.ID {
        return try await container.userRecordID()
    }
    
    // MARK: - Fetch User Record
    
    func userRecord() async throws -> CKRecord {
        return try await findRecord(for: userRecordID())
    }
    
    // MARK: - Fetch Records
    // Async version
    func records(for ids: [CKRecord.ID], desiredKeys: [CKRecord.FieldKey]? = nil) async throws -> [CKRecord.ID: CKRecord] {
        let results = try await database.records(for: ids, desiredKeys: desiredKeys)
        return try processResults(results)
    }
    
    private func processResults<T>(_ results: [CKRecord.ID: Result<T, Error>]) throws -> [CKRecord.ID: T] {
        var processedResults = [CKRecord.ID: T]()
        for (id, result) in results {
            switch result {
            case .success(let value):
                processedResults[id] = value
            case .failure(let error):
                throw error
            }
        }
        return processedResults
    }
    
    // Completion handler version
    func records(withRecordIDs recordIDs: [CKRecord.ID], desiredKeys: [CKRecord.FieldKey]? = nil, completionHandler: @escaping (Result<[CKRecord.ID: CKRecord], Error>) -> Void) {
        database.fetch(withRecordIDs: recordIDs, desiredKeys: desiredKeys) { result in
            switch result {
            case .success(let recordResults):
                var records = [CKRecord.ID: CKRecord]()
                for (id, result) in recordResults {
                    switch result {
                    case .success(let record):
                        records[id] = record
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                completionHandler(.success(records))
            case .failure(let error):
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    // MARK: - Fetch Single Record
    
    // Async version
    
    func findRecord(for recordID: CKRecord.ID) async throws -> CKRecord {
        return try await database.record(for: recordID)
    }
    
    // Completion handler version
    func findRecord(withRecordID recordID: CKRecord.ID, completionHandler: @escaping (Result<CKRecord, Error>) -> Void) {
        database.fetch(withRecordID: recordID) { record, error in
            if let record = record {
                completionHandler(.success(record))
            } else if let error = error {
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    // MARK: - Querying Records (Async)
    
    func findRecords(matching query: CKQuery, inZoneWith zoneID: CKRecordZone.ID? = nil, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        let (matchResults, queryCursor) = try await database.records(matching: query, inZoneWith: zoneID, desiredKeys: desiredKeys, resultsLimit: resultsLimit)
        var records = [CKRecord]()
        for (id, result) in matchResults {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                throw error
            }
        }
        return (records, queryCursor)
    }
    
    func findRecords(continuingMatchFrom queryCursor: CKQueryOperation.Cursor, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        let (matchResults, nextCursor) = try await database.records(continuingMatchFrom: queryCursor, desiredKeys: desiredKeys, resultsLimit: resultsLimit)
        var records = [CKRecord]()
        for (id, result) in matchResults {
            switch result {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                throw error
            }
        }
        return (records, nextCursor)
    }
    
    // MARK: - Querying Records (Completion Handler)
    
    func fetch(withQuery query: CKQuery, inZoneWith zoneID: CKRecordZone.ID? = nil, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults, completionHandler: @escaping (Result<([CKRecord], CKQueryOperation.Cursor?), Error>) -> Void) {
        database.fetch(withQuery: query, inZoneWith: zoneID, desiredKeys: desiredKeys, resultsLimit: resultsLimit) { result in
            switch result {
            case .success(let (matchResults, queryCursor)):
                var records = [CKRecord]()
                for (id, result) in matchResults {
                    switch result {
                    case .success(let record):
                        records.append(record)
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                completionHandler(.success((records, queryCursor)))
            case .failure(let error):
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    func fetch(withCursor queryCursor: CKQueryOperation.Cursor, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults, completionHandler: @escaping (Result<([CKRecord], CKQueryOperation.Cursor?), Error>) -> Void) {
        database.fetch(withCursor: queryCursor, desiredKeys: desiredKeys, resultsLimit: resultsLimit) { result in
            switch result {
            case .success(let (matchResults, nextCursor)):
                var records = [CKRecord]()
                for (id, result) in matchResults {
                    switch result {
                    case .success(let record):
                        records.append(record)
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                completionHandler(.success((records, nextCursor)))
            case .failure(let error):
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    // MARK: - Modifying Records (Async)
    
    func saveRecord(saving recordToSave: CKRecord) async throws -> CKRecord {
        let (saveResults, _) = try await modifyRecords(saving: [recordToSave], deleting: [], savePolicy: .ifServerRecordUnchanged, atomically: true)
        
        if let savedRecord = saveResults.values.first {
            return savedRecord
        } else {
            throw NSError(domain: "CloudKitManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to save the record."])
        }
    }
    
    func deleteRecord(deleting recordIDToDelete: CKRecord.ID) async throws {
        let (_, deleteResults) = try await modifyRecords(saving: [], deleting: [recordIDToDelete], savePolicy: .ifServerRecordUnchanged, atomically: true)
        
        guard deleteResults.keys.contains(recordIDToDelete) else {
            throw NSError(domain: "CloudKitManager", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to confirm the deletion of the record."])
        }
        // If no error was thrown, the deletion can be considered successful.
    }
    
    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID], savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged, atomically: Bool = true) async throws -> (saveResults: [CKRecord.ID: CKRecord], deleteResults: [CKRecord.ID: Void]) {
        let (saveResults, deleteResults) = try await database.modifyRecords(saving: recordsToSave, deleting: recordIDsToDelete, savePolicy: savePolicy, atomically: atomically)
        
        let savedRecords = try processResults(saveResults)
        let deletedRecordIDs = try processResults(deleteResults) as [CKRecord.ID: Void]
        
        return (saveResults: savedRecords, deleteResults: deletedRecordIDs)
    }
    
    // MARK: - Modifying Records (Completion Handler)
    
    func saveRecord(saving recordToSave: CKRecord, completionHandler: @escaping (Result<CKRecord, Error>) -> Void) {
        modifyRecords(saving: [recordToSave], deleting: [], savePolicy: .ifServerRecordUnchanged, atomically: true) { result in
            switch result {
            case .success((let saveResults, _)):
                if let savedRecordID = saveResults.keys.first, let savedRecord = saveResults[savedRecordID] {
                    completionHandler(.success(savedRecord))
                } else {
                    completionHandler(.failure(NSError(domain: "CloudKitManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to save the record."])))
                }
            case .failure(let error):
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }

    
    func modifyRecords(saving recordsToSave: [CKRecord], deleting recordIDsToDelete: [CKRecord.ID], savePolicy: CKModifyRecordsOperation.RecordSavePolicy = .ifServerRecordUnchanged, atomically: Bool = true, completionHandler: @escaping (Result<(saveResults: [CKRecord.ID: CKRecord], deleteResults: [CKRecord.ID: Void]), Error>) -> Void) {
        database.modifyRecords(saving: recordsToSave, deleting: recordIDsToDelete, savePolicy: savePolicy, atomically: atomically) { result in
            switch result {
            case .success(let (saveResults, deleteResults)):
                var savedRecords = [CKRecord.ID: CKRecord]()
                var deletedRecordIDs = [CKRecord.ID: Void]()
                
                for (id, result) in saveResults {
                    switch result {
                    case .success(let record):
                        savedRecords[id] = record
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                
                for (id, result) in deleteResults {
                    switch result {
                    case .success:
                        deletedRecordIDs[id] = ()
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                
                completionHandler(.success((saveResults: savedRecords, deleteResults: deletedRecordIDs)))
            case .failure(let error):
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    // MARK: Fetching Specific Subscriptions (Async)
    
    func fetchSubscriptions(for ids: [CKSubscription.ID]) async throws -> [CKSubscription] {
        let results = try await database.subscriptions(for: ids)
        var subscriptions = [CKSubscription]()
        for (_, result) in results {
            switch result {
            case .success(let subscription):
                subscriptions.append(subscription)
            case .failure(let error):
                throw error
            }
        }
        return subscriptions
    }
    
    func fetchSubscription(for subscriptionID: CKSubscription.ID) async throws -> CKSubscription {
        return try await database.subscription(for: subscriptionID)
    }
    
    // MARK: Fetching Specific Subscriptions (Completion Handler)
    
    func fetchSubscriptions(withSubscriptionIDs subscriptionIDs: [CKSubscription.ID], completionHandler: @escaping (Result<[CKSubscription], Error>) -> Void) {
        database.fetch(withSubscriptionIDs: subscriptionIDs) { result in
            switch result {
            case .success(let subscriptionResults):
                var subscriptions = [CKSubscription]()
                for (_, result) in subscriptionResults {
                    switch result {
                    case .success(let subscription):
                        subscriptions.append(subscription)
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                completionHandler(.success(subscriptions))
            case .failure(let error):
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    func fetchSubscription(withSubscriptionID subscriptionID: CKSubscription.ID, completionHandler: @escaping (Result<CKSubscription, Error>) -> Void) {
        database.fetch(withSubscriptionID: subscriptionID) { subscription, error in
            if let subscription = subscription {
                completionHandler(.success(subscription))
            } else if let error = error {
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    // MARK: Fetching All Subscriptions (Async & Completion Handler)
    
    func allSubscriptions() async throws -> [CKSubscription] {
        return try await database.allSubscriptions()
    }
    
    func fetchAllSubscriptions(completionHandler: @escaping (Result<[CKSubscription], Error>) -> Void) {
        database.fetchAllSubscriptions { subscriptions, error in
            if let subscriptions = subscriptions {
                completionHandler(.success(subscriptions))
            } else if let error = error {
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    // MARK: - Saving Subscription (Async)
    
    func saveSubscription(saving subscriptionToSave: CKSubscription) async throws -> CKSubscription {
        let (subscriptionResults, _) = try await modifySubscriptions(saving: [subscriptionToSave], deleting: [])
        
        if let subscriptionResult = subscriptionResults.first {
            return subscriptionResult
        } else {
            throw NSError(domain: "CloudKitManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to subscribe."])
        }
    }
    
    // MARK: - Modifying Subscriptions (Async)
    
    func modifySubscriptions(saving subscriptionsToSave: [CKSubscription], deleting subscriptionIDsToDelete: [CKSubscription.ID]) async throws -> (saved: [CKSubscription], deleted: [CKSubscription.ID]) {
        let (saveResults, deleteResults) = try await database.modifySubscriptions(saving: subscriptionsToSave, deleting: subscriptionIDsToDelete)
        
        var savedSubscriptions = [CKSubscription]()
        for (_, result) in saveResults {
            switch result {
            case .success(let subscription):
                savedSubscriptions.append(subscription)
            case .failure(let error):
                throw error
            }
        }
        
        var deletedSubscriptionIDs = [CKSubscription.ID]()
        for (id, result) in deleteResults {
            switch result {
            case .success:
                deletedSubscriptionIDs.append(id)
            case .failure(let error):
                throw error
            }
        }
        
        return (saved: savedSubscriptions, deleted: deletedSubscriptionIDs)
    }
    
    // MARK: - Modifying Subscriptions (Completion Handler)
    
    func modifySubscriptions(saving subscriptionsToSave: [CKSubscription], deleting subscriptionIDsToDelete: [CKSubscription.ID], completionHandler: @escaping (Result<(saved: [CKSubscription], deleted: [CKSubscription.ID]), Error>) -> Void) {
        database.modifySubscriptions(saving: subscriptionsToSave, deleting: subscriptionIDsToDelete) { result in
            switch result {
            case .success(let (saveResults, deleteResults)):
                var savedSubscriptions = [CKSubscription]()
                var deletedSubscriptionIDs = [CKSubscription.ID]()
                
                for (_, result) in saveResults {
                    switch result {
                    case .success(let subscription):
                        savedSubscriptions.append(subscription)
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                
                for (id, result) in deleteResults {
                    switch result {
                    case .success:
                        deletedSubscriptionIDs.append(id)
                    case .failure(let error):
                        completionHandler(.failure(self.handleError(error)))
                        return
                    }
                }
                
                completionHandler(.success((saved: savedSubscriptions, deleted: deletedSubscriptionIDs)))
            case .failure(let error):
                completionHandler(.failure(self.handleError(error)))
            }
        }
    }
    
    private func handleError(_ error: Error) -> Error {
        // Log error, transform it, or handle specific error cases
        print(error.localizedDescription)
        return error
    }
}

