//
//  DataService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import Foundation
import OSLog

@Observable class DataService: SceneLifeCycle, ViewLifeCycle {
    
    var isFetching: Bool = false
    var lastUpdateTime: Date?
    var isOnViewTree: Bool = false

    @ObservationIgnored
    var isUpdateAllowed: Bool = true
    @ObservationIgnored
    var fetchTimer: PausableTimer?
    @ObservationIgnored
    private let fetchInterval: TimeInterval
    
    init(fetchEvery fetchInterval: TimeInterval = 300) {
        self.fetchInterval = fetchInterval
        setupFetchTimer()
    }
    
    // MARK: - Timer Setup
    
    private func setupFetchTimer() {
        fetchTimer = PausableTimer(interval: fetchInterval, repeats: true) { [weak self] in
            Task { [weak self] in
                await self?.fetchAndUpdateDataIfNeeded()
            }
        }
    }
    
    // MARK: - Scene life cycle management
    
    func handleAppBecomingActive() {
        
        guard isOnViewTree == true else {
            Logger.dataServices.debug("View is not on screen")
            return
        }
        
        if let lastUpdateTime = self.lastUpdateTime, fetchTimer?.isPaused == true {
            fetchTimer?.adjustTimerRemainingTime(basedOn: lastUpdateTime)
            fetchTimer?.resume()
        } else {
            fetchTimer?.resume()
        }
    }
    
    func handleAppGoingInactive() {
        if isOnViewTree {
            fetchTimer?.pause()
        }
    }
    
    func handleAppInBackground() {
        if isOnViewTree {
            fetchTimer?.pause()
        }
    }
    
    // MARK: - View life cycle management
    
    func handleViewDidAppear() {
        isOnViewTree = true
        
        if let lastUpdateTime = self.lastUpdateTime {
            fetchTimer?.adjustTimerRemainingTime(basedOn: lastUpdateTime)
            fetchTimer?.resume()
        } else {
            Logger.dataServices.debug("First update.")
            Task {
                await self.fetchAndUpdateDataIfNeeded()
            }
            // Starts if it's the very first update.
            fetchTimer?.start()
            return
        }
    }
    
    func handleViewDidDisappear() {
        isOnViewTree = false
        fetchTimer?.pause()
    }
    
    // MARK: - Fetching Logic
    func fetchAndUpdateDataIfNeeded() async {
        guard canFetchData() else { return }
        
        isFetching = true
        await performFetch()
        isFetching = false
        
        // Update fetch time on successful fetch
        markFetchTime()
    }
    
    private func canFetchData() -> Bool {
        guard isUpdateAllowed else {
            Logger.dataServices.debug("Fetch precondition not met: Update not allowed.")
            return false
        }
        
        guard NetworkChecker.shared.isConnected else {
            Logger.dataServices.debug("Fetch precondition not met: no internet connection.")
            return false
        }
        
        return true
    }
    
    private func performFetch() async {
        await fetchData()
    }
    
    private func markFetchTime() {
        lastUpdateTime = Date()
        Logger.dataServices.info("Data successfully fetched and marked at \(String(describing: self.lastUpdateTime)).")
    }
    
    // MARK: - Data Fetch Implementation
    
    func fetchData() async {
        fatalError("fetchData() method must be overridden by subclasses.")
    }
    
    func isDataAvailable() -> Bool {
        fatalError("isDataAvailable() method must be overridden by subclasses.")
    }
}
