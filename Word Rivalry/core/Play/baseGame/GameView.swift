//
//  GameView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct GameView: View {
    private var gameModel: GameModel
    @State private var showingQuitAlert = false
    @Environment(\.dismiss) var dismiss

    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }

    var body: some View {
        VStack {
            Text("Ranked Game")
                .font(.largeTitle)
                .padding()
            
            Divider()
            
            // Displaying dynamic content
            VStack(alignment: .leading, spacing: 10) {
                Text("Timer: \(gameModel.timeLeft)")
                Text("Score: \(gameModel.currentScore)")
                Text("Path Score: \(gameModel.currentPathScore)")
                Text("Message: \(gameModel.message)")
                Text("Opponent recent score: \(gameModel.opponentScore)")
                
                switch gameModel.gameStatus {
                case .notStarted:
                    Text("Game Status: Not Started")
                case .ongoing:
                    Text("Game Status: Ongoing")
                case .finished:
                    Text("Game Status: Finished")
                }
            }
            .padding()
            
            Spacer()
            
            LetterBoardView(viewModel: gameModel)
                .cornerRadius(10)
                .scaleEffect(0.8)
            
            Button {
                showingQuitAlert = true
            } label: {
                Text("Quit")
            }
            .alert("Forfeit Match?", isPresented: $showingQuitAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Forfeit", role: .destructive) {
                    gameModel.quitGame()
                    BattleServerService.shared.leaveGameSession()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to forfeit the match?")
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            gameModel.startGame()
        }
    }
}
#Preview {
    GameView(gameModel: GameModel())
}
