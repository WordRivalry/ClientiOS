//
//  AudioController.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFoundation
import OSLog

private let logger = Logger(subsystem: "PixelsAnima", category: "Audio")

/// AudioController is responsible for controlling the audio player and sound effects manager.
class AudioService: ObservableObject {
    
    // MARK: - Published
    
    /// An error object that can be observed.
    @Published var error: Error?
    
    // MARK: - Class variables
    
    /// The audio player.
    let musicManager: MusicManager = MusicManager()
    /// The sound effects manager.
    let soundEffectsManager: SoundEffectsManager = SoundEffectsManager()
    
    // MARK: - Initialisation

    /// Initializes an instance of AudioController with a music manager and sound effects manager.
    init() {
        configureAudioSession()
        logger.notice("AudioService init")
    }
    
    
    // MARK: - Audio Session
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category to playback with default mode.
            // Adjust the category according to your app's audio usage.
            try audioSession.setCategory(.playback, mode: .default)
        } catch {
            print("Failed to set audio session category: \(error)")
            self.error = error
        }
        logger.notice("AudioSession configuration done")
    }
    
    // MARK: - Theme preparation
    
    func prepareAudioTheme(theme: ColorScheme) {
        musicManager.prepareThemedPlaylist(theme: theme)
        soundEffectsManager.prepareThemedSFX(theme: theme)
        logger.notice("Audio theme prepared")
    }
    
    // MARK: - Music Playback
    
    func playSong() {
        print("AudioControler : PlaySong")
        musicManager.playSong()
    }
    
    /// Play a song.
    func playNextSong() {
        do {
             try musicManager.playNextSong()
         } catch {
             print("Failed to play next song: \(error)")
             self.error = error
         }
    }

    func playPreviousSong() {
        do {
            try musicManager.playPreviousSong()
        } catch {
            print("Failed to play previous song: \(error)")
            self.error = error
        }
    }
    
    /// Pause the currently playing song.
    func pauseSong() {
        do {
            try musicManager.pauseSong()
        } catch {
            print("Failed to pause song: \(error)")
            self.error = error
        }
    }
    
    /// Resume playing the currently paused song.
    func resumeSong() {
        do {
            try musicManager.resumeSong()
        } catch {
            print("Failed to resume song: \(error)")
            self.error = error
        }
    }
    
    /// Stop playing the currently playing song.
    func stopSong() {
        do {
            try musicManager.stopSong()
        } catch {
            print("Failed to stop song: \(error)")
            self.error = error
        }
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
          do {
              try soundEffectsManager.play(soundEffect: soundEffect) {
                  // Restore the volume of the music when the sound effect finishes playing.
                  self.musicManager.musicPlayer.adjustVolume(to: 1.0)
              }
          } catch {
              print("Failed to play sound effect: \(error)")
              self.error = error
          }
    }
}





