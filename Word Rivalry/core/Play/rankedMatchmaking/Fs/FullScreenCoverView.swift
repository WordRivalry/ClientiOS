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
            
            Group{
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CountdownOverlayView(countdown: $searchModel.gameStartCountdown)
                .allowsHitTesting(false)
        }
    }
}

//struct PulsatingCircleView: View {
//    var animatePulse: Bool
//    let animationDuration: Double
//
//    var body: some View {
//        Circle()
//            .stroke(Color.blue.opacity(0.5), lineWidth: 5)
//            .scaleEffect(animatePulse ? 1.5 : 1)
//            .opacity(animatePulse ? 0 : 1)
//            // Ensure the animation only starts once `animatePulse` is true
//            .animation(animatePulse ? Animation.easeOut(duration: animationDuration).repeatForever(autoreverses: false) : nil, value: animatePulse)
//            .frame(width: 200, height: 200)
//    }
//}


struct SearchingView: View {
    var viewModel: SearchModel
    @Environment(\.dismiss) var dismiss
    
    @State private var textScale = 0.1 // Start scaled down
    @State private var textOpacity = 0.0 // Start almost invisible
    
    // Define specific animation durations for better control
    let textAppearDuration = 0.5
    let blinkDuration = 3.0
    
    var body: some View {
        ZStack {
            AnimatedCirclesView().opacity(0.7)
            
            VStack {
                Text(viewModel.modeType.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Spacer()
                
                // "Searching" text with varying opacity
                Text("Searching")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .padding()
                    .opacity(textOpacity)
                    .scaleEffect(textScale)
                    .shadow(radius: 10)
                    .onAppear {
                        // Pop effect: scale up then down
                        withAnimation(.easeOut(duration: textAppearDuration)) {
                            textScale = 1.2
                            textOpacity = 1.0
                        }
                        withAnimation(.easeOut(duration: textAppearDuration).delay(textAppearDuration)) {
                            textScale = 1.0
                        }
                        // Start blinking after initial animations
                        DispatchQueue.main.asyncAfter(deadline: .now() + textAppearDuration * 2) {
                            withAnimation(.easeInOut(duration: blinkDuration / 2).repeatForever(autoreverses: true)) {
                                textOpacity = 0.2 // Adjust opacity for the blinking effect
                            }
                        }
                    }
                
                Spacer()
                
                BasicButton(text: "Cancel Search") {
                    do {
                        try viewModel.cancelSearch()
                    } catch {
                        print("Error occurred: \(error)")
                    }
                    dismiss()
                }
                .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}



struct LobbyView: View {
    var viewModel: SearchModel
    var body: some View {
        VStack {
            Text("Opponent: \(viewModel.opponentUsername)")
                .foregroundColor(.black)
                .padding()
            
            Text("You: \(viewModel.myUsername)")
                .foregroundColor(.black)
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
