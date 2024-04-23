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
    case loading
    case mainContent
}

@Observable class AppServiceManager: ServiceCoordinator, ViewLifeCycle {

    var messageDisplay: String = ""

    let audioService: AudioSessionService
    let myPublicProfile: MyPublicProfile
    let myPersonalProfile: MyPersonalProfile
    
    init(
        audioService: AudioSessionService =  AudioSessionService(),
        myPublicProfile: MyPublicProfile = MyPublicProfile(),
        myPersonalProfile: MyPersonalProfile = MyPersonalProfile()
    ) {
        // init
        self.audioService = audioService
        self.myPublicProfile = myPublicProfile
        self.myPersonalProfile = myPersonalProfile
        super.init()
        
        // Service registrar
        self.addService(NetworkChecker.shared)
        self.addService(iCloudService.shared)
        self.addService(EfficientWordChecker.shared)
        self.addService(myPublicProfile)
        self.addService(myPersonalProfile)
        self.addService(audioService)
        
        // Self property
        self.startPriority = .critical(0)
        self.identifier = "AppServiceManager"
        
        Logger.viewCycle.debug("~~~ AppServiceManager init ~~~")
    }
    
    // MARK: Hook
    
    override func onCriticalServicesHealthy() {
        Task { @MainActor in
            StartUpViewModel.shared.screen = .mainContent
        }
        
        self.logger.logServiceTree(service: self)
    }
   
    // MARK: Scene life cycle

    override func handleAppBecomingActive() {
        super.handleAppBecomingActive()
    }
    
    override func handleAppGoingInactive() {
        super.handleAppGoingInactive()
    }
    
    override func handleAppInBackground() {
        super.handleAppInBackground()
    }
    
    // MARK: View life cycle
    
    func handleViewDidAppear() {
    }
    
    func handleViewDidDisappear() {
    }
}
