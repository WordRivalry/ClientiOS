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
    var body: some View {
        NavigationStack {
            PlayView()
                .navigationTitle("Battle")
                .navigationBarTitleDisplayMode(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background( Image("bg")
                    .resizable()
                    .ignoresSafeArea())
        }
        .logLifecycle(viewName: "PlayNavigationStack")
    }
}

#Preview {
    ViewPreview {
        PlayNavigationStack()
            .environment(Profile.preview)
            .environment(Network())
    }
}
