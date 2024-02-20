//
//  Playlist.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation

class Playlist {
    var songs: [Song]
    var currentIndex: Int

    init(songs: [Song]) {
        self.songs = songs
        self.currentIndex = 0
    }
    
    func nextSong() -> Song? {
        guard !songs.isEmpty else { return nil }
        currentIndex = (currentIndex + 1) % songs.count
        return songs[currentIndex]
    }
    
    func previousSong() -> Song? {
        guard !songs.isEmpty else { return nil }
        currentIndex = (currentIndex - 1 + songs.count) % songs.count
        return songs[currentIndex]
    }
    
    func currentSong() -> Song? {
        guard !songs.isEmpty else { return nil }
        return songs[currentIndex]
    }
}
