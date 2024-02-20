//
//  AudioSessionController.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFAudio

/// AudioSessionController manages the lifecycle of an audio session.
/// It handles interruptions from the system and notifies the audio controller.
class AudioSessionService: ObservableObject {
    let audioService: AudioService

    /// Initializes an instance of AudioSessionController with an audio controller.
    /// - Parameter audioController: The audio controller to be used for controlling audio.
    init(audioService: AudioService = AudioService()) {
        self.audioService = audioService
        let audioSession = AVAudioSession.sharedInstance()
        
        // Listen for audio interruption notifications.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruptions),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    /// Handles audio interruptions.
    /// - Parameter notification: The interruption notification.
    @objc func handleAudioInterruptions(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Pause audio when interruption begins.
            audioService.musicManager.pauseSong()
        case .ended:
            // Resume audio when interruption ends and if shouldResume option is set.
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    if !audioService.musicManager.isPlaying() {
                        audioService.musicManager.resumeSong()
                    }
                }
            }
        default: break
        }
    }
}
