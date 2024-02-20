//
//  SoundEffectManageable.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation



/// SoundEffectManageable is a protocol for sound effects management.
protocol SoundEffectManageable {
    /// Play a sound effect.
    /// - Parameters:
    ///   - soundEffect: The sound effect to be played.
    ///   - completion: A closure to be executed when the sound effect finishes playing.
    func play(soundEffect: SoundEffect, completion: @escaping () -> Void)
}
