//
//  PrivateDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-13.
//

import Foundation
import CloudKit
import os.log

//class PrivateDatabase {
//    
//    static let shared = PrivateDatabase()
//    let logger = Logger(subsystem: "CloudKit", category: "PrivateDatabase")
//    
//    let CKManager = ModelToCloudkit(
//        containerIdentifier: "iCloud.WordRivalryContainer",
//        databaseScope: .private)
//                                                                                                      
//    private init() {}
//}

class PrivateDatabase {
    let db: ModelToCloudkit
    static let shared: PrivateDatabase = PrivateDatabase()
    
    private init() {
        guard let containerIdentifier = ProcessInfo.processInfo.environment["CONTAINER_IDENTIFIER"] else {
            fatalError("Container Identifier not set in environment")
        }
        
        self.db = ModelToCloudkit(
            containerIdentifier: containerIdentifier,
            databaseScope: .private
        )
    }
}
