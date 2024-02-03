//
//  UserProfilRecord.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit

struct ProfilRecordKey {
    
    // Record name
    static let privateUserInfoRecordType = "PrivateUserInfo"
    static let publicUserInfoRecordType = "PublicUserInfo"
    
    // Record field
    static let username = "username"
    static let uuid = "uuid"
    static let themePreference = "themePreference"
    static let hapticPreference = "hapticPreferenceKey"
    static let friendsUUIDs = "friendsUUIDs" // Add this line
}

struct Profil {
    var recordId: CKRecord.ID?
    let uuid: String
    let username: String
    let themePreference: String
    let hapticPreference: Bool
    var friendsUUIDs: [String] // Add this line
}

extension Profil {
    
    var privateRecord: CKRecord {
          let record = recordId != nil ? CKRecord(recordType: ProfilRecordKey.privateUserInfoRecordType, recordID: recordId!) : CKRecord(recordType: ProfilRecordKey.privateUserInfoRecordType)
          record[ProfilRecordKey.uuid] = uuid
          record[ProfilRecordKey.username] = username
          record[ProfilRecordKey.themePreference] = themePreference
          record[ProfilRecordKey.hapticPreference] = hapticPreference
          record[ProfilRecordKey.friendsUUIDs] = friendsUUIDs // Add this line
          return record
      }
    
    var publicRecord: CKRecord {
        let record = CKRecord(recordType: ProfilRecordKey.publicUserInfoRecordType)
        record[ProfilRecordKey.uuid] = uuid
        record[ProfilRecordKey.username] = username
        return record
    }
}
