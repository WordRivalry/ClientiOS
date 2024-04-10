//
//  RankedGameTournamentView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-01.
//

import SwiftUI

struct GameTournamentCardView: View {
    let nextTournament: Date
    
    var body: some View {
        VStack {
            Text("Daily Arena")
                .font(.headline)
                .padding()
            
            Text("Next Tournament: \(nextTournament, style: .time)")
                .bold()
                .foregroundColor(.red) // Customize as needed
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(radius: 5)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

}

#Preview {
    GameTournamentCardView(nextTournament: Date.now)
}
