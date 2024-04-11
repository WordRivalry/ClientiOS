//
//  GameCenterView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI
import GameKit

// Define an enumeration to specify the dashboard state
enum GameCenterViewState {
    case dashboard
    case playerProfile
    case leaderboards
    case specificLeaderboard(leaderboardID: String, playerScope: GKLeaderboard.PlayerScope, timeScope: GKLeaderboard.TimeScope)
    case achievements
}

// SwiftUI View that wraps GKGameCenterViewController
struct GameCenterView: UIViewControllerRepresentable {
    @Binding var isVisible: Bool
    var state: GameCenterViewState
    var gameCenterDelegate: GKGameCenterControllerDelegate?
    
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let viewController = GKGameCenterViewController()
        viewController.gameCenterDelegate = context.coordinator
        
        // Configure the view controller based on the desired state
        switch state {
        case .dashboard:
            viewController.viewState = .default
        case .playerProfile:
            viewController.viewState = .localPlayerProfile
        case .leaderboards:
            viewController.viewState = .leaderboards
        case .specificLeaderboard(let leaderboardID, let playerScope, let timeScope):
            viewController.leaderboardIdentifier = leaderboardID
            viewController.leaderboardTimeScope = timeScope
           // viewController.leaderboardPlayerScope = playerScope
        case .achievements:
            viewController.viewState = .achievements
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        // No need to update the UIViewController in this context
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        var parent: GameCenterView
        
        init(_ parent: GameCenterView) {
            self.parent = parent
        }
        
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            // Dismiss the Game Center view when the player is done
            parent.isVisible = false
        }
    }
}

#Preview {
    GameCenterView(isVisible: .constant(true), state: .achievements)
}
