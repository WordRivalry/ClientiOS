//
//  CloudKitManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit
import OSLog

enum ModelError: Error {
    case invalidDataType
    case ckRecordConversionFailed
    case modelNotFound
    case multipleModelFoundWhenItShouldBeOne
}

enum isModelErrorStatus: Error {
    case yes(ModelError)
    case no
}

extension Error {
    func isModelError() -> isModelErrorStatus {
        guard let modelError = self as? ModelError else { return .no }
        return .yes(modelError)
    }
}

enum isCKErrorStatus {
    case yes(CKError)
    case no
}

extension Error {
    func isCKError() -> isCKErrorStatus {
        guard let ckError = self as? CKError else { return .no }
        return .yes(ckError)
    }
}

protocol CloudKitManageable {
    
    func isUnique<T: CKModel>(
        type: T.Type,
        by key: T.Key,
        value: String
    ) async throws -> Bool
    
    func getICloudAccountStatus() async throws -> CKAccountStatus
    func userRecord<T: CKModel>() async throws -> T
    func userRecordID() async throws -> CKRecord.ID
    
    func fetchModelsByRecordName<T: CKModel>(
        for recordNames: [String]
    ) async throws -> [T]
    
    func fetchSortedModels<T: CKModel>(
        for key: T.Key,
        ascending: Bool,
        limit: Int
    ) async throws -> [T]
    
    func queryModel<T: CKModel>(
        by key: T.Key,
        value: String
    ) async throws -> T
    
    func queryModels<T: CKModel>(
        by key: T.Key,
        values: [String]
    ) async throws -> [T]

    func queryModels<T: CKModel>(
        for key: T.Key,
        value: String,
        resultsLimit: Int
    ) async throws -> [T]
    
    func saveModel<T: CKModel>(
        saving model: T
    ) async throws -> T
    
    func deleteModel<T: CKModel>(
        deleting model: T
    ) async throws -> CKRecord.ID
    
    func subscribeToModelUpdates<T: CKModel>(
        model: T,
        desiredKeys: [T.Key]
    ) async throws -> Void
    
//    func fetchSubscriptions(
//        for ids: [CKSubscription.ID]
//    ) async throws -> [CKSubscription]
//    
//    func fetchSubscription(
//        for subscriptionID: CKSubscription.ID
//    ) async throws -> CKSubscription
//    
//    func allSubscriptions() async throws -> [CKSubscription]
}

class ModelToCloudkit: CloudKitManageable {
    
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
    
    // MARK: Metal
    
    func validateUnicity<T: CKModel>(for models: [T]) throws -> T {
        guard let model = models.first else { throw ModelError.modelNotFound }
        guard models.count == 1 else { throw ModelError.multipleModelFoundWhenItShouldBeOne }
        return model
    }
    
    /// Checks if a record value for a specified key is already taken in the database.
    /// - Parameters:
    ///   - key: The key within the model to check.
    ///   - value: The value to check for.
    /// - Returns: Boolean indicating whether the value is already taken.
    /// - Throws: Error if the fetch fails.
    func isUnique<T: CKModel>(type: T.Type, by key: T.Key, value: String) async throws -> Bool {
        let predicate = NSPredicate(format: "%K == %@", T.forKey(key), value)
        let records: [T] = try await findModels(using: predicate)
        let isUnique = records.isEmpty
        
        guard isUnique == true else {
            return true
        }
        
        return false
    }
    
    // MARK: - Icloud Accout
    
    func getICloudAccountStatus() async throws -> CKAccountStatus {
        let ret = try await self.container.accountStatus()
        return ret
    }
    
    // MARK: - UserRecord
    
    func userRecordID() async throws -> CKRecord.ID {
        let ret = try await container.userRecordID()
        return ret
    }
    
    /// Fetches the user's record and initializes it as an object of type `T`.
    func userRecord<T: CKModel>() async throws -> T {
        let recordID = try await userRecordID()
        return try await fetchModel(for: recordID)
    }
    
