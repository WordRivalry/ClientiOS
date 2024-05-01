//
//  GameResultsView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI
import SwiftData
import os.log

struct GameResultsView: View {
    var gameResults: GameResults
    @Environment(LocalUser.self) private var localUser
    @Environment(MainRouter.self) private var mainRouter
    @Environment(\.dismiss) private var dismiss
  
    private let logger = Logger(subsystem: "com.WordRivalry", category: "GameResultsView")
    
    private var gameOutcome: GameOutcome {
        if gameResults.winner == localUser.user.username {
            GameOutcome.victory
        } else if gameResults.winner.isEmpty {
            GameOutcome.draw
        } else {
            GameOutcome.defeat
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                OutcomeView(gameOutcome: gameOutcome)
                    .padding(.top, 40)
                
                RankUpdateView(
                    oldRating: localUser.user.currentPoints,
                    newRating: localUser.user.currentPoints  + 20
                )
                
                Divider()
                PlayerScoresView(scores: gameResults.playerResults)
                    .onAppearAnimate(delay: 0.6)
                
                Spacer()
                
                BasicButton(text: "Confirm") {
                    dismiss()
                }
                    .scaleEffect(0.8)
                    .padding()
                    .onAppearAnimate(delay: 1.2)
                Spacer()
            }
        }
//        .onAppear {
//            if gameOutcome == .victory {
//                battleOrchestrator.eloService.attributePoint()
//            } else if gameOutcome == .draw {
//                battleOrchestrator.eloService.cancel()
//            } else {
//                // Lost, do nothing
//            }
//        }
        .cornerRadius(15)
        // for smooth entering and exiting
        .transition(.opacity.combined(with: .blurReplace))
        .logLifecycle(viewName: "GameResultsView")
    }
}

#Preview {
    ViewPreview {
        ZStack {
            Text("Hi")
        }
        .fullScreenCover(isPresented: .constant(true)) {
            GameView(
                adversary: .previewOther,
                localUser: .preview,
                gameID: "",
                socket: BattleSocketService()
            )
                .blurredOverlayWithAnimation(isPresented: .constant(true)) {
                    GameResultsView(
                        gameResults: GameResults(
                            winner: "Lighthouse",
                            playerResults: [
                                PlayerResult(
                                    playerName: "Lighthouse",
                                    playerEloRating: 1200,
                                    score: 350,
                                    historic: [
                                        WordHistory(
                                            word: "aberrates",
                                            path: [[0, 0], [0, 1]],
                                            time: 1,
                                            score: 100
                                        ),
                                        WordHistory(
                                            word: "errates",
                                            path: [[0, 0], [0, 1]],
                                            time: 10,
                                            score: 75
                                        ),
                                        WordHistory(
                                            word: "bavera",
                                            path: [[0, 0], [0, 1]],
                                            time: 20,
                                            score: 75
                                        ),
                                        WordHistory(
                                            word: "lesteras",
                                            path: [[0, 0], [0, 1]],
                                            time: 45,
                                            score: 100
                                        ),
                                    ]
                                ),
                                PlayerResult(
                                    playerName: "Neytherland",
                                    playerEloRating: 1200,
                                    score: 250,
                                    historic: [
                                        WordHistory(
                                            word: "aberrates",
                                            path: [[0, 0], [0, 1]],
                                            time: 1,
                                            score: 100
                                        ),
                                        WordHistory(
                                            word: "errates",
                                            path: [[0, 0], [0, 1]],
                                            time: 40,
                                            score: 75
                                        ),
                                        WordHistory(
                                            word: "bavera",
                                            path: [[0, 0], [0, 1]],
                                            time: 60,
                                            score: 75
                                        ),
                                    ]
                                ),
                            ]
                        )
                    )
                }
        }
    }
}
