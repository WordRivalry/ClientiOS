//
//  LeaderboardRow.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import SwiftUI

struct LeaderboardRow: View {
    let rank: Int
    let player: User
    
    var body: some View {
        ZStack {
            rankAndPlayerView
            achievementsView
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
            case 1: Image("first-rank").resizable()
            case 2: Image("second-rank").resizable()
            case 3: Image("third-rank").resizable()
            default: Text("\(rank)").bold().font(.title3)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    private var playerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(player.username).font(.headline)
            Text("Elo \(player.currentPoints)").font(.subheadline).foregroundColor(.secondary)
        }
    }
    
    private var achievementsView: some View {
        HStack {
            Spacer()
            VStack {
                TitleView(title: player.title)
                    .frame(width: 140)
                    .font(.caption)
                    .padding(.vertical, 5)
                
                Text("Win \(player.soloWin) / \(player.soloMatch)")
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ViewPreview {
        LeaderboardRow(rank: 23, player: User.preview)
    }
}
