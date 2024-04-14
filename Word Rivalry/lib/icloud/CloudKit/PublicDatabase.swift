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
    
    static let shared = PublicDatabase()
    let logger = Logger(subsystem: "CloudKit", category: "PublicDatabase")
    
    let CKManager = CloudKitManager(
        containerIdentifier: "iCloud.WordRivalryContainer",
        databaseScope: .public)
    
    private init() {}
}
