//
//  AppService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import os.log
import SwiftUI

@Observable final class AppService: Service {
    var isReady: Bool = false
    var progress: Double = 0.0
    var message: String = ""
    
    var services: ServiceLocator?
    private let logger = Logger(subsystem: "com.WordRivalry", category: "AppService")
    
    init() {}
    
    func startApplication() {
        Task {
            // Prepare shared instances
            iCloudService.shared.checkICloudStatus()
            NetworkChecker.shared.startMonitoring()
            
            withAnimation {
                self.message = "Network monitoring"
                self.progress += 0.2
            }
 
            // Wait until the DataSource is ready
            while !(await DataSource.shared.isReady) {
                try? await Task.sleep(nanoseconds: 100_000_000)
                self.logger.info("Awaiting DataSource... 100ms")
            }
            
            withAnimation {
                self.message = "Data source"
                self.progress += 0.1
            }
            // Initialize services
            self.services = .init()
            withAnimation {
                self.message = "Services"
                self.progress += 0.3
            }
            
       
            // Load french dict
            WordChecker.shared.loadTrieFromFile(rss: "french_trie_serialized")
            withAnimation {
                self.message = "Dictionnary loaded"
                self.progress += 0.4
            }
            
            // Starts audio service
         //  if let songs = await services?.audioLoaderService.loadSongs() {
                // start AudioService
         //       services?.audioService.musicManager.setSongs(songs: songs)

                // Play music
                // services?.audioService.playSong()
       //     }
            self.message = "Audio loaded"
            self.message = "Ready"
            self.isReady = true
        }
    }
}
