//
//  PublicProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-28.
//

import Foundation

import GameKit
import CloudKit
import OSLog

@Observable final class User: CKModel, DataPreview {
    
    // MARK: Profile

    // User Stable
    var userID:             String
    
    // Profile
    var country:            Country
    var title:              Title
    var avatar:             Avatar
    var primaryColor:       String
    
    // Premium profile
    var avatarFrame:        AvatarFrame
    var profileEffect:      ProfileEffect
    var accent:             String
    
    // Stats
    var allTimeStars:      Int              = 0
    var experience:         Int             = 0 // Translate to a level
    
    var currentStars:      Int              = 0
    
    var soloMatch:          Int             = 0
    var soloWin:            Int             = 0
    
    var teamMatch:          Int             = 0
    var teamWin:            Int             = 0
    
    init( // Default provided for a new User values
        userID:             String,
        
        // Profile
        country:            Country         = .global,
        title:              Title           = .newLeaf,
        avatar:             Avatar          = .newLeaf,
        primaryColor:       String          = "#fff",
        
        // Premium
        avatarFrame:        AvatarFrame     = .none,
        profileEffect:      ProfileEffect   = .none,
        accent:             String          = "#fff",
        
        // Stats
        allTimePoints:      Int             = 0,
        experience:         Int             = 0,
        currentStars:      Int              = 0,
        
        soloMatch:          Int             = 0,
        soloWin:            Int             = 0,
        
        teamMatch:          Int             = 0,
        teamWin:            Int             = 0,
        
        // CKModel Compatibility
        recordID:           CKRecord.ID     = CKRecord.ID(recordName: "ND")
    ) {
        self.userID = userID
        self.country = country
        self.title = title
        self.avatar = avatar
        self.primaryColor = primaryColor
        
        self.avatarFrame = avatarFrame
        self.profileEffect = profileEffect
        self.accent = accent
        
        self.allTimeStars = allTimePoints
        self.experience = experience
        self.currentStars = currentStars
        self.soloMatch = soloMatch
        self.soloWin = soloWin
        self.teamMatch = teamMatch
        self.teamWin = teamWin
        
        // CKModel Compatibility
        self.recordName = recordID.recordName
        self.zoneName = recordID.zoneID.zoneName
        
        Logger.publicProfile.debug("Public Profile instanciated for: \(self.recordName)")
    }
    
    // MARK: CKModel
    
    static var recordType: String = "User"
    var recordName: String
    var zoneName: String
    

    enum Key: String, CaseIterable {
        case userID // Stable
        case country, title, avatar, primaryColor // Profile
        case avatarFrame, profileEffect, accent // Premium
        case allTimePoints, experience, currentStars, soloMatch, soloWin, teamMatch, teamWin // Stats
    }
    
    /// Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
    
    convenience init?(from ckRecord: CKRecord) {
        let userID = ckRecord[User.forKey(.userID)] as? String ?? ""
        let country = Country(rawValue: ckRecord[User.forKey(.country)] as? String ?? "") ?? .global
        let title = Title(rawValue: ckRecord[User.forKey(.title)] as? String ?? "") ?? .newLeaf
        let avatar = Avatar(rawValue: ckRecord[User.forKey(.avatar)] as? String ?? "") ?? .newLeaf
        let primaryColor = ckRecord[User.forKey(.primaryColor)] as? String ?? "#fff"
        let avatarFrame = AvatarFrame(rawValue: ckRecord[User.forKey(.avatarFrame)] as? String ?? "") ?? .none
        let profileEffect = ProfileEffect(rawValue: ckRecord[User.forKey(.profileEffect)] as? String ?? "") ?? .none
        let accent = ckRecord[User.forKey(.accent)] as? String ?? "#fff"
        let allTimePoints = ckRecord[User.forKey(.allTimePoints)] as? Int ?? 0
        let experience = ckRecord[User.forKey(.experience)] as? Int ?? 0
        let currentStars = ckRecord[User.forKey(.currentStars)] as? Int ?? 0
        let soloMatch = ckRecord[User.forKey(.soloMatch)] as? Int ?? 0
        let soloWin = ckRecord[User.forKey(.soloWin)] as? Int ?? 0
        let teamMatch = ckRecord[User.forKey(.teamMatch)] as? Int ?? 0
        let teamWin = ckRecord[User.forKey(.teamWin)] as? Int ?? 0
        
        self.init(
            userID: userID,
            country: country,
            title: title,
            avatar: avatar,
            primaryColor: primaryColor,
            avatarFrame: avatarFrame,
            profileEffect: profileEffect,
            accent: accent,
            allTimePoints: allTimePoints,
            experience: experience,
            currentStars: currentStars,
            soloMatch: soloMatch,
            soloWin: soloWin,
            teamMatch: teamMatch,
            teamWin: teamWin,
            recordID: ckRecord.recordID
        )
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: User.recordType)
        record[User.forKey(.userID)] = userID
        record[User.forKey(.country)] = country.rawValue
        record[User.forKey(.title)] = title.rawValue
        record[User.forKey(.avatar)] = avatar.rawValue
        record[User.forKey(.primaryColor)] = primaryColor
        record[User.forKey(.avatarFrame)] = avatarFrame.rawValue
        record[User.forKey(.profileEffect)] = profileEffect.rawValue
        record[User.forKey(.accent)] = accent
        record[User.forKey(.allTimePoints)] = allTimeStars
        record[User.forKey(.experience)] = experience
        record[User.forKey(.currentStars)] = currentStars
        record[User.forKey(.soloMatch)] = soloMatch
        record[User.forKey(.soloWin)] = soloWin
        record[User.forKey(.teamMatch)] = teamMatch
        record[User.forKey(.teamWin)] = teamWin
        return record
    }
    
    // MARK: PrewiewData
    
    static var preview: User = User(
        userID: UUID().uuidString,
        country: .random(),
        title: .random(),
        avatar: .random(),
        primaryColor: "red",
        avatarFrame: .random(),
        profileEffect: .random(),
        accent: "red"
    )
    
    static var previewOther: User =  User(userID: "")
    
    
    static var nullUser = User(userID: "")
}
