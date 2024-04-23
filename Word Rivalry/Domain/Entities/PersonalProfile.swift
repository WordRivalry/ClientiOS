//
//  PersonalProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-14.
//

import Foundation
import CloudKit
import os.log

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the Personal Profile events from the app
    static let personalProfile = Logger(subsystem: subsystem, category: "PersonalProfile")
}

// MARK: PersonalProfile
@Observable final class PersonalProfile: CKModel, DataPreview {
    
    var currency: Int = 0
    
    init(
        currency: Int,
        recordID: CKRecord.ID = CKRecord.ID(recordName: "RandomRecordName")
    ) {
        self.currency = currency
        self.recordID = recordID
        Logger.personalProfile.debug("Personal Profile instanciated")
    }
    
    // MARK: CKModel
    
    static var recordType: String {
        "Users"
    }
    
    var recordID: CKRecord.ID

    convenience init?(from ckRecord: CKRecord) {
        guard let currency = ckRecord[PersonalProfile.forKey(.currency)] as? Int else {
            return nil
        }
        
        self.init(
            currency: currency,
            recordID: ckRecord.recordID
        )
    }

    var record: CKRecord {
        let record = CKRecord(recordType: PersonalProfile.recordType)
        record[PersonalProfile.forKey(.currency)] = currency
        return record
    }
    
    // Public field
    enum Key: String, CaseIterable {
        case currency
    }
    
    // Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
    
    // MARK: PrewiewData

    static var preview: PersonalProfile = PersonalProfile(currency: 233)
}
