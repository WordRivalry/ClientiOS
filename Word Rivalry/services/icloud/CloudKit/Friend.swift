//
//  Friends.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-06.
//

import Foundation
import SwiftData

@Model final class Friend {
    let friendRecordID: String = ""
    init(friendRecordID: String) {
        self.friendRecordID = friendRecordID
    }
    
    static var preview: [Friend] {
        return [
            Friend(friendRecordID: "1"),
            Friend(friendRecordID: "2"),
            Friend(friendRecordID: "3"),
            Friend(friendRecordID: "4")
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
