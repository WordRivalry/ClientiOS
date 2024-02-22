//
//  UserDefaultsManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-21.
//

import Foundation
import SwiftUI

enum UserDefaultsManagerError: Error {
    case noUsernameDefault
    case noUserUUIDDefault
    case noThemePreferenceDefault
    case noHapticPreferenceDefault
}

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    private let usernameKey = "username"
    private let userUUIDKey = "userUUID"
    
    func setUsername(_ username: String) {
        UserDefaults.standard.set(username, forKey: self.usernameKey)
    }
    
    func getUsername() throws -> String {
        guard let username = UserDefaults.standard.string(forKey: self.usernameKey) else {
            throw UserDefaultsManagerError.noUsernameDefault
        }
        return username
    }
    
    func setUserUUID(_ userUUID: String) {
        UserDefaults.standard.set(userUUID, forKey: self.userUUIDKey)
    }
    
    func getUserUUID() throws -> String {
        guard let userUUID = UserDefaults.standard.string(forKey: self.userUUIDKey) else {
            throw UserDefaultsManagerError.noUserUUIDDefault
        }
        return userUUID
    }
}
