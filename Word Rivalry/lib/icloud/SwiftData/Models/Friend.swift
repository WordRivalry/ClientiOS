//
//  Friends.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-06.
//

import Foundation
import SwiftData
import os.log

@Model final class Friend {
    let friendRecordID: String = ""
    
    @Transient
    private let logger = Logger(subsystem: "SwiftData", category: "Friend")
    
    init(friendRecordID: String) {
        self.friendRecordID = friendRecordID
        logger.debug("Friend instanciated with id: [\(self.friendRecordID)]")
    }
    
    static var preview: [Friend] {
        return[
            Friend(friendRecordID: "234234234"),
            Friend(friendRecordID: "234234234"),
            Friend(friendRecordID: "234234234"),
            Friend(friendRecordID: "234234234"),
            Friend(friendRecordID: "234234234"),
        ]
    }
}

@Observable class Friends {
    var friends: [Friend]
    init(friends: [Friend]) {
        self.friends = friends
    }
    
    static var preview: Friends {
        return Friends(friends: Friend.preview)
    }
}
