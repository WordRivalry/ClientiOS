//
//  PlayNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

struct PlayNavigationStack: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                BasicButton(text: "Ranked", destination: RankedMatchmaking())
                BasicButton(text: "Play a friend", destination: PlayVsFriendMatchmakingView())
            }
            .navigationTitle("Matchmaking")
        }
    }
}

#Preview {
    PlayNavigationStack()
}
