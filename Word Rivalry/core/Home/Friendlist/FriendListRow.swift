//
//  FriendListRow.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

struct FriendListRow: View {
    let profile: PublicProfile
    
    var body: some View {
        ZStack {
            playerView
            achievementsView
            
            HStack {
                Spacer()
                VStack {
                    Button {
                        debugPrint("Challenging")
                    } label: {
                        VStack {
                            Image(systemName: "pencil.slash")
                            Text("Challenge")
                        }
                    }
                }.padding(.horizontal)
            }
        }
        .cardBackground()
    }
    
    private var playerView: some View {
        HStack(spacing: 20) {
            PortraitView(profileImage: profile.profileImage, banner: profile.banner)
                .scaleEffect(0.4)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            playerDetailsView
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var playerDetailsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(profile.playerName).font(.headline)
            Text("Elo \(profile.eloRating)").font(.subheadline).foregroundColor(.secondary)
        }
    }
    
    private var achievementsView: some View {
        HStack {
            Spacer()
            Spacer()
            VStack {
                TitleView(title: profile.title)
                    .frame(width: 140)
                    .font(.caption)
                    .padding(.vertical, 5)
                
                Text("Win \(profile.matchWon) / \(profile.matchPlayed)")
                    .font(.caption)
            }
            Spacer()
        }
    }
}

#Preview {
    FriendListRow(profile: PublicProfile.preview)
}
