//
//  PublicProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-28.
//

import Foundation

import CloudKit
import OSLog

// MARK: PublicProfile
@Observable final class User: CKModel, DataPreview {
   
    var playerName:     String = ""
    var eloRating:      Int = 0
    var title:          String = ""
    var banner:         String = ""
    var profileImage:   String = ""
    var matchPlayed:    Int = 0
    var matchWon:       Int = 0
    
    var computedTitle: Title {
        get { Title(rawValue: title) ?? .newLeaf }
        set { title = newValue.rawValue }
    }
    
    var computedBanner: Banner {
        get { Banner(rawValue: banner) ?? .PB_0 }
        set { banner = newValue.rawValue }
    }
    
    var computedProfileImage: ProfileImage {
        get { ProfileImage(rawValue: profileImage) ?? .PI_1 }
        set { profileImage = newValue.rawValue }
    }
    
    init( // Default provided define a new public profile values
        playerName:                 String,
        eloRating:                  Int                         = 800, // Default rating for new player
        title:                      String                      = Title.newLeaf.rawValue,
        banner:                     String                      = Banner.PB_0.rawValue,
        profileImage:               String                      = ProfileImage.PI_1.rawValue,
        matchPlayed:                Int                         = 0,
        matchWon:                   Int                         = 0,
        recordID:                   CKRecord.ID                 = CKRecord.ID(recordName: "RandomRecordName")
    ) {
        self.playerName                 = playerName
        self.eloRating                  = eloRating
        self.title                      = title
        self.banner                     = banner
        self.profileImage               = profileImage
        self.matchPlayed                = matchPlayed
        self.matchWon                   = matchWon
        self.recordName                 = recordID.recordName
        self.zoneName                   = recordID.zoneID.zoneName
        
        Logger.publicProfile.debug("Public Profile instanciated for: \(playerName)")
    }

    // MARK: CKModel
    
    static var recordType: String = "Users"
    
    var recordName: String
    var zoneName: String
    
    convenience init?(from ckRecord: CKRecord) {
        let playerName = ckRecord[User.forKey(.playerName)] as? String ?? ""
        let eloRating = ckRecord[User.forKey(.eloRating)] as? Int ?? 800
        let profileImage = ckRecord[User.forKey(.profileImage)] as? String ?? ProfileImage.PI_0.rawValue
        let title = ckRecord[User.forKey(.title)] as? String ?? Title.newLeaf.rawValue
        let banner = ckRecord[User.forKey(.banner)] as? String ?? Banner.PB_0.rawValue
        let matchPlayer = ckRecord[User.forKey(.matchPlayed)] as? Int ?? 0
        let matchWon = ckRecord[User.forKey(.matchWon)] as? Int ?? 0

        self.init(
            playerName: playerName,
            eloRating: eloRating,
            title: title,
            banner: banner,
            profileImage: profileImage,
            matchPlayed: matchPlayer,
            matchWon: matchWon,
            recordID: ckRecord.recordID
        )
    }
    
    var record: CKRecord {
        let record = CKRecord(recordType: User.recordType)
        record[User.forKey(.playerName)] = playerName
        record[User.forKey(.eloRating)] = eloRating
        record[User.forKey(.title)] = title
        record[User.forKey(.banner)] = banner
        record[User.forKey(.profileImage)] = profileImage
        record[User.forKey(.matchPlayed)] = matchPlayed
        record[User.forKey(.matchWon)] = matchWon
        return record
    }
    
    // Public field
    enum Key: String, CaseIterable {
        case playerName, eloRating, title, banner, profileImage, matchPlayed, matchWon
    }
    
    // Function to get the string value for a given key
    static func forKey(_ key: Key) -> String {
        return key.rawValue
    }
    
    // MARK: PrewiewData
    
    static var preview: User =  User(
        playerName: "Lighthouse"
    )
    
    static var previewOther: User =  User(
        playerName: "Goultard"
    )
    
    static var nullProfile: User {
        User(
            playerName: "",
            eloRating: 0,
            title: Title.newLeaf.rawValue,
            banner: Banner.PB_0.rawValue,
            profileImage: ProfileImage.PI_0.rawValue,
            matchPlayed: 0,
            matchWon: 0
        )
    }
}
