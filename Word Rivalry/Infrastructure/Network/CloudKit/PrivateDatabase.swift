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
    let db: CloudKitManageable
    static let shared: PrivateDatabase = PrivateDatabase()
    
    private init() {
        self.db = ModelToCloudkit(
            containerIdentifier: "iCloud.WordRivalryContainer",
            databaseScope: .private)
    }
}
