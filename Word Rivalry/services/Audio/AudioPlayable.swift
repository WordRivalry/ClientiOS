//
//  AudioPlayable.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation


/// AudioPlayable is a protocol for audio playback.
protocol AudioPlayable {
    /// Whether the audio player is currently playing.
    var isPlaying: Bool { get }
    
    /// Play a song.
    /// - Parameter song: The song to be played.
    func play(song: Song)
    
    /// Pause the currently playing song.
    func pause()
    
    /// Resume playing the currently paused song.
    func resume()
    
    /// Stop playing the currently playing song.
    func stop()
    
    /// Adjust the volume of the currently playing song.
    /// - Parameter volume: The volume to be adjusted to. Should be a value between 0.0 and 1.0.
    func adjustVolume(to volume: Float)
    
    /// The progress of the currently playing song.
    /// The value ranges from 0.0 (beginning of the song) to 1.0 (end of the song).
    var songProgress: Double { get }
}
