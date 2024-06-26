//
//  Song.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation

protocol PlayableSong {
    var title: String { get }
    var artist: String { get }
    var album: String { get }
    var url: URL { get }
}

struct Song: PlayableSong {
    let title: String
    let artist: String
    let album: String
    let url: URL
}

