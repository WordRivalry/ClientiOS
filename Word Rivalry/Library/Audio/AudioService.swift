//
//  AudioController.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFoundation
import OSLog

/// AudioController is responsible for controlling the audio player and sound effects manager.
@Observable class AudioService {
  
    /// An error object that can be observed.
    var error: Error?
    
    // MARK: - Class variables
    
    /// The audio player.
    @ObservationIgnored let musicManager: MusicManager = MusicManager()
    /// The sound effects manager.
    @ObservationIgnored let soundEffectsManager: SoundEffectsManager = SoundEffectsManager()
    
    // MARK: - Initialisation

    /// Initializes an instance of AudioController with a music manager and sound effects manager.
    init() { }
    
    // MARK: - Music Playback
    
    func playSong() {
        musicManager.playSong()
    }
    
    /// Play a song.
    func playNextSong() {
        musicManager.playNextSong()
    }

    func playPreviousSong() {
        musicManager.playPreviousSong()
    }
    
    /// Pause the currently playing song.
    func pauseSong() {
        musicManager.pauseSong()
    }
    
    /// Resume playing the currently paused song.
    func resumeSong() {
        musicManager.resumeSong()
    }
    
    /// Stop playing the currently playing song.
    func stopSong() {
        musicManager.stopSong()
    }

    // MARK: - Sound Effects
    
    /// Play a sound effect.
    /// The volume of the music is lowered when the sound effect starts
    /// and is restored when the sound effect ends.
    /// - Parameter soundEffect: The sound effect to be played.
    func playSoundEffect(_ soundEffect: SoundEffect) {
        // Lower the volume of the music.
        musicManager.musicPlayer.adjustVolume(to: 0.6)
        // Play the sound effect.
        soundEffectsManager.play(soundEffect: soundEffect) {
            // Restore the volume of the music when the sound effect finishes playing.
            self.musicManager.musicPlayer.adjustVolume(to: 1.0)
        }
    }
}

extension AudioService: AppService {
    var isHealthy: Bool {
        get {
            self.musicManager.currentPlaylist != nil
        }
        set {
            //
        }
    }
    
    func healthCheck() async -> Bool {
        self.musicManager.currentPlaylist != nil
    }
    
    var identifier: String {
        "AudioService"
    }
    
    var startPriority: ServiceStartPriority {
        .nonCritical(Int.max)
    }
    
    func start() async -> String {
        let loader = AudioLoaderService()
        let songs = await loader.loadSongs()
        musicManager.setSongs(songs: songs)
        return "Audio Service loaded"
    }
    
    func handleAppBecomingActive() {
        // Should check for reloading songs
        
        self.musicManager.resumeSong()
    }
    
    func handleAppGoingInactive() {
        self.musicManager.pauseSong()
    }
    
    func handleAppInBackground() {
        // Should release songs
    }
}




