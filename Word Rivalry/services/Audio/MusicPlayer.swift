//
//  AudioPlayer.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import AVFoundation


class MusicPlayer: NSObject, AudioPlayable, AVAudioPlayerDelegate, ObservableObject {
    
    static let shared = MusicPlayer()
    
    @Published var isPlaying: Bool = false
    private(set) var audioPlayer: AVAudioPlayer?
    @Published var songProgress: Double = 0
    private var progressTimer: Timer?
    
    public override init() {
        super.init()
    }
    
    func play(song: Song) {
        play(song: song, crossfadeDuration: 1)
    }
    
    func play(song: Song, crossfadeDuration: TimeInterval = 1) {
        if isPlaying {
            handleCrossfade(crossfadeDuration: crossfadeDuration) {
                self.prepareToPlay(song: song)
            }
        } else {
            prepareToPlay(song: song)
            isPlaying = true
        }
        startProgressTimer()
    }
    
    func resume() {
        togglePlaybackState(to: true)
        startProgressTimer()
    }
    
    func pause() {
        togglePlaybackState(to: false)
        pauseProgressTimer()
    }
    
    func stop() {
        togglePlaybackState(to: false)
        stopProgressTimer()
    }
    
    func adjustVolume(to level: Float, duration: TimeInterval = 0) {
        guard duration > 0 else {
            adjustVolume(to: level)
            return
        }
        
        animateVolumeChange(to: level, over: duration)
    }
    
    func adjustVolume(to level: Float) {
        audioPlayer?.volume = level
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

// MARK: - Private Helpers
private extension MusicPlayer {
    func prepareToPlay(song: Song) {
        do {
            let player = try AVAudioPlayer(contentsOf: song.url)
            player.delegate = self
            player.prepareToPlay()
            self.audioPlayer = player
            player.play()
        } catch {
            print("Failed to play song \(song.title): \(error)")
        }
    }
    
    func handleCrossfade(crossfadeDuration: TimeInterval, completion: @escaping () -> Void) {
        adjustVolume(to: 0.0, duration: crossfadeDuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + crossfadeDuration) {
            self.adjustVolume(to: 1.0)
            completion()
        }
    }
    
    func togglePlaybackState(to state: Bool) {
        if state {
            audioPlayer?.play()
        } else {
            audioPlayer?.pause()
        }
        isPlaying = state
    }
    
    func animateVolumeChange(to level: Float, over duration: TimeInterval) {
        let steps = Int(duration * 100)
        let increment = (level - (audioPlayer?.volume ?? 0)) / Float(steps)
        
        for step in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * duration / Double(steps)) {
                self.audioPlayer?.volume += increment
            }
        }
    }
    
    func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateSongProgress()
        }
    }
    
    func pauseProgressTimer() {
        progressTimer?.invalidate()
    }
    
    func stopProgressTimer() {
        progressTimer?.invalidate()
        songProgress = 0
    }
    
    func updateSongProgress() {
        if let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration {
            songProgress = currentTime / duration
        }
    }
}
