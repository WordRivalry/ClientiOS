//
//  PlayerInfoView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

struct PlayerInfoView: View {
    var playerName: String
    var eloRating: Int
    var color: Color
    
    var body: some View {
        VStack {
            Text(playerName)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("ELO: \(eloRating)")
                .font(.subheadline)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    PlayerInfoView(
        playerName: "lighthouse",
        eloRating: 1149,
        color: .green
    )
}
