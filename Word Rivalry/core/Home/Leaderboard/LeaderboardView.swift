//
//  LeaderboardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LeaderboardView: View {
    @Environment(LeaderboardService.self) private var leaderboard: LeaderboardService
    
    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(leaderboard.players.indices, id: \.self) { index in
                        let player = leaderboard.players[index]
                        LeaderboardRow(rank: index + 1, player: player)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top)
        BasicDissmiss()
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let player: Profile
    
    var body: some View {
        HStack(spacing: 20) {
            Text("\(rank)")
                .bold()
                .font(.title3)
                .frame(width: 36, alignment: .trailing)
            
            PortraitView(profileImage: player.profileImage, banner: player.banner)
                .scaleEffect(0.4)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.playerName)
                    .font(.headline)
                Text("Elo \(player.eloRating)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        LeaderboardView()
            .environment(LeaderboardService.preview)
    }
}


//
//BasicButton(text: "Send Achievment event") {
//    let buttonClickEvent = PlayerActionEvent(
//        type: .buttonClick,
//        data: [:],
//        timestamp: Date()
//    )
//
//    EventSystem.shared.publish(event: buttonClickEvent)
//}
