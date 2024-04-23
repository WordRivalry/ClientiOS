//
//  CKPublicDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit
import os.log

class PublicDatabase {
    let db: ModelToCloudkit
    static let shared: PublicDatabase = PublicDatabase()
    
    private init() {
        guard let containerIdentifier = ProcessInfo.processInfo.environment["CONTAINER_IDENTIFIER"] else {
            fatalError("Container Identifier not set in environment")
        }
        
        self.db = ModelToCloudkit(
            containerIdentifier: containerIdentifier,
            databaseScope: .public
        )
    }
}
