//
//  PlayerScoresView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-23.
//

import SwiftUI

struct PlayerScoresView: View {
    var scores: [PlayerResult]
    var sortedScores: [PlayerResult] {
        scores.sorted(by: { $0.score > $1.score })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Adds spacing between each Text view
            ForEach(sortedScores) { scoreEntry in
                HStack {
                    Text("\(scoreEntry.playerName)")
                        .font(.title2)
                        .fontWeight(.bold) // Make the player name bold
                        .foregroundColor(.primary) // Default text color
                    Spacer() // Pushes the name to the left and score to the right
                    Text("\(scoreEntry.score) points")
                        .font(.title2)
                        .foregroundColor(.secondary) // Slightly dimmed color for scores
                }
                .padding(.horizontal) // Add padding on the horizontal edges
                .padding(.vertical, 5) // Slightly less padding on the vertical edges
//                .background(
//                    VisualEffectView(effect: UIBlurEffect(style: .prominent))
//                        .ignoresSafeArea()
//                        .opacity(0.8)
//                    
//                ) // Use the system background color
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip the background to rounded corners
                .shadow(radius: 1) // Optional: Add a subtle shadow for depth
            }
        }
        .padding() // Add padding around the VStack to distance it from the screen edges
    }
}


#Preview {
    PlayerScoresView(scores: [
        PlayerResult(
            playerName: "Lighthouse",
            playerEloRating: 1200,
            score: 350,
            historic: [
                WordHistory(
                    word: "aberrates",
                    path: [[0, 0], [0, 1]],
                    time: 1,
                    score: 100
                ),
                WordHistory(
                    word: "errates",
                    path: [[0, 0], [0, 1]],
                    time: 10,
                    score: 75
                ),
                WordHistory(
                    word: "bavera",
                    path: [[0, 0], [0, 1]],
                    time: 20,
                    score: 75
                ),
                WordHistory(
                    word: "lesteras",
                    path: [[0, 0], [0, 1]],
                    time: 45,
                    score: 100
                ),
            ]
        ),
        PlayerResult(
            playerName: "Neytherland", 
            playerEloRating: 1200,
            score: 250,
            historic: [
                WordHistory(
                    word: "aberrates",
                    path: [[0, 0], [0, 1]],
                    time: 1,
                    score: 100
                ),
                WordHistory(
                    word: "errates",
                    path: [[0, 0], [0, 1]],
                    time: 40,
                    score: 75
                ),
                WordHistory(
                    word: "bavera",
                    path: [[0, 0], [0, 1]],
                    time: 60,
                    score: 75
                ),
            ]
        )
    ])
}
