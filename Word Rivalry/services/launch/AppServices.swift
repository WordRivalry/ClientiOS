//
//  AppService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import os.log
import SwiftUI
import GameKit

//@Observable final class AppServices: AppService {
//    var isReady: Bool = false
//    var progress: Double = 0.0
//    var message: String = ""
//    var services: ServiceLocator?
//    private let logger = Logger(subsystem: "com.WordRivalry", category: "AppService")
//    
//    init() {
//        self.logger.debug("*** AppService INITIATED ***")
//    }
//    
//    func startApplication() {
//        Task {
//
//            
//         
//            
//            GKLocalPlayer.local.authenticateHandler = { viewController, error in
//               // Handle the authorization callbacks.
//                
//                if let viewController = viewController {
//                        // Present the view controller so the player can sign in.
//                    self.logger.info("GameCenter need sign-in.")
//                        return
//                    }
//                    if error != nil {
//                        // Player could not be authenticated.
//                        // Disable Game Center in the game.
//                        self.logger.info("GameCenter disabled")
//                        return
//                    }
//                    
//                    // Player was successfully authenticated.
//                    // Check if there are any player restrictions before starting the game.
//                self.logger.info("GameCenter authenticated.")
//                
//                // Place the access point on the upper-left corner.
//                GKAccessPoint.shared.location = .topLeading
//                GKAccessPoint.shared.showHighlights = true
//          //      GKAccessPoint.shared.isActive = true
//                
//                Task {
//                    
//                    let val = try await GKAchievement.loadAchievements()
//                    if val.isEmpty {
//                        let achie = GKAchievement(identifier: "newleaf")
//                        achie.percentComplete += 10
//                        try await GKAchievement.report([achie])
//                        
//                        let val2 = try await GKAchievement.loadAchievements()
//                        self.logger.info( "\(val2.debugDescription)" )
//                    }
//                    self.logger.info( "\(val.debugDescription)" )
//                }
//             
//                            
//                    if GKLocalPlayer.local.isUnderage {
//                        // Hide explicit game content.
//                        self.logger.info("Is under age.")
//                    }
//
//
//                    if GKLocalPlayer.local.isMultiplayerGamingRestricted {
//                        // Disable multiplayer game features.
//                        self.logger.info("No multiplayer.")
//                    }
//
//
//                    if GKLocalPlayer.local.isPersonalizedCommunicationRestricted {
//                        // Disable in game communication UI.
//                        self.logger.info("No communication.")
//                    }
//            }
//            
//            do {
//                try await PPLocalService.shared.subscribeToChanges()
//            } catch {
//                debugPrint("Failed first subscription \(error)")
//            }
//            self.message = "Icloud account"
//            withAnimation {
//              
//                self.progress += 0.1
//            }
//            
//            try? await Task.sleep(nanoseconds: 200_000_000)
// 
//            // Wait until the DataSource is ready
//            while !(await SwiftDataSource.shared.isReady) {
//                try? await Task.sleep(nanoseconds: 100_000_000)
//                self.logger.info("Awaiting DataSource... 100ms")
//            }
//            self.message = "Data source"
//            withAnimation {
//             
//                self.progress += 0.1
//            }
//            
//            try? await Task.sleep(nanoseconds: 200_000_000)
//            
//            // Initialize services
//            self.services = .init()
//            self.message = "Services"
//            withAnimation {
//                self.progress += 0.2
//            }
//            
//            try? await Task.sleep(nanoseconds: 100_000_000)
//            withAnimation {
//                self.progress += 0.4
//            }
//            
//            try? await Task.sleep(nanoseconds: 400_000_000)
//            
//            // Starts audio service
//            self.message = "Audio loaded"
//            withAnimation {
//           
//                self.progress += 0.2
//            }
//            
//            try? await Task.sleep(nanoseconds: 200_000_000)
//            
//            self.message = "Ready"
//            
//            try? await Task.sleep(nanoseconds: 100_000_000)
//            
//            self.isReady = true
            
