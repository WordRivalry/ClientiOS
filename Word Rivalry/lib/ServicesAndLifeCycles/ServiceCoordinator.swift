//
//  ServiceCoordinator.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import OSLog

@Observable class ServiceCoordinator: AppService {
    
    private var services: [AppService] = []
    var messages: [String] = []
    
    // Progress Reporting
    @ObservationIgnored
    var progressUpdate: ((Double) -> Void)?
    var progress: Double = 0.0
    
    /// Utility to report progress
    private func reportProgress(_ progress: Double) {
        progressUpdate?(progress)
        Task { @MainActor in
            self.progress = progress
        }
    }
    
    // Hooks
    
    /// Precondition to start the service
    func precondition() async -> Bool { return true }
    func onCriticalServicesReady() { }
    
    init() {}
    
    // MARK: AppService conformance
    
    var isReady: Bool = false
    
    /// Is updated based on services added.
    var isCritical: Bool = false
    
    func start() async -> String {
        if await !precondition() {
            return "Early return: Precondition didn't check"
        }
        
        guard !services.isEmpty else {
            isReady = true
            reportProgress(1.0) // Report 100% progress
            return "No services to start."
        }
        
        Logger.serviceManager.info("Start sub-services")
        
        // Start all services simultaneously
        await startAllServices()
        
        Logger.serviceManager.info("Sub-services task started")
        
        // Monitor readiness of critical services
        await monitorCriticalServicesReadiness()
        
        // Once all critical services are ready, the ServiceManager is ready.
        isReady = true
        
        reportProgress(1.0) // Report 100% progress
        
        onCriticalServicesReady()
        
        return messages.joined(separator: "\n")
    }
    
    private func startAllServices() async {
        await withTaskGroup(of: String.self) { group in
            for (index, service) in self.services.enumerated() {
                group.addTask {
                    // If the service is a coordinator, set up its progress reporting
                    if let coordinator = service as? ServiceCoordinator {
                        coordinator.progressUpdate = { [weak self] progress in
                            self?.reportProgress(Double(index) / Double(self?.services.count ?? 1) + progress / Double(self?.services.count ?? 1))
                        }
                    }
                    return await service.start()
                }
            }
            // Collect messages asynchronously without waiting for all to complete
            for await message in group {
                Logger.serviceManager.info("\(message, privacy: .public)")
                self.messages.append(message)
            }
        }
    }
    
    /// Poll the readiness state of critical services
    private func monitorCriticalServicesReadiness() async {
        let criticalServices = services.filter { $0.isCritical }
        var allCriticalReady = false
        
        repeat {
            allCriticalReady = criticalServices.allSatisfy { $0.isReady }
            Logger.serviceManager.info("Critical sub-services readyness: \(allCriticalReady)")
            try? await Task.sleep(nanoseconds: 100_000_000)
        } while !allCriticalReady
    }
    
    func handleAppBecomingActive() {
        services.forEach { $0.handleAppBecomingActive() }
    }
    
    func handleAppGoingInactive() {
        services.forEach { $0.handleAppGoingInactive() }
    }
    
    func handleAppInBackground() {
        services.forEach { $0.handleAppInBackground() }
    }
    
    // MARK: Service management
    
    /// Add a sub-service dynamically and re-evaluate criticality.
    func addService(_ service: AppService) {
        services.append(service)
        
        if self.isCritical == false { // Check now criticality
            self.isCritical = service.isCritical
        }
    }
}
