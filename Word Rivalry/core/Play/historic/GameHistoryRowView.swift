//
//  GameHistoryRowView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import SwiftUI

struct GameHistoryRowView: View {
    let gameHistory: MatchHistoric
    
    var body: some View {
        content
            .cardBackground()
    }
    
    @ViewBuilder
    private var content: some View {
        HStack {
            Group {
                if gameHistory.ownScore > gameHistory.opponentScore {
                    Text ("Won")
                        .foregroundStyle(.green)
                } else if gameHistory.ownScore < gameHistory.opponentScore {
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
                Text("\(gameHistory.ownScore)")
            }
            .padding(.horizontal)
            
            Divider()
                .frame(height: 30)
            
            VStack {
                Text(gameHistory.opponentRecordID)
                Text("\(gameHistory.opponentScore)")
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    GameHistoryRowView(gameHistory: MatchHistoric.preview)
}
