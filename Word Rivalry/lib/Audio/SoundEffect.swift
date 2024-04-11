//
//  SoundEffect.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation



enum SoundEffect: CaseIterable {
    case buttonTap
    case screenTransition
    
    // Add an interruptible property for each sound effect.
    var properties: SoundEffectProperties {
        switch self {
        case .buttonTap:
            return SoundEffectProperties(name: "button_tap", isInterruptible: true)
        case .screenTransition:
            return SoundEffectProperties(name: "arcade", isInterruptible: false)
        }
    }
}


struct SoundEffectProperties {
    let name: String
    let isInterruptible: Bool
}

class SFXThemedCollection {
        
}
