//
//  PrivateDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-13.
//

import Foundation
import CloudKit
import os.log

class PrivateDatabase {
    
    static let shared = PrivateDatabase()
    let logger = Logger(subsystem: "CloudKit", category: "PrivateDatabase")
    
    let CKManager = ModelToCloudkit(
        containerIdentifier: "iCloud.WordRivalryContainer",
        databaseScope: .private)
    
    private init() {}
}
