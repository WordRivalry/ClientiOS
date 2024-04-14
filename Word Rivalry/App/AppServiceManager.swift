//
//  AppServiceManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//
import Foundation
import OSLog


@Observable class StartUpViewModel {
    var messageToDisplay = ""
    var screen: Screen = .loading
    static var shared = StartUpViewModel()
    
    private init() { }
}

enum Screen {
    case noIcloud
    case noInternet
    case loading
    case main
    case error
}

@Observable class AppServiceManager: ServiceCoordinator, ViewLifeCycle {

    var messageDisplay: String = ""
    
    @ObservationIgnored
    var monitoringTimer: PausableTimer?

    let audioService: AudioSessionService
    let profileDataService: ProfileDataService
    
    init(
        audioService: AudioSessionService,
        profileDataService: ProfileDataService
    ) {
        // init
        self.audioService = audioService
        self.profileDataService = profileDataService
        super.init()
        
        // Service registrar
        self.addService(NetworkChecker.shared)
        self.addService(iCloudService.shared)
        self.addService(WordChecker.shared)
        self.addService(audioService)
        self.addService(profileDataService)
        
        // Self property
        self.startPriority = .critical(0)
        self.identifier = "AppServiceManager"
    }
    
    // MARK: Hook
    
    override func onCriticalServicesHealthy() {
        Task { @MainActor in
            StartUpViewModel.shared.screen = .main
        }
        
        self.logger.logServiceTree(service: self)
    }
   
    // MARK: Scene life cycle

    override func handleAppBecomingActive() {
        super.handleAppBecomingActive()
        if ((monitoringTimer?.isPaused) != nil) {
            monitoringTimer?.resume()
        }
    }
    
    override func handleAppGoingInactive() {
        super.handleAppGoingInactive()
        monitoringTimer?.pause()
    }
    
    override func handleAppInBackground() {
        super.handleAppInBackground()
        monitoringTimer?.pause()
    }
    
    // MARK: View life cycle
    
    func handleViewDidAppear() {
        setupFetchTimer()
    }
    
    func handleViewDidDisappear() {
        self.monitoringTimer?.stop()
    }
    
    // MARK: - Timer Setup
    
    private func setupFetchTimer() {
        monitoringTimer = PausableTimer(interval: 60, repeats: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.logger.logServiceTree(service: strongSelf)
        }
    }
}
