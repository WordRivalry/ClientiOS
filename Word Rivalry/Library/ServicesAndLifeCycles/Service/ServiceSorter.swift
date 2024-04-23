//
//  ServiceSorter.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import Foundation

/// Sorts services based on their start priority.
class ServiceSorter {
    func sortedServices(from services: [AppService]) -> (critical: [AppService], nonCritical: [AppService]) {
        let criticalServices = services.filter { if case .critical = $0.startPriority { return true }; return false }
                                       .sorted { $0.startPriority < $1.startPriority }
        let nonCriticalServices = services.filter { if case .nonCritical = $0.startPriority { return true }; return false }
                                          .sorted { $0.startPriority < $1.startPriority }
        return (criticalServices, nonCriticalServices)
    }
}
