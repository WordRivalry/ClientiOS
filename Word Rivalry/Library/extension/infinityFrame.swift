//
//  infinityFrame.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-20.
//

import Foundation
import SwiftUI

extension View {
    func infinityFrame() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
