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
    case countdown(Int) // Holds the countdown value
    case inGame(MatchmakingType) // Holds the matchmaking type for the game
}

struct FullScreenCoverView: View {
    var viewModel = MatchmakingViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.process {
            case .searching:
                SearchingView {
                    viewModel.searchMatch()
                }
            case .countdown(let seconds):
                CountdownView(countdown: seconds) {
                    viewModel.process = .inGame(viewModel.matchmakingType)
                }
            case .inGame:
                GameView(viewModel: GameModel())
            }
        }
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }
}


struct SearchingView: View {
    var searchMatch: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Searching...")
                .foregroundColor(.white)
                .padding()
            Button("Cancel Search") {
                // This will dismiss the current full-screen cover view
                dismiss()
            }
            .foregroundColor(.blue)
            .padding()
            .onAppear(perform: searchMatch)
        }
    }
}


struct CountdownView: View {
    @State var countdown: Int
    @State private var timerCancellable: AnyCancellable?
    var onComplete: () -> Void
    
    var body: some View {
        Text("Game starts in \(countdown)")
            .font(.title)
            .foregroundColor(.white)
            .padding()
            .onAppear {
                self.timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        if self.countdown > 0 {
                            self.countdown -= 1
                        } else {
                            self.timerCancellable?.cancel() // Stop the timer
                            onComplete()
                        }
                    }
            }
            .onDisappear {
                // Invalidate and cancel the timer when the view disappears
                self.timerCancellable?.cancel()
            }
    }
}

#Preview {
    FullScreenCoverView()
}
