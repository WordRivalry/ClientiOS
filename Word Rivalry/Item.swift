//
//  Item.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
