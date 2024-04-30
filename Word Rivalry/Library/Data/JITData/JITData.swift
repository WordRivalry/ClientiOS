//
//  DataService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

@Observable class JITData: SceneLifeCycle, ViewLifeCycle {
    
    var isFetching: Bool = false
    var lastUpdateTime: Date?
    var error: Error?

    @ObservationIgnored
    var isOnViewTree: Bool = false
    @ObservationIgnored
    var isUpdateAllowed: Bool = true
    @ObservationIgnored
    private let cooldownRefresh: TimeInterval
    
    init(with cooldownRefresh: TimeInterval = 300) {
        self.cooldownRefresh = cooldownRefresh
    }
    
    // MARK: - Scene life cycle management
    
    func handleAppBecomingActive() {
        
        guard isOnViewTree == true else {
            Logger.dataServices.debug("View is not on screen")
            return
        }
        Task {
            await fetchAndUpdateDataIfNeeded()
        }
    }
    
    func handleAppGoingInactive() { }
    
    func handleAppInBackground() { }
    
    // MARK: - View life cycle management
    
    func handleViewDidAppear() {
        isOnViewTree = true
        Task { // Background thread work
            await self.fetchAndUpdateDataIfNeeded()
        }
    }
    
    func handleViewDidDisappear() {
        isOnViewTree = false
    }
    
    // MARK: - Fetching Logic
    func fetchAndUpdateDataIfNeeded() async {
        guard canFetchData() else { return }
        
        // UI
        await MainActor.run {
            isFetching = true
        }

        // Work
        do {
            try await fetchData()
        } catch {
            // UI
            await MainActor.run {
                self.error = error
            }
        }
        
        // UI
        await MainActor.run {
            isFetching = false
        }
        
        // Update fetch time on successful fetch
        await markFetchTime()
    }
    
    private func canFetchData() -> Bool {
        guard isUpdateAllowed else {
            Logger.dataServices.debug("Fetch precondition not met: Update not allowed.")
            return false
        }
        
        guard NetworkMonitoring.shared.isConnected else {
            Logger.dataServices.debug("Fetch precondition not met: no internet connection.")
            return false
        }
        
        Logger.dataServices.debug("Fetch precondition: \(-(self.lastUpdateTime?.timeIntervalSinceNow ?? -1))")
        
        if let lastUpdateTime = self.lastUpdateTime {
            // timeIntervalSinceNow is a negative value
            let timeIntervalSinceLastupdate =  -lastUpdateTime.timeIntervalSinceNow
        
            if timeIntervalSinceLastupdate < cooldownRefresh {
                Logger.dataServices.debug("Fetch precondition not met: Refresh in cooldown.")
                return false
            }
        }
        
        return true
    }
    
    private func markFetchTime() async {
        
        // UI
        await MainActor.run {
            lastUpdateTime = Date()
            
            Logger.dataServices.info(
                "Data successfully fetched and marked at \(String(describing: self.lastUpdateTime))."
            )
        }
    }
    
    // MARK: - Data Fetch Implementation
    
    func fetchData() async throws {
        fatalError("fetchData() method must be overridden by subclasses.")
    }
    
    func isDataAvailable() -> Bool {
        fatalError("isDataAvailable() method must be overridden by subclasses.")
    }
    
    func isDataUnavailable() -> Bool {
        !self.isDataAvailable()
    }
}
