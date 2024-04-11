//
//  AppServiceManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//
import Foundation
import OSLog

enum Screen {
    case noIcloud
    case noInternet
    case main
    case error
}

@Observable class AppServiceManager: ServiceCoordinator {

    var messageDisplay: String = ""
    var screenToDisplay: Screen = .main
    
    let audioService: AudioSessionService
    let profileDataService: ProfileDataService
    let jitData: JITDataService<JITDataType>
    init(
        audioService: AudioSessionService,
        profileDataService: ProfileDataService,
        jitData: JITDataService<JITDataType>
    ) {
        self.audioService = audioService
        self.profileDataService = profileDataService
        self.jitData = jitData
        super.init()
        
        self.addService(jitData)
        self.addService(audioService)
        self.addService(profileDataService)
        self.addService(WordChecker.shared)
        
        Logger.serviceManager.info("*** AppServiceManager init ***")
    }
    
    override func precondition() async -> Bool {
        
        NetworkChecker.shared
        iCloudService.shared.checkICloudStatus()
        
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        if !NetworkChecker.shared.isConnected {
            self.messages.append("No internet connection found")
            self.screenToDisplay = .noInternet
            return false
        }
        
        if iCloudService.shared.iCloudStatus != .available {
            self.messages.append(iCloudService.shared.statusMessage())
            self.screenToDisplay = .noInternet
            return false
        }
        return true
    }
}
