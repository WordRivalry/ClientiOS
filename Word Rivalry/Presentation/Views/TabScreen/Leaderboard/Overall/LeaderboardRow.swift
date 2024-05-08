//
//  LeaderboardRow.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import SwiftUI

struct LeaderboardRow<Content: View>: View {
    let rank: Int
    let player: User
    let username: String
    let content: Content
    
    var body: some View {
        ZStack {
            rankAndPlayerView
            contentView
        }
        .cardBackground()
    }
    
    private var rankAndPlayerView: some View {
        HStack(spacing: 20) {
            rankImageView
                .offset(x: 10)
                .frame(width: 36, height: 36)
            PortraitView(avatar: player.avatar, avatarFrame: player.avatarFrame)
                .scaleEffect(0.4)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            playerView
            Spacer()
        }
    }
    
    private var rankImageView: some View {
        Group {
            switch rank {
            case 1: Image("Leaderboard/first-rank").resizable()
            case 2: Image("Leaderboard/second-rank").resizable()
            case 3: Image("Leaderboard/third-rank").resizable()
            default: Text("\(rank)").bold().font(.title3)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    private var playerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(username)").font(.subheadline).foregroundColor(.secondary)
            TitleView(title: player.title)
                .font(.caption)
                .padding(.vertical, 5)
        }
    }
    
    private var contentView: some View {
        HStack {
            Spacer()
            content
                .frame(width: 140)
        }
    }
}

#Preview {
    ViewPreview {
        LeaderboardRow(
            rank: 23,
            player: User.preview,
            username: "Lighthouse",
            content: Text("Achi: 1234")
        )
    }
}


