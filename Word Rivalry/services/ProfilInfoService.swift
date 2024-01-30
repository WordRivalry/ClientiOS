//
//  ProfileInfoService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-30.
//

import Foundation
import CloudKit

class ProfileInfoService {
    
    private let cloudKitService: CloudKitService
    
    // Initialization with dependency injection for easier testing
    init(cloudKitService: CloudKitService = CloudKitService()) {
        self.cloudKitService = cloudKitService
    }
    
    // Creates a new user profile
    func createUserProfile(username: String) async throws -> CKRecord {
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
    func getThemePreference() async throws -> ThemeConstants {
        return try await cloudKitService.fetchThemePreference()
    }
    
    // Updates the username for a given user record
    func updateUsername(newUsername: String) async throws -> CKRecord {
        return try await cloudKitService.updateUsernameRecord(username: newUsername)
    }
    
    // Updates the theme preference for a given user record
    func updateThemePreference(to newThemePreference: ThemeConstants) async throws -> CKRecord {
        return try await cloudKitService.updateThemePreferenceRecord(themePreference: newThemePreference)
    }
}
