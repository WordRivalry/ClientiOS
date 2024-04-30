//
//  PlayerView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-19.
//

import SwiftUI

struct PlayerView: View {
    var profile: User
    var showScore: Bool = true
    var score: Int
    
    var body: some View {
        VStack {
            PortraitView(avatar: profile.avatar, avatarFrame: profile.avatarFrame)
                .scaleEffect(0.4)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            UsernameView(username: profile.username)
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
            profile: User.preview,
            score: 10
        )
    }
}
