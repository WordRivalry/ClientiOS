//
//  AudioLoaderService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFoundation
import OSLog

private let logger = Logger(subsystem: "PixelsAnima", category: "Audio")

class AudioLoaderService {
    func loadSongs() async -> [Song] {
        guard let resourcePath = Bundle.main.resourcePath else { return [] }
        
        let musicDir = URL(fileURLWithPath: resourcePath).appendingPathComponent("Music")
        
        do {
            let songPaths = try FileManager.default.contentsOfDirectory(at: musicDir, includingPropertiesForKeys: nil)
            
            var loadedSongs: [Song] = []
            
            // Create new task group
            await withTaskGroup(of: Song?.self) { group in
                // Add new task for each song
                for songPath in songPaths.filter({ $0.pathExtension == "mp3" }) {
                    group.addTask {
                        do {
                            return try await self.createSong(from: songPath)
                        } catch {
                            print("Failed to create song from URL \(songPath): \(error)")
                            return nil
                        }
                    }
                }
                
                // Collect results
                for await result in group {
                    if let song = result {
                        loadedSongs.append(song)
                    }
                }
            }
            
            logger.notice("Songs loaded")
            
            return loadedSongs
        } catch {
            print("Failed to load songs: \(error)")
            return []
        }
    }
    
    private func createSong(from url: URL) async throws -> Song {
        let asset = AVAsset(url: url)
        
        // Now we can use await here to load metadata asynchronously
        let metadata = try await asset.load(.commonMetadata)
        
        let title = try await AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierTitle).first?.load(.stringValue) ?? "Unknown"
        let artist = try await AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtist).first?.load(.stringValue) ?? "Unknown"
        let album = try await AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierAlbumName).first?.load(.stringValue) ?? "Unknown"
        
        return Song(theme: .system, title: title, artist: artist, album: album, url: url)
    }
    
}
