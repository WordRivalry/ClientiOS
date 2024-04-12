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
        
        let check = NetworkChecker.shared
        iCloudService.shared.checkICloudStatus()
        
        self.messages.append("Getting ready!")
        
        // Sleep for 500 ms before check internet
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Loop until the internet connection is available
        while !check.isConnected {
            self.messages.append("No internet connection found. Retrying...")
            
            if self.screenToDisplay != .noInternet {
                Task { @MainActor in
                    self.screenToDisplay = .noInternet
                }
            }

            // Sleep for 1 sec before checking again
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        if iCloudService.shared.iCloudStatus != .available {
            self.messages.append(iCloudService.shared.statusMessage())
            Task { @MainActor in
                self.screenToDisplay = .noIcloud
            }
            return false
        }
        
        Task { @MainActor in
            self.screenToDisplay = .main
        }
        
        return true
    }
}
