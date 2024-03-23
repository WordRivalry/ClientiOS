//
//  PlayNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

enum PlayTab {
    case Multiplayer, SoloAdventures
}

struct PlayNavigationStack: View {
    @State private var selectedTab: PlayTab = .Multiplayer

    var body: some View {
        NavigationStack {
            VStack {
                // Tabs for selection
                Picker("Select", selection: $selectedTab) {
                    Text("Multiplayer").tag(PlayTab.Multiplayer)
                    Text("Solo Adventures").tag(PlayTab.SoloAdventures)
                }
                .pickerStyle(.palette)
                .padding()
                
                Spacer()

                // Content based on selection
                switch selectedTab {
                case .Multiplayer:
                    VStack(spacing: 20) {
                        BasicNavButton(text: "Rank", destination: RankedGamesView())
                        BasicNavButton(text: "Quick Duel", destination: RankedGamesView())
                    }
                case .SoloAdventures:
                    BasicNavButton(text: "Heroic Challenges", destination: DailiesView())
                }
                Spacer()
            }
            .navigationTitle("Play")
            .navigationBarTitleDisplayMode(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
        }
    }
}


//
//struct MatchmakingButtonView<Destination: View>: View {
//    var text: String
//    var destination: Destination
//    var imageName: String // Name of the image to use as background
//
//    var body: some View {
//        NavigationLink(destination: destination) {
//            ZStack {
//                // Image as the background
//                Image(imageName)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .cornerRadius(8)
//                    .overlay(
//                        // Darken the image slightly to ensure text readability
//                        LinearGradient(gradient: Gradient(colors: [.black.opacity(0.3), .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
//                    )
//                
//                // Game mode text
//                Text(text)
//                    .bold()
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//            }
//        }
//        .frame(height: 100) // Adjust based on your design needs
//        .cornerRadius(8)
//        .padding(.horizontal)
//        .contentShape(Rectangle())
//    }
//}


struct MatchmakingButtonView<Destination: View>: View {
    var text: String
    var destination: Destination

    var body: some View {
        
        
        
        NavigationLink(destination: destination) {
            Text(text)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}



// Placeholder view for Dailies, replace with your actual view
struct DailiesView: View {
    var body: some View {
        Text("Daily Challenges")
    }
}


#Preview {
    PlayNavigationStack()
}
