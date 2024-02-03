//
//  GameView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct GameView: View {
    private var viewModel: GameModel

    init(viewModel: GameModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Ranked Game")
                .font(.largeTitle)
                .padding()

            Divider()

            // Displaying dynamic content
            VStack(alignment: .leading, spacing: 10) {
                Text("Timer: \(viewModel.timerStatus)")
                Text("Score: \(viewModel.currentScore)")
                Text("Path Score: \(viewModel.currentPathScore)")
                Text("Message: \(viewModel.message)")
                
                switch viewModel.gameStatus {
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

            LetterBoardView(viewModel: viewModel)
                .padding()
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.startGame()
        }
    }
}
#Preview {
    GameView(viewModel: GameModel())
}