    func isUserNew() async throws -> Bool {
        let userRecordID = try await userRecordID()
        let ckRecord = try await database.record(for: userRecordID)
        
        let creationDate = ckRecord.creationDate
        let modificationDate = ckRecord.modificationDate
        
        // Check if the record has been modified by comparing the creation and modification dates
        if creationDate == modificationDate {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Fetch Records
    
    func fetchModelsByRecordName<T: CKModel>(for recordNames: [String]) async throws -> [T] {
        let recordIDs = recordNames.map { recordName in
            return CKRecord.ID(recordName: recordName)
        }
        return try await fetchModels(for: recordIDs)
    }
    
    func fetchSortedModels<T: CKModel>(for key: T.Key, ascending: Bool, limit: Int) async throws -> [T] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: T.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: T.forKey(key), ascending: ascending)]
        return try await findModels(matching: query, resultsLimit: limit)
    }
    
    /// Fetches multiple CKRecord objects of a specified type.
    /// - Parameters:
    ///   - ids: Array of CKRecord.ID to fetch.
    ///   - desiredKeys: Optional specific fields to fetch; nil fetches all fields.
    /// - Returns: An array of initialized objects of the specified CKModel type.
    private func fetchModels<T: CKModel>(for ids: [CKRecord.ID], desiredKeys: [CKRecord.FieldKey]? = nil) async throws -> [T] {
        let results = try await database.records(for: ids, desiredKeys: desiredKeys)
        let processedResults = try processResults(results, for: T.self)
        return processedResults
    }
    
    /// Processes the results of a CloudKit fetch operation using the CloudKitHelper class.
    /// - Parameters:
    ///   - results: A dictionary mapping CKRecord.ID to Result containing CKRecord or Error.
    ///   - type: The type of CKModel to process.
    /// - Returns: An array of initialized CKModel objects.
    /// - Throws: An error if any record fails to load or initialize.
    private func processResults<T: CKModel>(_ results: [CKRecord.ID: Result<CKRecord, Error>], for type: T.Type) throws -> [T] {
        var processedResults = [T]()
        for (_, result) in results {
            switch result {
            case .success(let record):
                try processedResults.append(self.convert(record: record, to: T.self))
            case .failure(let error):
                throw error
            }
        }
        return processedResults
    }
    
    
    // MARK: - Fetch Single Record
    
    func fetchModelByRecordName<T: CKModel>(with recordName: String) async throws -> T {
        let recordID = CKRecord.ID(recordName: recordName)
        return try await fetchModel(for: recordID)
    }
    
    /// Finds and converts a record by its identifier to a specified CKModel type.
    /// - Parameters:
    ///   - recordID: The CKRecord.ID of the record to fetch.
    /// - Returns: The specific CKModel type fetched and initialized from the database.
    private func fetchModel<T: CKModel>(for recordID: CKRecord.ID) async throws -> T {
        let ckRecord = try await database.record(for: recordID)
        return try self.convert(record: ckRecord, to: T.self)
    }
    
    // MARK: - Querying Records
    
    
    func queryModels<T: CKModel>(
        by key: T.Key,
        values: [String]
    ) async throws -> [T] {
        let predicate = NSPredicate(format: "%K IN %@", T.forKey(key), values)
        return try await findModels(using: predicate)
    }
    
    func queryModel<T: CKModel>(by key: T.Key, value: String) async throws -> T {
        let ret: [T] = try await queryModels(for: key, value: value, resultsLimit: 1)
        if let singleModel = ret.first {
            return singleModel
        } else {
            throw ModelError.modelNotFound
        }
    }
    
    func queryModelUserReference<T: CKModel>(by userRecordName: String) async throws -> T {
        // Create the UserRecordID
        let userRecordID = CKRecord.ID(recordName: userRecordName)
        
        // Creating a reference to the user record
        let userReference = CKRecord.Reference(recordID: userRecordID, action: .none)
        
        // Predicate to compare reference against the creatorUserRecordID field
        let predicate = NSPredicate(format: "creatorUserRecordID == %@", userReference)
        
        let ret: [T] = try await findModels(using: predicate, resultsLimit: 1)
        if let singleModel = ret.first {
            return singleModel
        } else {
            throw ModelError.modelNotFound
        }
    }
    
    func queryModelUserReference<T: CKModel>(by userRecordID: CKRecord.ID) async throws -> T {
        // Creating a reference to the user record
        let userReference = CKRecord.Reference(recordID: userRecordID, action: .none)
        
        // Predicate to compare reference against the creatorUserRecordID field
        let predicate = NSPredicate(format: "creatorUserRecordID == %@", userReference)
        
        let ret: [T] = try await findModels(using: predicate, resultsLimit: 1)
        if let singleModel = ret.first {
            return singleModel
        } else {
            throw ModelError.modelNotFound
        }
    }
    
    func queryModels<T: CKModel>(for key: T.Key, value: String, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> [T] {
        let predicate = NSPredicate(format: "%K == %@", T.forKey(key), value)
        return try await findModels(using: predicate, resultsLimit: resultsLimit)
    }
    
    private func findModels<T: CKModel>(using predicate: NSPredicate, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> [T] {
        
        let query = CKQuery(recordType: T.recordType, predicate: predicate)
        return try await findModels(matching: query, resultsLimit: resultsLimit)
    }
    
    /// Finds records matching a CloudKit query and converts them to a specified CKModel type.
    /// - Parameters:
    ///   - query: The CloudKit query to execute.
    ///   - zoneID: Optional specific zone to query within.
    ///   - desiredKeys: Optional specific fields to fetch; nil fetches all fields.
    ///   - resultsLimit: The maximum number of results to return.
    /// - Returns: An array of CKModel objects and an optional cursor for further queries.
    private func findModels<T: CKModel>(matching query: CKQuery, inZoneWith zoneID: CKRecordZone.ID? = nil, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> ([T], CKQueryOperation.Cursor?) {
        let (matchResults, queryCursor) = try await database.records(matching: query, inZoneWith: zoneID, desiredKeys: desiredKeys, resultsLimit: resultsLimit)
        var models = [T]()
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                try models.append(self.convert(record: record, to: T.self))
            case .failure(let error):
                throw error
            }
        }
        return (models, queryCursor)
    }
    
    /// Finds records matching a CloudKit query and converts them to a specified CKModel type.
    /// - Parameters:
    ///   - query: The CloudKit query to execute.
    ///   - zoneID: Optional specific zone to query within.
    ///   - desiredKeys: Optional specific fields to fetch; nil fetches all fields.
    ///   - resultsLimit: The maximum number of results to return.
    /// - Returns: An array of CKModel objects and an optional cursor for further queries.
    private func findModels<T: CKModel>(matching query: CKQuery, inZoneWith zoneID: CKRecordZone.ID? = nil, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> [T] {
        let (matchResults, queryCursor) = try await database.records(matching: query, inZoneWith: zoneID, desiredKeys: desiredKeys, resultsLimit: resultsLimit)
        var models = [T]()
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                try models.append(self.convert(record: record, to: T.self))
            case .failure(let error):
                throw error
            }
        }
        return models
    }
    
    /// Continues finding records from a previous query and converts them to a specified CKModel type.
    /// - Parameters:
    ///   - queryCursor: The cursor from a previous query to continue from.
    ///   - desiredKeys: Optional specific fields to fetch; nil fetches all fields.
    ///   - resultsLimit: The maximum number of results to return.
    /// - Returns: An array of CKModel objects and an optional cursor for further queries.
    func findModels<T: CKModel>(continuingMatchFrom queryCursor: CKQueryOperation.Cursor, desiredKeys: [CKRecord.FieldKey]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults) async throws -> ([T], CKQueryOperation.Cursor?) {
        let (matchResults, nextCursor) = try await database.records(continuingMatchFrom: queryCursor, desiredKeys: desiredKeys, resultsLimit: resultsLimit)
        var models = [T]()
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                try models.append(self.convert(record: record, to: T.self))
            case .failure(let error):
                throw error
            }
        }
        return (models, nextCursor)
    }
    
    // MARK: - Modifying Records
    
    /// Saves a CKModel instance to the CloudKit database and returns the updated model.
    /// This method first saves the CKRecord representation of the model to the database
    /// and then converts the returned CKRecord (which includes any modifications made by
    /// the database during the save operation, such as timestamp updates) back to the model type.
    /// - Parameter model: The model to save, which conforms to the CKModel protocol.
    /// - Returns: An updated instance of the model of type T.
    /// - Throws: An error if the save operation or model conversion fails.
    func saveModel<T: CKModel>(saving model: T) async throws -> T {
        let ret = try await database.save(model.record)
        // Convert the saved CKRecord back to the model type to reflect any changes made by the database.
        return try self.convert(record: ret, to: T.self)
    }
    
    /// Attempts to convert a CKRecord to a specified CKModel type.
    /// - Parameters:
    ///   - record: The CKRecord to convert.
    ///   - type: The type of CKModel to convert to.
    /// - Returns: An initialized object of type T.
    /// - Throws: An error if conversion fails.
    private func convert<T: CKModel>(record: CKRecord, to type: T.Type) throws -> T {
        guard let model = T(from: record) else {
            Logger.cloudKit.error("Failed to initialize \(T.self) from CKRecord.")
            throw ModelError.ckRecordConversionFailed
        }
        return model
    }
    
    /// Deletes a CKModel instance from the CloudKit database and returns the identifier of the deleted record.
    /// This function asynchronously deletes the record associated with the model from the database
    /// and logs the operation.
    /// - Parameter model: The model to delete, which conforms to the CKModel protocol.
    /// - Returns: The CKRecord.ID of the deleted record.
    /// - Throws: An error if the delete operation fails.
    func deleteModel<T: CKModel>(deleting model: T) async throws -> CKRecord.ID {
        let recordID = self.buildRecordID(model: model)
        let ret = try await database.deleteRecord(withID: recordID)
        return ret
    }
    
    // MARK: Fetching Specific Subscriptions
    
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
    
    // MARK: Fetching All Subscriptions
    
    func allSubscriptions() async throws -> [CKSubscription] {
        return try await database.allSubscriptions()
    }
    
    // MARK: - Saving Subscription
    
    /// Creates a subscription for changes on a CloudKit record type.
    /// - Parameters:
    ///   - recordType: The record type to subscribe to.
    ///   - predicate: The NSPredicate to filter changes.
    ///   - subscriptionID: A unique identifier for the subscription.
    /// - Throws: An error if the subscription fails.
    func subscribeToModelUpdates<T: CKModel>(model: T, desiredKeys: [T.Key] = []) async throws {
        
        // Validate the number of desired keys.
        guard desiredKeys.count <= 3 else {
            throw NSError(
                domain: "DatabaseError",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Too many keys requested"]
            )
        }
        
        let subscriptionID = "\(T.recordType)-onUpdateOf-\(model.recordName)"
        
        // Check if the subscription has already been registered.
        guard !UserDefaults.standard.bool(forKey: subscriptionID) else { return }
        
        Logger.dataServices.info("Registering subscription to changes in \(model.recordName)")
        
        let recordID = self.buildRecordID(model: model)
        let predicate = NSPredicate(format: "%K == %@", "recordID", recordID)
        Logger.dataServices.debug("Creating subscription with recordName: \(model.recordName)")
        
        let subscription = CKQuerySubscription(
            recordType: T.recordType,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        // Set desired keys based on input or nil if empty
        notificationInfo.desiredKeys = desiredKeys.isEmpty ? nil : desiredKeys.map { $0.rawValue }
        
        subscription.notificationInfo = notificationInfo
        
        do {
            _ = try await saveSubscription(saving: subscription)
        } catch {
            Logger.cloudKit.error("Subscription for \(T.recordType) updates failed :\n\(error)")
            return
        }
        
        // Mark the subscription as created in UserDefaults.
        UserDefaults.standard.set(true, forKey: subscriptionID)
        Logger.dataServices.debug("Subscription for \(T.recordType) updates registered")
    }
    
    private func saveSubscription(saving subscriptionToSave: CKSubscription) async throws -> CKSubscription {
        let (subscriptionResults, _) = try await modifySubscriptions(saving: [subscriptionToSave], deleting: [])
        
        if let subscriptionResult = subscriptionResults.first {
            return subscriptionResult
        } else {
            throw NSError(domain: "CloudKitManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to subscribe."])
        }
    }
    
    // MARK: - Modifying Subscriptions
    
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
    
    private func buildRecordID<T: CKModel>(model: T) -> CKRecord.ID {
        let zoneID = CKRecordZone.ID(zoneName: model.zoneName)
        let recordID = CKRecord.ID(recordName: model.recordName, zoneID: zoneID)
        return recordID
    }
    
    private func handleError(_ error: Error) -> Error {
        // Log error, transform it, or handle specific error cases
        print(error.localizedDescription)
        return error
    }
}
