//
//  GameHistoryRowView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import SwiftUI

struct HistoryRowView: View {
    let matchDetails: MatchRecord
    
    var body: some View {
        HStack {
            ResultView
            ScoreView
            Divider().frame(height: 30)
            OpponentView
        }
        .frame(maxWidth: .infinity)
        .cardBackground()
    }
    
    // View for Result Status (Won, Lost, Draw)
    private var ResultView: some View {
        Group {
            if matchDetails.ownScore > matchDetails.opponentScore {
                statusText("Won", color: .green)
            } else if matchDetails.ownScore < matchDetails.opponentScore {
                statusText("Lost", color: .red)
            } else {
                statusText("Draw", color: .gray)
            }
        }
        .frame(width: 60)
        .padding(.horizontal)
    }
    
    // Helper to create a styled text for result status
    private func statusText(_ text: String, color: Color) -> some View {
        Text(text)
            .foregroundStyle(color)
            .font(.title2)
    }
    
    // View for displaying the player's score
    private var ScoreView: some View {
        VStack {
            Text("Your score")
            Text("\(matchDetails.ownScore)")
                .frame(width: 80)
        }
        .padding(.horizontal)
    }
    
    // View for displaying opponent's name and score
    private var OpponentView: some View {
        VStack {
            Text("\(matchDetails.thenOpponentName)")
                .frame(width: 115)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text("\(matchDetails.opponentScore)")
                .frame(width: 80)
        }
        .padding(.horizontal)
    }
}


#Preview {
    ViewPreview {
        HistoryRowView(matchDetails: MatchRecord.preview)
    }
}
