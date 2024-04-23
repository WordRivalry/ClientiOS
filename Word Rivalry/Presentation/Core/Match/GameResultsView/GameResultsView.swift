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
    var duration: Int
    var completeWordList: [String]
    var board: Board<LetterTile>
    @State var showWordList: Bool = false
    @Environment(MyPublicProfile.self) private var profile
    @Environment(MatchService.self) private var service: MatchService
    @Environment(MainRouter.self) private var mainRouter
  
    private let logger = Logger(subsystem: "com.WordRivalry", category: "GameResultsView")
    
    private var gameOutcome: GameOutcome {
        if gameResults.winner == profile.publicProfile.playerName {
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
                    oldRating: profile.publicProfile.eloRating,
                    newRating: profile.publicProfile.eloRating  + 20
                )
                
                Divider()
                PlayerScoresView(scores: gameResults.playerResults)
                    .onAppearAnimate(delay: 0.6)
                
                Spacer()
                Button {
                    showWordList = true
                } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .symbolEffect(.bounce.down, value: showWordList)
                        .scaleEffect(2.5)
                }
                .onAppearAnimate(delay: 1.1)
                
                BasicButton(text: "Confirm") {
                    mainRouter.showTabScreen = true
                    BattleServerService.shared.disconnect()
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
        .blurredOverlay(isPresented: $showWordList) {
            VStack {
                WordHistoryTimelineView(playerResults: gameResults.playerResults)
                    .padding()
                
                CompleteWordListView(completeWordList: completeWordList)
            }
        }
        .logLifecycle(viewName: "GameResultsView")
    }
}

#Preview {
    ViewPreview {
        ZStack {
            Text("Hi")
        }
        .fullScreenCover(isPresented: .constant(true)) {
            GameView()
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
                        ),
                        duration: 90,
                        completeWordList: [
                            "a",
                            "abbe",
                            "abbes",
                            "aberra",
                            "aberras",
                            "aberrat",
                            "aberrates",
                            "aberre",
                            "aberres",
                            "abeti",
                            "abetir",
                            "abetira",
                            "abetiras",
                            "are",
                            "ares",
                            "arete",
                            "aretes",
                            "arret",
                            "arrete",
                            "arretes",
                            "arrets",
                            "art",
                            "artel",
                            "artels",
                            "arts",
                            "as",
                            "atre",
                            "ave",
                            "avera",
                            "averas",
                            "averat",
                            "averates",
                            "avers",
                            "averti",
                            "avertir",
                            "avertira",
                            "avertiras",
                            "bar",
                            "barete",
                            "verras",
                            "verrat",
                            "verrats",
                            "verre",
                            "verres",
                            "vers",
                            "verste",
                            "verstes",
                            "vert",
                            "verte",
                            "vertes",
                            "verts",
                            "veste",
                            "vestes",
                            "vet",
                            "vete",
                            "vetes",
                            "vetir",
                            "vetira",
                            "vetiras",
                            "vets"
                        ],
                        board: Board(
                            rows: 4,
                            cols: 4,
                            initialValue: LetterTile(
                                letter: "",
                                value: 0,
                                letterMultiplier: 1,
                                wordMultiplier: 1)
                        )
                    )
                }
        }
    }
}
