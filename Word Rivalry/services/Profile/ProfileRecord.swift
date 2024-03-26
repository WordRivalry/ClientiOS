//
//  UserProfilRecord.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit
import SwiftUI

struct ProfilRecordKey {
    
    // Record name
    static let privateUserInfoRecordType = "PrivateUserInfo"
    static let publicUserInfoRecordType = "PublicUserInfo"
    
    // Record field
    static let playerName = "username"
    static let uuid = "uuid"
    static let eloRating = "eloRating"
    static let friendsUUIDs = "friendsUUIDs"
    
}

struct Profil {
    var recordId: CKRecord.ID?
    let uuid: String
    let playerName: String
    let eloRating: Int
    var friendsUUIDs: [String]
}

extension Profil {
    var privateRecord: CKRecord {
        let record = recordId != nil ? CKRecord(recordType: ProfilRecordKey.privateUserInfoRecordType, recordID: recordId!) : CKRecord(recordType: ProfilRecordKey.privateUserInfoRecordType)
        record[ProfilRecordKey.uuid] = uuid
        record[ProfilRecordKey.playerName] = playerName
        record[ProfilRecordKey.friendsUUIDs] = friendsUUIDs
        return record
    }
    
    var publicRecord: CKRecord {
        let record = CKRecord(recordType: ProfilRecordKey.publicUserInfoRecordType)
        record[ProfilRecordKey.uuid] = uuid
        record[ProfilRecordKey.eloRating] = eloRating
        record[ProfilRecordKey.playerName] = playerName
        return record
    }
}

