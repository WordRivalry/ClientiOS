//
//  MockCloudKitManager.swift
//  Word RivalryTests
//
//  Created by benoit barbier on 2024-05-06.
//

import Foundation
import CloudKit
@testable import Word_Rivalry

class MockCloudKitManager: CloudKitManageable {

    
    // Storage for models, using type name as key and array of models as value
    var storage: [String: [any CKModel]] = [:]

    // Ability to force failures for testing error handling
    var shouldReturnFailure: Bool = false
    var failureError: Error = NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Forced error for testing"])

    func isUnique<T: CKModel>(type: T.Type, by key: T.Key, value: String) async throws -> Bool {
        if shouldReturnFailure {
            throw failureError
        }
        
        let models = storage[String(describing: type)] as? [T] ?? []
        let unique = !models.contains { $0.record[key.rawValue] as? String == value }
        return unique
    }

    func getICloudAccountStatus() async throws -> CKAccountStatus {
        if shouldReturnFailure {
            throw failureError
        }
        return .available  // Return .available as default mock status
    }

    func userRecord<T: CKModel>() async throws -> T {
        if shouldReturnFailure {
            throw failureError
        }
        guard let model = storage[String(describing: T.self)]?.first as? T else {
            throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No user record found"])
        }
        return model
    }

    func userRecordID() async throws -> CKRecord.ID {
        if shouldReturnFailure {
            throw failureError
        }
        return CKRecord.ID(recordName: "mockUserRecordID")
    }

    func fetchModelsByRecordName<T: CKModel>(for recordNames: [String]) async throws -> [T] {
        if shouldReturnFailure {
            throw failureError
        }
        let models = recordNames.compactMap { recordName in
            storage[String(describing: T.self)]?.first { $0.record.recordID.recordName == recordName } as? T
        }
        return models
    }

    func fetchSortedModels<T: CKModel>(for key: T.Key, ascending: Bool, limit: Int) async throws -> [T] {
        if shouldReturnFailure {
            throw failureError
        }
        let sortedModels = (storage[String(describing: T.self)] as? [T] ?? [])
            .prefix(limit)
        return Array(sortedModels)
    }

    func queryModel<T: CKModel>(by key: T.Key, value: String) async throws -> T {
        if shouldReturnFailure {
            throw failureError
        }
        guard let model = (storage[String(describing: T.self)] as? [T])?.first(where: { $0.record[key.rawValue] as? String == value }) else {
            throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Model not found"])
        }
        return model
    }
    
    func queryModels<T: CKModel>(by key: T.Key, values: [String]) async throws -> [T] {
        if shouldReturnFailure {
            throw failureError
        }

        // Use a flatMap to iterate over all values and concatenate results of each value query up to the results limit.
        let models = values.flatMap { value -> [T] in
            let filteredModels = (storage[String(describing: T.self)] as? [T] ?? [])
                .filter { $0.record[key.rawValue] as? String == value }
            return Array(filteredModels)
        }

        // You can apply another limit here if the total results should be limited
        return Array(models)
    }


    func queryModels<T: CKModel>(for key: T.Key, value: String, resultsLimit: Int) async throws -> [T] {
        if shouldReturnFailure {
            throw failureError
        }
        let models = (storage[String(describing: T.self)] as? [T] ?? [])
            .filter { $0.record[key.rawValue] as? String == value }
            .prefix(resultsLimit)
        return Array(models)
    }

    func saveModel<T: CKModel>(saving model: T) async throws -> T {
        if shouldReturnFailure {
            throw failureError
        }
        var models = storage[String(describing: T.self)] as? [T] ?? []
        models.append(model)
        storage[String(describing: T.self)] = models
        return model
    }

    func deleteModel<T: CKModel>(deleting model: T) async throws -> CKRecord.ID {
        if shouldReturnFailure {
            throw failureError
        }
        var models = storage[String(describing: T.self)] as? [T] ?? []
        models.removeAll { $0.record.recordID == model.record.recordID }
        storage[String(describing: T.self)] = models
        return model.record.recordID
    }

    // Subscription methods throwing mock errors
    func subscribeToModelUpdates<T: CKModel>(model: T, desiredKeys: [T.Key]) async throws {
        if shouldReturnFailure {
            throw failureError
        }
    }
}
