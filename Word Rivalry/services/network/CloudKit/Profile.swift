//
//  PublicProfile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-28.
//

import Foundation
import SwiftData
import CloudKit

@Model
final class Profile {
    let userRecordID: String = ""
    var playerName: String = ""
    var eloRating: Int = 0
    var title: String = ""
    var banner: String = ""
    var profileImage: String = ""
    
    @Relationship
    var achievementsProgression: [AchievementProgression]?
    
    @Transient // We store this information in the public profile, not in SwiftData
    var unlockedAchievementIDs: [String] = []
    

    
    @Transient
    var computedTitle: Title {
        get { Title(rawValue: title) ?? .newLeaf }
        set { title = newValue.rawValue }
    }
    
    @Transient
    var computedBanner: Banner {
        get { Banner(rawValue: banner) ?? .defaultProfileBanner }
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
        banner:                     String                      = Banner.defaultProfileBanner.rawValue,
        profileImage:               String                      = ProfileImage.PI_1.rawValue,
        unlockedAchievementIDs:     [String]                    = [],
        achievementsProgression:    [AchievementProgression]    = []
    ) {
        self.userRecordID               = userRecordID
        self.playerName                 = playerName
        self.eloRating                  = eloRating
        self.title                      = title
        self.banner                     = banner
        self.profileImage               = profileImage
        self.unlockedAchievementIDs     = unlockedAchievementIDs
        self.achievementsProgression    = achievementsProgression
        
        self.subscribeToEvents()
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
}

extension Profile: EventSubscriber {
    
    func subscribeToEvents() {
          EventSystem.shared.subscribe(self, to: [AchievementEventType.achievementUnlocked])
    }
    
    func handleEvent(_ event: AnyEvent) {
        // Check if the event is an AchievementUnlockedEvent
        if let unlockEvent = event as? AchievementUnlockedEvent,
           let achievementID = unlockEvent.data["achievementID"] as? String {
            // Add the achievement ID to the unlocked list if not already present
            if !unlockedAchievementIDs.contains(achievementID) {
                unlockedAchievementIDs.append(achievementID) // SwiftData
                
                Task { // Public profile
                    try? await PublicDatabase.shared.updateAchievementIDs(adding: achievementID)
                }
               
                // Update the UI or notify the user as necessary
                print("Achievement \(unlockEvent.data["name"] ?? "") unlocked!")
            }
        }
    }
}
