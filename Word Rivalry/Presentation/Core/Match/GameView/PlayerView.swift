//
//  PlayerView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-19.
//

import SwiftUI

struct PlayerView: View {
    @State var profile: PublicProfile
    @State var showScore: Bool = true
    @Binding var score: Int
    
    var body: some View {
        VStack {
            PortraitView(profileImage: profile.profileImage, banner: profile.banner)
                .scaleEffect(0.4)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            PlayerNameView(playerName: profile.playerName)
            TitleView(title: profile.title)
       
            Text("Score: \(score)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .opacity(showScore ? 1 : 0)
        }
        .frame(width: 115)
    }
}

#Preview {
    ViewPreview {
        PlayerView(
            profile: PublicProfile.preview, score: .constant(10)
        )
    }
}
