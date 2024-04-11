//
//  AudioSessionController.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFAudio
import OSLog

/// AudioSessionController manages the lifecycle of an audio session.
/// It handles interruptions from the system and notifies the audio controller.
@Observable class AudioSessionService: ServiceCoordinator {
    var audioService: AudioService

    /// Initializes an instance of AudioSessionController with an audio controller.
    /// - Parameter audioController: The audio controller to be used for controlling audio.
    init(audioService: AudioService = AudioService()) {
        self.audioService = audioService
        super.init()
        
        // Need to await this service
        self.addService(audioService)
        
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category to playback with default mode.
            // Adjust the category according to your app's audio usage.
            try audioSession.setCategory(.playback, mode: .default)
            
            // Listen for audio interruption notifications.
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioInterruptions),
                name: AVAudioSession.interruptionNotification,
                object: audioSession
            )
        } catch {
            Logger.audio.error("Failed to set audio session category: \(error)")
        }
        Logger.audio.info("AudioSession configuration done")
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
        
        Logger.audio.info("!!! Audio interruption \(type.rawValue) notification received !!!")

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
