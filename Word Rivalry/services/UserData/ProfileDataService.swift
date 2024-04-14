//
//  ProfileDataService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import OSLog

@Observable
class ProfileDataService: ServiceCoordinator {
    var personalProfile: PersonalProfile
    let ppLocal: PPLocalService
    
    override init() {
        self.ppLocal = PPLocalService.sharedInstace
        self.personalProfile = PersonalProfile()
        super.init()

        self.startPriority = .critical(2)
        self.identifier = "ProfileDataService"
        self.addService(ppLocal)
        self.addService(personalProfile)
    }
}
