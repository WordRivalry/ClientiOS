//
//  AppService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation

final class AppService: ObservableObject {
    
    var services: ServiceLocator
    
    init(services: ServiceLocator = .init()) {
        self.services = services
    }
    
    func startApplication() {
        // Start theme service
        let initialTheme = services.themeService.loadInitialTheme()
        
        Task {
            // Load Profile
            try await self.services.profileService.loadProfile()
            
            // Inject Profile service into matchmaking service
            MatchmakingService.shared.setProfileService(self.services.profileService)
            
            // Load Wordchecker
            WordChecker.shared.loadTrieFromFile(rss: "french_trie_serialized")
            
            // Connect to server
            BattleServerService.shared.setProfileService(self.services.profileService)
        }

        // Starts audio service
        Task {
            // Load music
            let songs = await services.audioLoaderService.loadSongs()
            
            // start AudioService
            services.audioService.musicManager.setSongs(songs: songs)
            
            // Prepare the audio service for the initial theme.
            services.audioService.prepareAudioTheme(theme: initialTheme)
            
            // Play music
//            services.audioService.playSong()
        }
    }
}
