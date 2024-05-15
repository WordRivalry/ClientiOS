//
//  GameCenter.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-02.
//

import Foundation

import GameKit
import SwiftUI

/// Extension to define custom notification names related to network connectivity.
extension Notification.Name {
    static let presentGameCenterViewController = Notification.Name("presentGameCenterViewController")
}


/// - Tag:RealTimeGame
@MainActor @Observable class GameCenter: NSObject {
    // The local player's friends, if they grant access.
    var friends: [Friend] = []
    
    var myAvatar = Image(systemName: "person.crop.circle")
    
    /// The local player's name.
    var myName: String {
        GKLocalPlayer.local.displayName
    }
        
    static let shared: GameCenter = .init()

    
 
 
    /// The root view controller of the window.
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }

    /// Authenticates the local player, initiates a multiplayer game, and adds the access point.
    /// - Tag:authenticatePlayer
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Authentication Error: \(error.localizedDescription)")
                return
            }
            
            if let viewController = viewController {
                // Present the view controller if additional authentication steps are required.
                self.rootViewController?.present(viewController, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                print("Player authenticated successfully.")
            }
        }
    }
    
    var gameCenterViewController: GKGameCenterViewController?
    
    func showGKGameCenter(state: GKGameCenterViewControllerState) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated.")
            return
        }
        
        gameCenterViewController = nil
        let gameCenterViewController = GKGameCenterViewController(state: state)
        gameCenterViewController.gameCenterDelegate = self
        
        rootViewController?.present(gameCenterViewController, animated: true)
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

extension GameCenter: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

