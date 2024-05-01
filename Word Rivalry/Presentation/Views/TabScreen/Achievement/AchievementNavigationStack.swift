//
//  AchievementNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI

struct AchievementNavigationStack: View {
    
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Normal")
            
            Divider()
            
            BasicButton(text: "All time points") {
             //   fsCoordinator.presentModal(.totalPoints)
            }
            BasicButton(text: "All time achievement") {
             //   fsCoordinator.presentModal(.achievementPoints)
            }
            
            Spacer()
        
        }
        .infinityFrame()
     //   .fullScreenCoverCoordinating(coordinator: fsCoordinator)
        .background(
            Image("bg")
                .resizable()
                .ignoresSafeArea()
        )
        
    }
}

#Preview {
    ViewPreview {
        AchievementNavigationStack()
    }
}
