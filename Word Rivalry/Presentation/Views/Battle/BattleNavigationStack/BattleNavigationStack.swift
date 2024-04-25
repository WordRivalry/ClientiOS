//
//  PlayNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import OSLog

enum PlayTab {
    case Multiplayer, SoloAdventures
}

struct BattleNavigationStack: View {
    
    init() {
        Logger.viewCycle.debug("~~~ PlayNavigationStack init ~~~")
    }
 
    var body: some View {
        NavigationStack {
            BattleMainView()
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
        BattleNavigationStack()
    }
}
