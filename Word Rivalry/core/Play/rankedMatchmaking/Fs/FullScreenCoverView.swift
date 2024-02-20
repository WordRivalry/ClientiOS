//
//  SearchingFullScreenCoverView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-04.
//


import SwiftUI
import Combine


enum GameProcess {
    case searching
    case lobby
    case inGame // Holds the matchmaking type for the game
    case gameEnded
}

struct FullScreenCoverView: View {
    var onGameEnded: (() -> Void)?
    @Bindable var searchModel: SearchModel
    
    init(gameMode: GameMode, modeType: ModeType) {
        self.searchModel = SearchModel(modeType: modeType)
    }
    
    var body: some View {
        ZStack {
            switch searchModel.process {
            case .searching:
                SearchingView(viewModel: searchModel)
            case .lobby:
                LobbyView(viewModel: searchModel)
            case .inGame:
                GameView(gameModel: searchModel.gameModel)
            case .gameEnded:
                ResultsView(viewModel: searchModel)
            }
            
            CountdownOverlayView(countdown: $searchModel.gameStartCountdown)
                .allowsHitTesting(false)
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct SearchingView: View {
    var viewModel:SearchModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            Text(viewModel.modeType.rawValue)
            
            Spacer()
            
            Text("Searching...")
                .foregroundColor(.white)
                .padding()
            
            Button("Cancel Search") {
                do {
                    try  viewModel.cancelSearch()
                } catch {
                    print("Error occurred: \(error)")
                }
                dismiss()
            }
            .foregroundColor(.blue)
            .padding()
            Spacer()
        }
    }
}

struct LobbyView: View {
    var viewModel: SearchModel
    var body: some View {
        VStack {
            Text("Opponent: \(viewModel.opponentUsername)")
                .foregroundColor(.white)
                .padding()
            
            Text("You: \(viewModel.myUsername)")
                .foregroundColor(.white)
                .padding()
        }
    }
}


struct CountdownOverlayView: View {
    @Binding var countdown: Int
    // Added to trigger the scale animation
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            if countdown > 0 {
                Text("\(countdown)")
                    .font(.system(size: 90, weight: .bold))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.0) // Fade effect
                // Ensure the animation triggers scale and opacity changes
                    .animation(.easeInOut(duration: 0.5), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                        // Reset animation state after it's complete to prepare for next countdown
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isAnimating = false
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5))
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.all)
        // Trigger the countdown decrease and restart the animation
        .onChange(of: countdown) {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
            }
        }
    }
}

struct ResultsView: View {
    var viewModel: SearchModel
    
    var body: some View {
        // Design your presentation screen
        // Use viewModel and viewModel.gameModel to access game data for recap
        Text("Game Recap")
    }
}


#Preview {
    FullScreenCoverView(gameMode: GameMode.RANK, modeType: ModeType.NORMAL)
}
