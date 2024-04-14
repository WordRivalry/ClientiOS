//
//  GameHistoryRowView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import SwiftUI

struct MatchDetailsRowView: View {
    let matchDetails: MatchHistoric
    
    var body: some View {
        content
            .cardBackground()
    }
    
    @ViewBuilder
    private var content: some View {
        HStack {
            Group {
                if matchDetails.ownScore > matchDetails.opponentScore {
                    Text ("Won")
                        .foregroundStyle(.green)
                } else if matchDetails.ownScore < matchDetails.opponentScore {
                    Text ("Lost")
                        .foregroundStyle(.red)
                } else {
                    Text ("Draw")
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 60)
            .font(.title2)
            .padding(.horizontal)
            
            VStack {
                Text("Your score")
                Text("\(matchDetails.ownScore)")
            }
            .padding(.horizontal)
            
            Divider()
                .frame(height: 30)
            
            VStack {
                Text(matchDetails.thenOpponentName)
                Text("\(matchDetails.opponentScore)")
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    MatchDetailsRowView(matchDetails: MatchHistoric.preview)
}
