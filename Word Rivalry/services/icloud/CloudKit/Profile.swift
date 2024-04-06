//
//  PublicProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-28.
//

import Foundation
import SwiftData
import CloudKit
import os.log

@Model
final class Profile {
    let userRecordID: String = ""
    var playerName: String = ""
    var eloRating: Int = 0
    var title: String = ""
    var banner: String = ""
    var profileImage: String = ""
        
    @Transient
    private let logger = Logger(subsystem: "com.WordRivalry", category: "Profile")
    
    @Transient // We store this information in the public profile, not via SwiftData
    var unlockedAchievementIDs: [String] = []
    
    @Transient
    var computedTitle: Title {
        get { Title(rawValue: title) ?? .newLeaf }
        set { title = newValue.rawValue }
    }
    
    @Transient
    var computedBanner: Banner {
        get { Banner(rawValue: banner) ?? .PB_0 }
        set { banner = newValue.rawValue }
    }
    
    @Transient
    var computedProfileImage: ProfileImage {
        get { ProfileImage(rawValue: profileImage) ?? .PI_1 }
        set { profileImage = newValue.rawValue }
    }
    
    init( // Default provided define a new public profile values
        userRecordID:               String,
        playerName:                 String,
        eloRating:                  Int                         = 800, // Default rating for new player
        title:                      String                      = Title.newLeaf.rawValue,
        banner:                     String                      = Banner.PB_0.rawValue,
        profileImage:               String                      = ProfileImage.PI_1.rawValue,
        unlockedAchievementIDs:     [String]                    = []
    ) {
        self.userRecordID               = userRecordID
        self.playerName                 = playerName
        self.eloRating                  = eloRating
        self.title                      = title
        self.banner                     = banner
        self.profileImage               = profileImage
        self.unlockedAchievementIDs     = unlockedAchievementIDs
       // self.subscribeToEvents()
        
        logger.debug("Profile instanciated for: \(playerName)")
    }
}

extension Profile: EventSubscriber {
    
    static var nullProfile: Profile {
        Profile(
            userRecordID: "",
            playerName: "",
            eloRating: 0,
            title: Title.newLeaf.rawValue,
            banner: Banner.PB_0.rawValue,
            profileImage: ProfileImage.PI_0.rawValue,
            unlockedAchievementIDs: []
        )
    }
    
    static var preview: Profile {
        Profile(
            userRecordID: "AQSuadaQUNDa",
            playerName: "Lighthouse"
        )
    }
    
    static var local: FetchDescriptor<Profile> {
        var descriptor = FetchDescriptor<Profile>()
        descriptor.fetchLimit = 1
        
        return descriptor
    }

    func subscribeToEvents() {
          EventSystem.shared.subscribe(self, to: [AchievementEventType.achievementUnlocked])
    }
    
    func handleEvent(_ event: AnyEvent) {
        logger.debug("Received event in profile")
        // Check if the event is an AchievementUnlockedEvent
        if let unlockEvent = event as? AchievementUnlockedEvent {
            self.logger.debug("Event is of type Unlock")
            Task { // Public profile
                do {
                    _ = try await PublicDatabase.shared.updateAchievementIDs(adding: unlockEvent.name)
                    self.logger.debug("Completed Achievement \(unlockEvent.name) added to public profile")
                } catch {
                    self.logger.error("\(error.localizedDescription)")
                }
            }
            // Update the UI or notify the user as necessary
        }
    }
}
