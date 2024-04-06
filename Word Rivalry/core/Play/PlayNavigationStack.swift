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
    var body: some View {
        NavigationStack {
            RankedGamesView()
                .navigationTitle("Battle")
                .navigationBarTitleDisplayMode(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
        }
    }
}

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
    ModelContainerPreview {
        previewContainer
    } content: {
        PlayNavigationStack()
            .environment(Profile.preview)
    }
}
