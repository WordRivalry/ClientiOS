//
//  GameCenter.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-02.
//

import Foundation

import GameKit
import SwiftUI

/// - Tag:RealTimeGame
@MainActor @Observable class GameCenter {
    // The local player's friends, if they grant access.
    var friends: [Friend] = []
    
    var myAvatar = Image(systemName: "person.crop.circle")
    
    /// The local player's name.
    var myName: String {
        GKLocalPlayer.local.displayName
    }
 
    /// The root view controller of the window.
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }

    /// Authenticates the local player, initiates a multiplayer game, and adds the access point.
    /// - Tag:authenticatePlayer
    func authenticatePlayer() {
        // Set the authentication handler that GameKit invokes.
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // If the view controller is non-nil, present it to the player so they can
                // perform some necessary action to complete authentication.
                self.rootViewController?.present(viewController, animated: true) { }
                return
            }
            if let error {
                // If you can’t authenticate the player, disable Game Center features in your game.
                print("Error: \(error.localizedDescription).")
                return
            }
            
            // A value of nil for viewController indicates successful authentication, and you can access
            // local player properties.
            
            // Load the local player's avatar.
//            GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
//                if let image {
//                    self.myAvatar = Image(uiImage: image)
//                }
//                if let error {
//                    // Handle an error if it occurs.
//                    print("Error: \(error.localizedDescription).")
//                }
//            }
            
            // Add an access point to the interface.
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
      //      GKAccessPoint.shared.isActive = true
        }
    }
 
    /// Saves the local player's score.
    /// - Tag:saveScore
//    func saveScore() {
//        GKLeaderboard.submitScore(myScore, context: 0, player: GKLocalPlayer.local,
//            leaderboardIDs: ["123"]) { error in
//            if let error {
//                print("Error: \(error.localizedDescription).")
//            }
//        }
//    }
    
    /// Resets a match after players reach an outcome or cancel the game.
    func resetMatch() {
        GKAccessPoint.shared.isActive = true
    }
    
    // Rewarding players with achievements.
    
    /// Reports the local player's progress toward an achievement.
    func reportProgress() {
        GKAchievement.loadAchievements(completionHandler: { (achievements: [GKAchievement]?, error: Error?) in
            let achievementID = "1234"
            var achievement: GKAchievement? = nil

            // Find an existing achievement.
            achievement = achievements?.first(where: { $0.identifier == achievementID })

            // Otherwise, create a new achievement.
            if achievement == nil {
                achievement = GKAchievement(identifier: achievementID)
            }

            // Create an array containing the achievement.
            let achievementsToReport: [GKAchievement] = [achievement!]

            // Set the progress for the achievement.
            achievement?.percentComplete = achievement!.percentComplete + 10.0

            // Report the progress to Game Center.
            GKAchievement.report(achievementsToReport, withCompletionHandler: {(error: Error?) in
                if let error {
                    print("Error: \(error.localizedDescription).")
                }
            })

            if let error {
                print("Error: \(error.localizedDescription).")
            }
        })
    }
}
