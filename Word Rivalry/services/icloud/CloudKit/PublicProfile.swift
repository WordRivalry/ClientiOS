//
//  PublicProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-28.
//

import Foundation

import CloudKit
import os.log

@Observable final class PublicProfile {
    var userRecordID:   String = ""
    var playerName:     String = ""
    var eloRating:      Int = 0
    var title:          String = ""
    var banner:         String = ""
    var profileImage:   String = ""
    var matchPlayed:    Int = 0
    var matchWon:       Int = 0
    var unlockedAchievementIDs: [String] = []
        
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
    
    private let logger = Logger(subsystem: "CloudKit", category: "PublicProfile")
    
    init( // Default provided define a new public profile values
        userRecordID:               String,
        playerName:                 String,
        eloRating:                  Int                         = 800, // Default rating for new player
        title:                      String                      = Title.newLeaf.rawValue,
        banner:                     String                      = Banner.PB_0.rawValue,
        profileImage:               String                      = ProfileImage.PI_1.rawValue,
        unlockedAchievementIDs:     [String]                    = [],
        matchPlayed:                Int                         = 0,
        matchWon:                   Int                         = 0
    ) {
        self.userRecordID               = userRecordID
        self.playerName                 = playerName
        self.eloRating                  = eloRating
        self.title                      = title
        self.banner                     = banner
        self.profileImage               = profileImage
        self.unlockedAchievementIDs     = unlockedAchievementIDs
        self.matchPlayed                = matchPlayed
        self.matchWon                   = matchWon

        logger.debug("Public Profile instanciated for: \(playerName)")
    }
}

extension PublicProfile: EventSubscriber {
    
    static var nullProfile: PublicProfile {
        PublicProfile(
            userRecordID: "",
            playerName: "",
            eloRating: 0,
            title: Title.newLeaf.rawValue,
            banner: Banner.PB_0.rawValue,
            profileImage: ProfileImage.PI_0.rawValue,
            unlockedAchievementIDs: [],
            matchPlayed: 0,
            matchWon: 0
        )
    }
    
    static var preview: PublicProfile {
        PublicProfile(
            userRecordID: "AQSuadaQUNDa",
            playerName: "Lighthouse"
        )
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
