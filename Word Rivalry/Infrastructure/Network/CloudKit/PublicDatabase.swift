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
    var db: CloudKitManageable
    static let shared: PublicDatabase = PublicDatabase()
    
    private init() {
        self.db = ModelToCloudkit(
            containerIdentifier: "iCloud.WordRivalryContainer",
            databaseScope: .public)
    }
}
