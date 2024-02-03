//
//  ProfileInfoService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit

class ProfileService: ObservableObject {
    
    private let cloudKitService: CloudKitService
    
    init(cloudKitService: CloudKitService = CloudKitService()) {
        self.cloudKitService = cloudKitService
    }
    
    // MARK: PRIVATE PROFILE
    
    // Creates a new user profile
    func createProfile(username: String) async throws -> CKRecord {
        return try await cloudKitService.createUserRecord(username: username)
    }
    
    // Function to get the username for the current iCloud user
    func getUsername() async throws -> String {
        return try await cloudKitService.fetchUsername()
    }
    
    // Function to get the UUID for the current iCloud user
    func getUUID() async throws -> String {
        return try await cloudKitService.fetchUUID()
    }
    
    // Function to get the theme preference for the current iCloud user
    func getThemePreference() async throws -> ColorScheme {
        return try await cloudKitService.fetchThemePreference()
    }
    
    // Updates the username for a given user record
    func updateUsername(to newUsername: String) async throws -> CKRecord {
        return try await cloudKitService.updateUsernameRecord(username: newUsername)
    }
    
    // Updates the theme preference for a given user record
    func updateThemePreference(to newThemePreference: ColorScheme) async throws -> CKRecord {
        return try await cloudKitService.updateThemePreferenceRecord(themePreference: newThemePreference)
    }
    
    // Check if a profile already exist for the user
    func exist() async throws -> Bool  {
        do {
            return try await !cloudKitService.isUserNew()
        } catch {
            throw error
        }
    }
    
    // MARK: FRIEND
    
    func addFriend(username: String) async throws -> Void {
        return try await cloudKitService.addFriend(byUsername: username)
    }
    
    func deleteFriend(friendUUID: String) async throws -> Void {
        return try await cloudKitService.removeFriend(friendUUID: friendUUID)
    }
    
    func searchByUsername(username: String) async throws -> CKRecord? {
        return try await cloudKitService.searchPublicUser(byUsername: username)
    }
}
