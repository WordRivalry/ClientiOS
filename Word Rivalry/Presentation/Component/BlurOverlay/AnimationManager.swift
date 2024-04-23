//
//  AnimationManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-24.
//

import Foundation
import SwiftUI
import Combine

class AnimationManager {
    static let shared = AnimationManager()
    private var timers: [UUID: Timer] = [:]
    private var progressHandlers: [UUID: (CGFloat) -> Void] = [:]
    private var completionHandlers: [UUID: () -> Void] = [:]

    private init() {}

    @discardableResult
    func startAnimation(
        duration: TimeInterval,
        curve: AnimationCurve = .linear,
        onProgress: @escaping (CGFloat) -> Void,
        onComplete: @escaping () -> Void = {}
    ) -> UUID {
        let animationID = UUID()
        let startTime = Date()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            let elapsedTime = Date().timeIntervalSince(startTime)
            let rawProgress = elapsedTime / duration
            let progress = min(max(curve.apply(rawProgress), 0), 1)

            onProgress(progress)
            
            if progress >= 1 {
                timer.invalidate()
                self?.timers.removeValue(forKey: animationID)
                self?.progressHandlers.removeValue(forKey: animationID)
                onComplete()
                self?.completionHandlers.removeValue(forKey: animationID)
            }
        }
        
        timers[animationID] = timer
        progressHandlers[animationID] = onProgress
        completionHandlers[animationID] = onComplete
        
        return animationID
    }

    func pauseAnimation(animationID: UUID) {
        timers[animationID]?.invalidate()
    }

    func resumeAnimation(
        animationID: UUID,
        duration: TimeInterval,
        curve: AnimationCurve = .linear,
        currentProgress: CGFloat,
        onComplete: @escaping () -> Void = {}
    ) {
        guard let onProgress = progressHandlers[animationID] else { return }
        
        startAnimation(
            duration: duration * TimeInterval(1 - currentProgress),
            curve: curve,
            onProgress: onProgress,
            onComplete: onComplete
        )
    }

    func cancelAnimation(animationID: UUID) {
        timers[animationID]?.invalidate()
        timers.removeValue(forKey: animationID)
        progressHandlers.removeValue(forKey: animationID)
        completionHandlers.removeValue(forKey: animationID)
    }
}

enum AnimationCurve {
    case linear
    case easeIn
    case easeOut
    case easeInOut

    func apply(_ progress: CGFloat) -> CGFloat {
        switch self {
        case .linear:
            return progress
        case .easeIn:
            return progress * progress
        case .easeOut:
            return progress * (2 - progress)
        case .easeInOut:
            return progress < 0.5 ? 2 * progress * progress : -1 + (4 - 2 * progress) * progress
        }
    }
}