//            
//            [
//               PublicProfile(userRecordID: "", playerName: "Darkfeu", eloRating: 1892, title: "Word Conqueror",profileImage: "PI_15", matchPlayed: 177, matchWon: 138),
//               PublicProfile(userRecordID: "", playerName: "Feudala", eloRating: 1832, title: "Word Smith", profileImage: "PI_2", matchPlayed: 168, matchWon: 123),
//               PublicProfile(userRecordID: "", playerName: "Osamodas", eloRating: 1745, title: "Word Conqueror", profileImage: "PI_14", matchPlayed: 177, matchWon: 116),
//               PublicProfile(userRecordID: "", playerName: "Enutrof", eloRating: 1691, title: "Word Smith", profileImage: "PI_4", matchPlayed: 278, matchWon: 169),
//               PublicProfile(userRecordID: "", playerName: "Cra", eloRating: 1689, title: "New Leaf", profileImage: "PI_5", matchPlayed: 124, matchWon: 123),
//               PublicProfile(userRecordID: "", playerName: "Dartagnan", eloRating: 1676, title: "New Leaf", profileImage: "PI_12", matchPlayed: 134, matchWon: 89),
//               PublicProfile(userRecordID: "", playerName: "Darkfeu", eloRating: 1645, title: "Word Conqueror",profileImage: "PI_15", matchPlayed: 241, matchWon: 167),
//               PublicProfile(userRecordID: "", playerName: "Jack Sparrow", eloRating: 1643, title: "Word Smith", profileImage: "PI_2", matchPlayed: 134, matchWon: 78),
//               PublicProfile(userRecordID: "", playerName: "Harry potter", eloRating: 1623, title: "Word Conqueror", profileImage: "PI_14", matchPlayed: 76, matchWon: 123),
//               PublicProfile(userRecordID: "", playerName: "Venus", eloRating: 1621, title: "Word Smith", profileImage: "PI_4", matchPlayed: 68, matchWon: 138),
//               PublicProfile(userRecordID: "", playerName: "Vlad", eloRating: 1615, title: "New Leaf", profileImage: "PI_5", matchPlayed: 67, matchWon: 123),
//               PublicProfile(userRecordID: "", playerName: "Baran", eloRating: 1613, title: "New Leaf", profileImage: "PI_12", matchPlayed: 34, matchWon: 123),
//               PublicProfile(userRecordID: "", playerName: "Diablo", eloRating: 1609, title: "Word Conqueror",profileImage: "PI_15", matchPlayed: 87, matchWon: 145),
//               PublicProfile(userRecordID: "", playerName: "Pink", eloRating: 1578, title: "Word Smith", profileImage: "PI_2", matchPlayed: 134, matchWon: 56),
//               PublicProfile(userRecordID: "", playerName: "Licorn", eloRating: 1545, title: "Word Conqueror", profileImage: "PI_14", matchPlayed: 654, matchWon: 299),
//               PublicProfile(userRecordID: "", playerName: "Damian", eloRating: 1531, title: "Word Smith", profileImage: "PI_4", matchPlayed: 123, matchWon: 65),
//               PublicProfile(userRecordID: "", playerName: "Thlatta", eloRating: 1529, title: "New Leaf", profileImage: "PI_5", matchPlayed: 145, matchWon: 59),
//               PublicProfile(userRecordID: "", playerName: "3ba7", eloRating: 1526, title: "New Leaf", profileImage: "PI_12", matchPlayed: 321, matchWon: 165),
//               PublicProfile(userRecordID: "", playerName: "Balou", eloRating: 1522, title: "Word Conqueror",profileImage: "PI_15", matchPlayed: 234, matchWon: 128),
//               PublicProfile(userRecordID: "", playerName: "Mouglie", eloRating: 1512, title: "Word Smith", profileImage: "PI_2", matchPlayed: 198, matchWon: 123),
//               PublicProfile(userRecordID: "", playerName: "Vagabond", eloRating: 1445, title: "Word Conqueror", profileImage: "PI_14", matchPlayed: 177, matchWon: 90),
//               PublicProfile(userRecordID: "", playerName: "Beluz", eloRating: 1391, title: "Word Smith", profileImage: "PI_4", matchPlayed: 122, matchWon: 87),
//               PublicProfile(userRecordID: "", playerName: "Baltimor", eloRating: 1289, title: "New Leaf", profileImage: "PI_5", matchPlayed: 78, matchWon: 45),
//               PublicProfile(userRecordID: "", playerName: "Paris", eloRating: 1276, title: "New Leaf", profileImage: "PI_12", matchPlayed: 56, matchWon: 34)
//            ].forEach { profile in
//                Task {
//                    try await PublicDatabase.shared.addPublicProfileRecord(for: profile)
//                }
//                
//            }







//
//        }
//    }
//}
