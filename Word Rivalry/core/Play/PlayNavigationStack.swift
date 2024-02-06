//
//  PlayNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI

struct PlayNavigationStack: View {
    // Simulated data for countdown timer to next tournament
    let nextTournament = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                MatchmakingButtonView(text: "Rank ", destination: RankedMatchmakingView())
                MatchmakingButtonView(text: "Quick Duel", destination: RankedMatchmakingView())
                MatchmakingButtonView(text: "Custom", destination:PlayVsFriendMatchmakingView())
                MatchmakingButtonView(text: "Heroic Challenges", destination: DailiesView())
            }
            .navigationTitle("World of WordRivalry")
            .navigationBarTitleDisplayMode(.large)
            .padding()
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
