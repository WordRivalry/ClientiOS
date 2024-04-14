//
//  Profile.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-08.
//

import Foundation
import SwiftData
import os.log

@Model
final class Profile: DataPreview {
    

    static var preview: Profile = Profile(currency: 100)
    
    var currency: Int = 0
    
    @Transient
    private let logger = Logger(subsystem: "SwiftData", category: "Profile")
   
    
    init(currency: Int = 0) {
        self.currency = currency
        logger.debug("Profile instanciated with currency: [\(self.currency)]")
    }
}

extension Profile  {
    static var new: Profile {Profile(currency: 0)}
    
    static var local: FetchDescriptor<Profile> {
        var descriptor = FetchDescriptor<Profile>()
        descriptor.fetchLimit = 1
        return descriptor
    }
}
