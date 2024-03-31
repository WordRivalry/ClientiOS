//
//  LeaderboardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        VStack {
            Text("Leaderboard Page")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
            
            BasicButton(text: "Send Achievment event") {
                let longWordEvent = PlayerActionEvent(
                    type: .buttonClick,
                    data: [:],
                    timestamp: Date()
                )

                EventSystem.shared.publish(event: longWordEvent)

            }
        }
    
    }
}

#Preview {
    LeaderboardView()
}
