//
//  PublicProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-28.
//

import Foundation
import SwiftData
import CloudKit

@Model final class Profile {
    let userRecordID: String = ""
    var playerName: String = ""
    var eloRating: Int = 800
    var title: Int = 0
    var banner: Int = 0
    var profileImage: Int = 0
    
    init( // Default provided define a new public profile values
        userRecordID: String,
        playerName: String,
        eloRating: Int,
        title: Int,
        banner: Int,
        profileImage: Int
    ) {
        self.userRecordID = userRecordID
        self.playerName = playerName
        self.eloRating = eloRating
        self.title = title
        self.banner = banner
        self.profileImage = profileImage
    }
    
    static var preview: Profile {
        Profile(
            userRecordID: "my record id",
            playerName: "Lighthouse",
            eloRating: 1234,
            title: 0,
            banner: 0,
            profileImage: 0
        )
    }
    
    static var local: FetchDescriptor<Profile> {
        var descriptor = FetchDescriptor<Profile>()
        descriptor.fetchLimit = 1
        return descriptor
    }
}
