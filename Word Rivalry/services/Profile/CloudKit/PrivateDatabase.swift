//
//  CKPrivateDatabase.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit

class PrivateCloudKitService {
    
    private let CKManager: CloudKitManager
    
    init() {
        self.CKManager = CloudKitManager(containerIdentifier: "iCloud.WordRivalryContainer", databaseScope: .private)
    }
    
    // Function to reserve space for user's data on first start
    func reserveUserDataSpace() async throws {
        // Assuming a method to check if the initial setup needs to be done
        
        // 1. Generate and store a unique UUID for the user
        let uuidRecord = CKRecord(recordType: "UserUUID")
        uuidRecord["uuid"] = UUID().uuidString
        
        // 2. Initialize the friend list with an empty array
        let friendListRecord = CKRecord(recordType: "FriendList")
        friendListRecord["friends"] = [CKRecord.Reference]()
        
        // 3. Setup placeholders for achievements
        // This assumes you have a defined record type for achievements and will vary based on your app's needs
        let achievementsRecord = CKRecord(recordType: "Achievements")
        achievementsRecord["list"] = [String]() // Adjust based on actual achievement data structure
        
        // Save these records using CloudKitManager's functionalities
        // This step might require implementing a new method in CloudKitManager to save a list of CKRecords,
        // or looping through each record to save them individually if your manager supports single record operations.
    }
    
    // Fetches the current user's CKRecord and modifies it
    func updatePlayerName(playerName: String) async throws -> CKRecord {
        // Fetch the current user's record
        let userRecord = try await CKManager.userRecord()
        
        // Modify the user's record with the new player name
        userRecord[ProfilRecordKey.playerName] = playerName
        
        // Save the modified record back to CloudKit
        return try await CKManager.saveRecord(saving: userRecord)
    }
    
    //    func addPlayerRecord2(playerName: String) async throws -> CKRecord {
    //        let userRecordID = try await CKManager.userRecordID()
    //        let playerRecord = CKRecord(recordType: RecordType.player)
    //        playerRecord[PlayerRecord.userRecordID] = CKRecord.Reference(recordID: userRecordID, action: .none)
    //        playerRecord[PlayerRecord.eloRating] = 800  // Unencrypted as it's a non-sensitive, numerical value
    //
    //        // CloudKit's built-in encryption for sensitive fields
    //        playerRecord.encryptedValues[PlayerRecord.playerName] = playerName as NSString
    //        playerRecord.encryptedValues[PlayerRecord.title] = "standard" as NSString
    //        playerRecord.encryptedValues[PlayerRecord.banner] = "standard" as NSString
    //        playerRecord.encryptedValues[PlayerRecord.profileImage] = "standard" as NSString
    //
    //        return try await CKManager.saveRecord(saving: playerRecord)
    //    }
}
