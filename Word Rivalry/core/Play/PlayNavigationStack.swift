//
//  PlayNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import os.log

enum PlayTab {
    case Multiplayer, SoloAdventures
}

struct PlayNavigationStack: View {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "PlayNavigationStack")
    
    init() {
        self.logger.debug("*** PlayNavigationStack init ***")
    }
    
    var body: some View {
        NavigationStack {
            PlayView()
                .navigationTitle("Battle")
                .navigationBarTitleDisplayMode(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
        }
    }
}



#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        PlayNavigationStack()
            .environment(Profile.preview)
    }
}
