//
//  GameResultsView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

struct GameResultsView: View {
    var gameResults: GameResults
    var duration: Int
    var completeWordList: [String]
    var board: Board<LetterTile> // Used to display a word path when user wants to see it
    
    var sortedScores: [PlayerResults] {
        gameResults.getScores().sorted(by: { $0.score < $1.score })
     }
    

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Game Outcome
                Text("Game Recap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Winner and Scores
                HStack {
                    VStack(alignment: .leading) {
                        Text("Winner: \(gameResults.getWinner())")
                            .font(.title2)
                            .fontWeight(.semibold)
                        ForEach(sortedScores) { scoreEntry in
                            Text("\(scoreEntry.playerName): \(scoreEntry.score) points")
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                // Word Lists
                Group {
                    WordListView(title: "My Words (\(myWordFound.count))", wordScores: myWordFound)
                    WordListView(title: "Opponent's Words (\(opponentWordFound.count))", wordScores: opponentWordFound)
                }
                
                // Complete Word List
                VStack(alignment: .leading) {
                    Text("Complete Word List")
                        .font(.headline)
                        .padding(.bottom, 5)
                    ForEach(completeWordList, id: \.self) { word in
                        Text(word)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct WordListView: View {
    let title: String
    let wordScores: [String: Int]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
            ForEach(wordScores.sorted(by: { $0.value > $1.value }), id: \.key) { word, score in
                HStack {
                    Text(word)
                    Spacer()
                    Text("\(score) pts")
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    GameResultsView(
        gameResults: GameResults(
            winner: "Lighthouse",
            scores: [
                PlayerResults(playerName: "Lighthouse", score: 350, historic: []),
                PlayerResults(playerName: "Neytherland", score: 250, historic: [])
            ]),
        completeWordList: [ // Alphabetic order
            "Chat",
            "Dog",
            "Fish",
            "nage",
            "nageons",
            "nager",
            // ...
            "voiture",
            "voix"
        ],
        myWordFound: [
            "nage" : 50,
            "nageons": 100,
            "nager": 75,
            "voiture": 50,
            "voix": 25
        ],
        opponentWordFound: [
            "Chat": 50,
            "Dog": 50,
            "Fish": 75,
            "voiture": 50,
            "voix": 25
        ]
    )
}
