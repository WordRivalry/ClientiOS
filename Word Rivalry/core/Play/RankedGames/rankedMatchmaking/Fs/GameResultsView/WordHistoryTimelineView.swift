//
//  WordHistoryTimelineView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-23.
//

import SwiftUI

struct TimelineIndicatorView: View {
    var playerOneWords: [WordHistory] // Assuming WordHistory includes time and score
    var playerTwoWords: [WordHistory]
    var scale: CGFloat

    private let timelineDuration: CGFloat = 90 // seconds
    private let lineWidth: CGFloat = 2
    private let triangleSize: CGSize = CGSize(width: 20, height: 20)
    private let scoreOffset: CGFloat = 30 // Increase as needed for score visibility
    private let lineLength: CGFloat // Adjust based on your view's padding
    
    init(playerOneWords: [WordHistory], playerTwoWords: [WordHistory], scale: CGFloat) {
        self.playerOneWords = playerOneWords
        self.playerTwoWords = playerTwoWords
        self.scale = scale
        self.lineLength = (UIScreen.main.bounds.width - 40) * scale
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Timeline
                Line()
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: lineLength, height: lineWidth)
                    .background(Color.clear)
                
                // Player One Words
                ForEach(playerOneWords, id: \.word) { word in
                    VStack {
                        Triangle()
                            .fill(Color.blue)
                            .frame(width: triangleSize.width, height: triangleSize.height)
                        Text("\(word.score)")
                            .font(.caption)
                            .offset(y: -scoreOffset)
                    }
                    .position(x: positionForTime(time: Int(word.time)), y: geometry.size.height / 2 - triangleSize.height)
                }
                
                // Player Two Words
                ForEach(playerTwoWords, id: \.word) { word in
                    VStack {
                        Text("\(word.score)")
                            .font(.caption)
                            .offset(y: scoreOffset - triangleSize.height / 2)
                        Triangle()
                            .fill(Color.red)
                            .frame(width: triangleSize.width, height: triangleSize.height)
                            .rotationEffect(.degrees(180))
                    }
                    .position(x: positionForTime(time: Int(word.time)), y: geometry.size.height / 2 + triangleSize.height)
                }
            }
        }
        .frame(height: 100 * scale) // Adjust height based on your needs and scale
    }

    private func positionForTime(time: Int) -> CGFloat {
        // Calculate position based on time
        let timeFraction = CGFloat(time) / timelineDuration
        return timeFraction * lineLength
    }
}

struct WordHistoryTimelineView: View {
    var playerResults: [PlayerResult] // Assuming this includes both players
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            TimelineIndicatorView(
                playerOneWords: playerResults[0].historic,
                playerTwoWords: playerResults[1].historic,
                scale: scale
            )
            .gesture(MagnificationGesture().onChanged { value in
                self.scale = value
            })
        }
    }
}


// Define a simple line shape
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

// Define a triangle shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


struct TimelinePoint: Identifiable {
    let id = UUID()
    var time: Float // Example of a simple time representation
    var details: String // Details to show when tapped
}

#Preview {
    WordHistoryTimelineView(
        playerResults: [
            PlayerResult(
                playerName: "Lighthouse",
                playerEloRating: 1200,
                score: 350,
                historic: [
                    WordHistory(
                        word: "aberrates",
                        path: [[0, 0], [0, 1]],
                        time: 1, // at wich moment the word was played
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
//        board:  Board(
//            rows: 4,
//            cols: 4,
//            initialValue: LetterTile(
//                letter: "",
//                value: 0,
//                letterMultiplier: 1,
//                wordMultiplier: 1)
//        )
    )
}
