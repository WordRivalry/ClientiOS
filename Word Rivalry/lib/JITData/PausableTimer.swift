//
//  PausableTimer.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

class PausableTimer {
    private var timer: Timer?
    private var action: (() -> Void)?
    private let interval: TimeInterval
    private var remainingTime: TimeInterval?
    private var pauseStartTime: Date?
    private var repeats: Bool
    var isPaused: Bool = false
    
    init(interval: TimeInterval, repeats: Bool = true, action: @escaping () -> Void) {
        self.interval = interval
        self.repeats = repeats
        self.action = action
    }
    
    func start() {
        // Guard against restarting the timer if it's only meant to be resumed
        guard !isPaused else {
            Logger.timer.debug("Timer is paused, use resume to continue.")
            return
        }
        
        Logger.timer.debug("Timer started.")
        scheduleTimer(for: interval)
    }
    
    /// Trash the timer, but keep track of the cycle
    func pause() {
        Logger.timer.debug("Timer paused.")
        if timer != nil {
            isPaused = true // Mark as paused to differentiate from stopped
            pauseStartTime = Date()
            timer?.invalidate()
            timer = nil
            
            if let pauseStartTime = pauseStartTime {
                let elapsedTime = Date().timeIntervalSince(pauseStartTime)
                remainingTime = max(interval - elapsedTime, 0)
            }
        }
    }
    
    func resetAndStart() {
        Logger.timer.debug("Timer reset and started.")
        invalidateTimer() // Stop any existing timer and clear state
        start() // Start the timer anew
    }
    
    /// Resume the timer or start it
    func resume() {
        guard isPaused else {
            Logger.timer.debug("Timer is not paused. Use start to initiate.")
            return
        }
        
        Logger.timer.debug("Timer resumed.")
        if let remainingTime = remainingTime {
            scheduleTimer(for: remainingTime)
        }
        isPaused = false // Reset paused state
    }
    
    /// Trash the timer and the cycle
    func stop() {
        Logger.timer.debug("Timer stopped.")
        invalidateTimer()
        isPaused = false // Ensure paused state is reset
    }
    
    private func scheduleTimer(for timeInterval: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.action?()
            if self?.repeats == true && !(self?.isPaused ?? false) {
                self?.scheduleTimer(for: self?.interval ?? timeInterval)
            }
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
        remainingTime = nil
        pauseStartTime = nil
        isPaused = false
    }
    
   func adjustTimerRemainingTime(basedOn lastUpdateTime: Date) {
       let elapsedTimeSinceLastUpdate = Date().timeIntervalSince(lastUpdateTime)
       self.remainingTime = max(interval - elapsedTimeSinceLastUpdate, 0)
       Logger.timer.debug("Remaining time until action: \(self.remainingTime!.description)")
   }
}

