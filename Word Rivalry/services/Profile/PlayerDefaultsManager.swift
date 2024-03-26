//
//  UserDefaultsManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-21.
//

import Foundation
import SwiftUI

enum PlayerDefaultsManagerError: Error {
    case noPlayerNameDefault
    case noPlayerUUIDDefault
    case noPlayerEloRatingDefault
    case noThemePreferenceDefault
    case noHapticPreferenceDefault
}

class PlayerDefaultsManager {
    
    static let shared = PlayerDefaultsManager()
    
    private init() {}
    
    private let playerNameKey = "playerName"
    private let playerUUIDKey = "playerUUID"
    private let playerEloRatingKey = "playerEloRating"
    
    func setUsername(_ playerName: String) {
        UserDefaults.standard.set(playerName, forKey: self.playerNameKey)
    }
    
    func getUsername() throws -> String {
        guard let playerName = UserDefaults.standard.string(forKey: self.playerNameKey) else {
            throw PlayerDefaultsManagerError.noPlayerNameDefault
        }
        return playerName
    }
    
    func setUserUUID(_ playerUUID: String) {
        UserDefaults.standard.set(playerUUID, forKey: self.playerUUIDKey)
    }
    
    func getUserUUID() throws -> String {
        guard let playerUUID = UserDefaults.standard.string(forKey: self.playerUUIDKey) else {
            throw PlayerDefaultsManagerError.noPlayerUUIDDefault
        }
        return playerUUID
    }
    
    func setUserEloRating(_ playerEloRating: Int) {
        UserDefaults.standard.set(playerEloRating, forKey: self.playerEloRatingKey)
    }
    
    func getUserEloRating() throws -> Int {
        return UserDefaults.standard.integer(forKey: self.playerEloRatingKey)
    }
}
