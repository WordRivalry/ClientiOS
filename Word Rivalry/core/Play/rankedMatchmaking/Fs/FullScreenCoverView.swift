//
//  SearchingFullScreenCoverView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-04.
//


import SwiftUI
import Combine


enum MatchmakingProcess {
    case searching
    case lobby
    case inGame // Holds the matchmaking type for the game
}

struct FullScreenCoverView: View {
    @Bindable var viewModel: MatchmakingViewModel

    init(gameMode: MatchmakingType) {
        self.viewModel = MatchmakingViewModel(matchmakingType: gameMode)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.process {
            case .searching:
                SearchingView(viewModel: viewModel)
            case .lobby:
                LobbyView(viewModel: viewModel)
            case .inGame:
                GameView(gameModel: viewModel.gameModel)
            }
            
            CountdownOverlayView(countdown: $viewModel.gameStartCountdown)
                .allowsHitTesting(false)
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}

struct SearchingView: View {
    var viewModel:MatchmakingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            Text(viewModel.matchmakingType.rawValue)
            
            Spacer()
            
            Text("Searching...")
                .foregroundColor(.white)
                .padding()
            
            Button("Cancel Search") {
                
                viewModel.cancelSearch()
                dismiss()
            }
            .foregroundColor(.blue)
            .padding()
            .onAppear(perform: viewModel.searchMatch)
            
            Spacer()
        }
    }
}

struct LobbyView: View {
    var viewModel: MatchmakingViewModel
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

#Preview {
    FullScreenCoverView(gameMode: MatchmakingType.normal)
}
