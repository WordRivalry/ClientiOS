//
//  DataSource.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-31.
//

import Foundation
import SwiftData
import os.log

//final class SwiftDataSource {
//    var isReady: Bool = false
//    
//    private var modelContainer: ModelContainer
//    private let modelContext: ModelContext
//    private let logger = Logger(subsystem: "SwiftData", category: "DataSource")
//
//    @MainActor
//    static let shared = SwiftDataSource()
//
//    @MainActor
//    init() {
//        self.modelContainer = try! ModelContainer(
//            for: MatchRecord.self,
//            configurations: ModelConfiguration(cloudKitDatabase: .private("iCloud.WordRivalryContainer"))
//        )
//        self.modelContext = modelContainer.mainContext
//        self.isReady = true
//    }
//    
//    func save() {
//        do {
//            try modelContext.save()
//            logger.debug("Context saved")
//        } catch {
//            handleError(error)
//        }
//    }
//
//    func append<T: PersistentModel>(_ entity: T) {
//        modelContext.insert(entity)
//        save()
//    }
//
//    func fetch<T: PersistentModel>(type: T.Type) -> [T] {
//        do {
//            let result = try modelContext.fetch(FetchDescriptor<T>())
//            return result
//        } catch {
//            handleError(error)
//            return []
//        }
//    }
//
//    func remove<T: PersistentModel>(_ entity: T) {
//        modelContext.delete(entity)
//        save()
//    }
//    
//    // MARK: - Error Handling
//    
//    private func handleError(_ error: Error) {
//        logger.error("\(error.localizedDescription)")
//    }
//}
