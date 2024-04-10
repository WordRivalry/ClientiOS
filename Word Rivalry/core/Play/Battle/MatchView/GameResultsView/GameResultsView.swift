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
    @Environment(PublicProfile.self) private var profile: PublicProfile
    @Environment(MatchService.self) private var service: MatchService
    @Environment(BattleOrchestrator.self) private var battleOrchestrator: BattleOrchestrator
    private let logger = Logger(subsystem: "com.WordRivalry", category: "GameResultsView")
    
    private var gameOutcome: GameOutcome {
        if gameResults.winner == profile.playerName {
            GameOutcome.victory
        } else if gameResults.winner.isEmpty {
            GameOutcome.draw
        } else {
            GameOutcome.defeat
        }
    }
    
    var body: some View {
        // Use a ZStack to layer content and buttons
        ZStack {
            // Main content in a VStack for alignment
            VStack(spacing: 20) {
                Spacer()
                OutcomeView(gameOutcome: gameOutcome)
                    .padding(.top, 40)
                
                RankUpdateView(
                    oldRating: battleOrchestrator.eloService.defaultEloRating,
                    newRating: profile.eloRating
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
                
                
                BasicDissmiss(text: "Confirm") {
                 //   battleOrchestrator.eloService.attributePoint()
                }
                    .scaleEffect(0.8)
                    .padding()
                    .onAppearAnimate(delay: 1.2)
                Spacer()
            }
            
            // Position the 'Confirm' button at the bottom
            VStack {
                
            }
        }
        .onAppear {
            self.logger.debug("* GameResultsView Appeared *")
        }.onDisappear {
            self.logger.debug("* GameResultsView Disappeared *")
        }
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
    }
}

#Preview {
    
    ModelContainerPreview {
        previewContainer
    } content: {
        ZStack {
            Text("Hi")
        }
        .fullScreenCover(isPresented: .constant(true)) {
            GameView(gameModel: GameModel(), opponentProfile: PublicProfile.preview)
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
                            "bareter",
                            "baretes",
                            "barre",
                            "barree",
                            "barrees",
                            "barres",
                            "barri",
                            "barrit",
                            "barrites",
                            "bas",
                            "base",
                            "basee",
                            "basees",
                            "baser",
                            "bat",
                            "bate",
                            "batee",
                            "batees",
                            "bater",
                            "bates",
                            "bati",
                            "batir",
                            "bats",
                            "bave",
                            "baver",
                            "bavera",
                            "baveras",
                            "baves",
                            "bea",
                            "beas",
                            "beat",
                            "beate",
                            "beates",
                            "beats",
                            "bee",
                            "beer",
                            "beera",
                            "beeras",
                            "bees",
                            "bel",
                            "ber",
                            "bers",
                            "beta",
                            "betas",
                            "bete",
                            "betel",
                            "betels",
                            "betes",
                            "ebat",
                            "ebats",
                            "erra",
                            "erras",
                            "errat",
                            "errates",
                            "erre",
                            "erres",
                            "es",
                            "est",
                            "ester",
                            "et",
                            "ete",
                            "etes",
                            "etira",
                            "etiras",
                            "etire",
                            "etires",
                            "etre",
                            "etres",
                            "ira",
                            "iras",
                            "ire",
                            "ires",
                            "irreel",
                            "irreels",
                            "itera",
                            "iteras",
                            "le",
                            "les",
                            "lest",
                            "lesta",
                            "lestas",
                            "leste",
                            "lester",
                            "lestera",
                            "lesteras",
                            "lestes",
                            "let",
                            "lev",
                            "leva",
                            "leve",
                            "lever",
                            "levera",
                            "leveras",
                            "leves",
                            "ra",
                            "ras",
                            "rase",
                            "rasee",
                            "rasees",
                            "rat",
                            "rate",
                            "ratee",
                            "ratees",
                            "ratel",
                            "ratels",
                            "rater",
                            "rates",
                            "rats",
                            "re",
                            "rea",
                            "reas",
                            "reat",
                            "reates",
                            "rebab",
                            "rebabs",
                            "rebat",
                            "rebati",
                            "rebatir",
                            "rebats",
                            "ree",
                            "reel",
                            "reels",
                            "reer",
                            "reera",
                            "reeras",
                            "rees",
                            "resta",
                            "restas",
                            "reste",
                            "rester",
                            "restera",
                            "resteras",
                            "restes",
                            "retira",
                            "retiras",
                            "retire",
                            "retires",
                            "rets",
                            "reva",
                            "reve",
                            "rever",
                            "revera",
                            "reveras",
                            "reverat",
                            "revers",
                            "reves",
                            "revet",
                            "revetir",
                            "revetira",
                            "revetiras",
                            "revets",
                            "ri",
                            "rira",
                            "riras",
                            "rire",
                            "rires",
                            "rit",
                            "rite",
                            "rites",
                            "sa",
                            "sari",
                            "sati",
                            "satire",
                            "satires",
                            "se",
                            "sel",
                            "sels",
                            "sera",
                            "serra",
                            "serras",
                            "serrat",
                            "serrate",
                            "serrates",
                            "serre",
                            "serres",
                            "sers",
                            "sert",
                            "serte",
                            "sertes",
                            "serti",
                            "sertir",
                            "sertira",
                            "sertiras",
                            "ses",
                            "set",
                            "sets",
                            "seve",
                            "seves",
                            "star",
                            "stase",
                            "stera",
                            "steras",
                            "stras",
                            "ta",
                            "tabes",
                            "tare",
                            "taree",
                            "tarees",
                            "tares",
                            "tari",
                            "tarir",
                            "tas",
                            "te",
                            "tee",
                            "tees",
                            "tel",
                            "tels",
                            "terra",
                            "terras",
                            "terre",
                            "terres",
                            "terri",
                            "tes",
                            "tir",
                            "tira",
                            "tiras",
                            "tire",
                            "tiree",
                            "tirees",
                            "tires",
                            "tirs",
                            "trabe",
                            "trabee",
                            "trabees",
                            "trabes",
                            "tres",
                            "treve",
                            "treves",
                            "tri",
                            "va",
                            "ver",
                            "veratre",
                            "veratres",
                            "verite",
                            "verites",
                            "verra",
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
        .environment(PublicProfile.preview)
        .environment(MatchService(
            localProfile: PublicProfile.preview,
            modeType: .NORMAL,
            gameSessionUUID: "324234",
            opponentUsername: "Bluehouse"
        ))
    }
}
