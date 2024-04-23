//
//  ProgressReporter.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import Foundation

@Observable
/// Handles progress reporting for service startup.
class ProgressReporter {
    var progress: Double = 0.0
    
    @ObservationIgnored
    var progressUpdate: ((Double) -> Void)?
    
    func updateProgress(for service: AppService) {
        // Assume each service has equal weight in progress.
        if (service as? ServiceCoordinator) != nil {
            if let count = (service as? ServiceCoordinator)?.subserviceCount {
                progress += Double(count)
            }
        }
    
        debugPrint(progress.debugDescription)
        progressUpdate?(progress)
    }

    func completeProgress() {
        progressUpdate?(1.0)
    }
}
