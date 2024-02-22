//
//  PlayNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

//struct PlayNavigationStack: View {
//    // Simulated data for countdown timer to next tournament
//    let nextTournament = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                BasicNavButton(text: "Rank ", destination: RankedMatchmakingView())
//                BasicNavButton(text: "Quick Duel", destination: RankedMatchmakingView())
//                BasicNavButton(text: "Custom", destination:PlayVsFriendMatchmakingView())
//                BasicNavButton (text: "Heroic Challenges", destination: DailiesView())
//            }
//            .navigationTitle("Play")
//            .navigationBarTitleDisplayMode(.large)
//            .padding()
//        }
//    }
//}

enum PlayTab {
    case pvp, solo, training, custom
}

struct PlayNavigationStack: View {
    @State private var selectedTab: PlayTab = .pvp

    var body: some View {
        NavigationStack {
            VStack {
                // Tabs for selection
                Picker("Select", selection: $selectedTab) {
                    Text("PVP").tag(PlayTab.pvp)
                    Text("Solo").tag(PlayTab.solo)
                    Text("Training").tag(PlayTab.training)
                    Text("Custom").tag(PlayTab.custom)
                }
                .pickerStyle(.palette)
                .padding()
                
                Spacer()

                // Content based on selection
                switch selectedTab {
                case .pvp:
                    VStack(spacing: 20) {
                        BasicNavButton(text: "Rank", destination: RankedMatchmakingView())
                        BasicNavButton(text: "Quick Duel", destination: RankedMatchmakingView())
                    }
                case .solo:
                    BasicNavButton(text: "Heroic Challenges", destination: DailiesView())
                case .training:
                    // TrainingPageView() // Implement your training view
                    Text("Training Page Content")
                case .custom:
                    // CreateCustomPageView() // Implement your create custom view
                    Text("Create Custom Page Content")
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
