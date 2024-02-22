//
//  SoundEffectsManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFoundation

class SoundEffectsManager: NSObject, SoundEffectManageable {
    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private var completionBlocks: [AVAudioPlayer: () -> Void] = [:]
    
    public override init() {
        super.init()
        loadSoundEffects()
    }
    
    private func loadSoundEffects() {
        SoundEffect.allCases.forEach { soundEffect in
            guard let url = Bundle.main.url(forResource: soundEffect.properties.name, withExtension: "wav") else { return }
            
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                audioPlayers[soundEffect] = audioPlayer
            } catch {
                print("Failed to load sound effect \(soundEffect.properties.name): \(error)")
            }
        }
    }
    
//    func prepareThemedSFX(theme: ColorScheme) {
//        
//    }
    
    func play(soundEffect: SoundEffect, completion: @escaping () -> Void) {
        guard let player = audioPlayers[soundEffect] else { return }
        player.delegate = self
        player.play()
        // Make a copy of the completion block so it can be called after the audio finishes playing.
        completionBlocks[player] = completion
    }
    
    func adjustVolume(to level: Float) {
        for (_, audioPlayer) in audioPlayers {
            audioPlayer.volume = level
        }
    }
}

extension SoundEffectsManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Call the completion block (if any) for this player.
        if let completion = completionBlocks[player] {
            completion()
        }
        // Remove the completion block to avoid calling it more than once.
        completionBlocks[player] = nil
    }
}
