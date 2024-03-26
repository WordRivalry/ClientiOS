//
//  CKServivce.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-26.
//

import Foundation
import CloudKit
import SwiftUI

// Simplified for brevity; apply similar refactorings as needed.
class CKService {
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    
    // Utilize Swift's error handling to define possible errors.
    enum CloudKitServiceError: Error {
        case userAlreadyExists
        case usernameTaken
        case dataCorrupted
        case userProfileNotFound
        case multipleProfilesFound
        case unknown(Error)
    }
    
    // MARK: - Public Methods
     
     func isUserNew() async throws -> Bool {
         do {
             return try await fetchPrivateRecords(ofType: ProfilRecordKey.privateUserInfoRecordType).isEmpty
         } catch {
             throw CloudKitServiceError.unknown(error)
         }
     }
    
    func createUserRecord(playerName: String) async throws {
         guard try await isUserNew() else {
             throw CloudKitServiceError.userAlreadyExists
         }

         guard !(try await isPlayerNameInPublicDatabase(playerName: playerName)) else {
             throw CloudKitServiceError.usernameTaken
         }

         // Create and save records.
         let userUUID = UUID().uuidString
         let profil = Profil(uuid: userUUID, playerName: playerName, eloRating: 0, friendsUUIDs: [""])

         // Example of applying settings in UserDefaults with a wrapper or dedicated manager.
         UserDefaults.standard.set(playerName, forKey: "playerName")
         UserDefaults.standard.set(userUUID, forKey: "userUUID")

         do {
             try await savePrivateRecord(profil.privateRecord)
             try await savePublicRecord(profil.publicRecord)
         } catch {
             throw CloudKitServiceError.unknown(error)
         }
     }
    
    // MARK: - Private Methods
    
    private func isPlayerNameInPublicDatabase(playerName: String) async throws -> Bool {
        let predicate = NSPredicate(format: "%K == %@", ProfilRecordKey.playerName, playerName)
        let query = CKQuery(recordType: ProfilRecordKey.publicUserInfoRecordType, predicate: predicate)
        do {
            let results = try await publicDatabase.records(matching: query)
            return !results.isEmpty
        } catch {
            throw CloudKitServiceError.unknown(error)
        }
    }

    // Simplify repetitive fetch operations into a single method.
    private func fetchPrivateRecords(ofType recordType: String) async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true) // Fetches all records of the specified type
        let query = CKQuery(recordType: recordType, predicate: predicate)
        do {
            let results = try await privateDatabase.records(matching: query)
            return results.compactMap { $0.1 }
        } catch {
            throw CloudKitServiceError.unknown(error)
        }
    }

