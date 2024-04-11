//
//  MusicLibrary.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFoundation


class MusicLibrary {
    var songs: [Song] = []
    
    
    public init() {}
    
    func setSongs(songs: [Song]) {
        self.songs = songs
    }
    
    func getSong(index: Int) -> Song? {
        return (index < songs.count) ? songs[index] : nil
    }
    
    func getSong(title: String) -> Song? {
        return songs.first { $0.title == title }
    }
}
