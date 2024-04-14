//
//  MusicManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "MusicManager", category: "Audio")

class MusicManager {
    private(set) var musicPlayer: MusicPlayer
    private var musicLibrary: MusicLibrary
    var currentPlaylist: Playlist?
    
    // Add this property to keep track of the current song index.
    private var currentSongIndex: Int? = nil
    
    public init(
        musicPlayer: MusicPlayer = MusicPlayer(),
        musicLibrary: MusicLibrary = MusicLibrary()
    ) {
        self.musicPlayer =  musicPlayer
        self.musicLibrary =  musicLibrary
    }
    
    func setSongs(songs: [Song]) {
        musicLibrary.setSongs(songs: songs)
        currentPlaylist = Playlist(songs: songs)
    }
    
    func isPlaying() -> Bool {
        return musicPlayer.isPlaying
    }
    
    func playSong() {
        guard let song = currentPlaylist?.currentSong() else {
            Logger.audio.error("Failed to get the current song from the playlist")
            return
        }
        
        musicPlayer.play(song: song)
    }
    
    func playNextSong() {
        guard let nextSong = currentPlaylist?.nextSong() else {
            Logger.audio.error("Failed to get the next song from the playlist")
            return
        }
        musicPlayer.play(song: nextSong)
    }
    
    // Play a song by its index.
    func playSong(at index: Int) {
        
        // place the playlist index
        guard ((currentPlaylist?.currentIndex = index) != nil) else {
            Logger.audio.error("Failed to get song at index \(index)")
            return
        }

        self.playSong()
    }
    
    func playPreviousSong() {
        guard let previousSong = currentPlaylist?.previousSong() else {
            Logger.audio.error("Failed to get the previous song from the playlist")
            return
        }
        musicPlayer.play(song: previousSong)
    }
    
    // Pause the currently playing song.
    func pauseSong() {
        musicPlayer.pause()
    }
    
    // Resume playing the currently paused song.
    func resumeSong() {
        musicPlayer.resume()
    }
    
    // Stop playing the currently playing song.
    func stopSong() {
        musicPlayer.stop()
    }
}
