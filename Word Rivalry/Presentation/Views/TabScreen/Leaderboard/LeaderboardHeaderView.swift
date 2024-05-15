//
//  HeaderView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI

struct LeaderboardHeaderView: View {
    @Binding var selectedLeaderboard: LeaderboardType
    @Binding var arenaMode: ArenaMode
    @Namespace private var namespace

    var body: some View {
        HStack {
            Image(
                selectedLeaderboard == .allTimeStars ? arenaMode.imageName : selectedLeaderboard.imageName
            )
                .resizable()
                .frame(width: 80, height: 80)
            
            Text(
                selectedLeaderboard == .allTimeStars ? 
                    arenaMode.header :
                    selectedLeaderboard.header
            )
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .shadow(radius: 2, x: 2, y: 2)
                .matchedGeometryEffect(id: "title", in: namespace)
            
            Spacer()
        }
        .headerStyle()
    }
}

#Preview {
    ViewPreview {
        LeaderboardHeaderView(
            selectedLeaderboard: .constant(.CurrentStars),
            arenaMode: .constant(.solo)
        )
    }
}
