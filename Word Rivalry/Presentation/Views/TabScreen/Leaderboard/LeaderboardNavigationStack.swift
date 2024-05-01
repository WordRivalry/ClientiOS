//
//  LeaderboardNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import SwiftUI

enum LeaderboardEnum: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case overall = "Overall"
    case arena = "Arena"
    case achievements = "Achievements"
    
    var imageName: String {
         "OverallLeaderboard" // Assuming the same image for simplicity; adjust if needed
    }
}


extension Color {
    static let lightGreen = Color(
        red: 151 / 255,
        green: 168 / 255,
        blue: 0 / 255
    )
    static let fontColor =  Color(
        red: 118 / 255.0,
        green: 100 / 255.0,
        blue: 74 / 255.0
    )
    static let lightTint = Color(
        red: 219 / 255.0,
        green: 220 / 255.0,
        blue: 153 / 255.0
    )
}

struct LeaderboardNavigationStack: View {
    @State private var selectedLeaderboard: LeaderboardEnum = .overall
    @State private var arenaMode: String = "1v1" // Default mode

    
    var body: some View {
        VStack(spacing: 0) { // Zero to remove any automatic spacing
            headerView
            tabBar
            Spacer()
            contentView
        }
        .infinityFrame()
        .background(
            Image("bg")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
        )
    }
    
    private var headerView: some View {
        HStack {
            Image(selectedLeaderboard.imageName)
                .resizable()
                .frame(width: 100, height: 100)
            Text(selectedLeaderboard.rawValue)
                .bold()
                .font(.largeTitle)
            Spacer()
        }
        .padding(.horizontal)
        .background(Color.lightGreen)
    }
    
    private var tabBar: some View {
        HStack {
            ForEach(LeaderboardEnum.allCases, id: \.self) { tab in
                Spacer()
                Text(tab.rawValue)
                    .bold()
                    .foregroundColor(selectedLeaderboard == tab ? .lightGreen : .fontColor)
                    .padding(.vertical, 10)
                    .overlay(
                        Rectangle()
                            .frame(height: 5)
                            .foregroundColor(selectedLeaderboard == tab ? .lightGreen : .lightTint),
                        alignment: .bottom
                    )
                    .onTapGesture {
                        selectedLeaderboard = tab
                    }
                Spacer()
            }
        }
        .background(.white)
    }
    
    private var contentView: some View {
            Group {
                switch selectedLeaderboard {
                case .overall:
                   OverallLeaderboardView()
                case .arena:
                    VStack {
                        Picker("Mode", selection: $arenaMode) {
                            Text("1v1").tag("1v1")
                            Text("2v2").tag("2v2")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                        ArenaLeaderboardView(mode: arenaMode)
                    }
                case .achievements:
                    AchievementsLeaderboardView()
                }
            }
            .padding(.top)
        }
}

#Preview {
    ViewPreview {
        LeaderboardNavigationStack()
    }
}
