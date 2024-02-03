//
//  ServiceLocator.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation

final class ServiceLocator {
    private(set) var audioService:          AudioService
    private(set) var audioSessionService:   AudioSessionService
    private(set) var audioLoaderService:    AudioLoaderService
    private(set) var themeService:          ThemeService
    private(set) var profileService:        ProfileService
    
    init() {
        self.audioService           = .init()
        self.audioSessionService    = .init(audioService: self.audioService)
        self.audioLoaderService     = .init()
        self.themeService           = .init()
        self.profileService         = .init()
    }
}
