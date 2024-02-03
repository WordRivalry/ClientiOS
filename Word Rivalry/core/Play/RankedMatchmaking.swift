//
//  RankedMatchmaking.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct RankedMatchmaking: View {
    @State private var isMatchmaking = false
    var body: some View {
        VStack {
            Text("Ranked Matchmaking")
                .font(.largeTitle)
                .padding()

            Divider()
            
            Text("Word 'example' exists: \(WordChecker.shared.wordExists("example") ? "Yes" : "No")")
                .padding()
                .background(WordChecker.shared.wordExists("example") ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .cornerRadius(10)
                .padding()

            if isMatchmaking {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                
                NavigationLink {
                    GameView(viewModel: GameModel())
                } label: {
                    Text("Find Match")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }

             
//                Button(action: {
//                    // Placeholder for matchmaking logic
//                    print("Initiating ranked matchmaking...")
//                    
//                    withAnimation {
//                        isMatchmaking = true
//                    }
//                }) {
//                    Text("Find Match")
//                        .bold()
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                .padding()

                Spacer()
            }
        }
    }
}

#Preview {
    RankedMatchmaking()
}
