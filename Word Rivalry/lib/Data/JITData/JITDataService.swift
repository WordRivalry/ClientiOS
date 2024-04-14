//
//  JITDataService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import OSLog

@Observable class JITDataService<ServiceIdentifier: JITServiceType & Hashable> : AppService {
    
    func healthCheck() async -> Bool {
        self.isHealthy
    }
    
    var identifier: String = "JITDataService"
    var startPriority: ServiceStartPriority = .nonCritical(Int.max)
    var subserviceCount: Int = 0
    
    var isHealthy: Bool = false
    
    private var servicesRegistry: [ServiceIdentifier: JITData] = [:]
    
    func start() async -> String {
        isHealthy = true
        return "Just-in-time data service(s) ready"
    }

    func registerService(_ service: JITData, forType type: ServiceIdentifier) {
        servicesRegistry[type] = service
    }
    
    func getService<T: JITData>(for type: ServiceIdentifier) -> T {
        let jitData = self.servicesRegistry[type]  as! T
        return jitData
    }

    func handleAppBecomingActive() {
        servicesRegistry.values.forEach { $0.handleAppBecomingActive() }
    }
    
    func handleAppGoingInactive() {
        servicesRegistry.values.forEach { $0.handleAppGoingInactive() }
    }
    
    func handleAppInBackground() {
        servicesRegistry.values.forEach { $0.handleAppInBackground() }
    }
    
    func handleViewDidAppear() {}
    func handleViewDidDisappear() {}
}
