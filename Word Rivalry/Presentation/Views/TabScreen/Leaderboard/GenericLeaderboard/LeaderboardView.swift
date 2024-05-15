//
//  LeaderboardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-08.
//

import SwiftUI
import GameKit

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct LeaderboardView<ViewModel: LeaderboardViewModel, Content: View>: View {
    @Environment(LocalUser.self) var localUser
    @State var gkLocalPlayer = GKLocalPlayer.local
    
    var viewModel: ViewModel
    var content: (LeaderboardEntry) -> Content
    
    @State private var showMyProfileBottomRow = true
    
    var body: some View {
        JITDataView(for: viewModel) {
            LeaderboardLoadingView()
        } content: {
            VStack {
                if let leaderboard = viewModel.leaderboard {
                    
                    listView(entries: leaderboard.topPlayers)
                    Spacer()
                    if showMyProfileBottomRow {
                        if let localEntry = leaderboard.localEntry {
                            localPlayerRow(localPlayerEntry: localEntry)
                        }
                    }
                    lastUpdatedView
                }
            }
        }
        .logLifecycle(viewName: "LeaderboardView")
    }
    
    @ViewBuilder
    private func listView(entries: [LeaderboardEntry]) -> some View {
        
        
        VisibilityTrackingScrollView(action: handleVisibilityChanged) {
            LazyVStack {
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 10)
                    .background(.clear)
                    .foregroundStyle(.clear)
                
                ForEach(entries.indices, id: \.self) { index in
                    LeaderboardRow(
                        rank: index + 1,
                        player: entries[index].user,
                        username: entries[index].displayName,
                        content: content(entries[index])
                    )
                    .padding(.horizontal)
                    .trackVisibility(id: "\(entries[index].displayName)")
                    .border(entries[index].displayName == gkLocalPlayer.displayName ? Color.accentColor : Color.clear, width: 4)
                }
                
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 100)
                    .background(.clear)
                    .foregroundStyle(.clear)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .coordinateSpace(.named("LeaderboardScroll"))
    }
    
    func handleVisibilityChanged(_ id: String, change: VisibilityChange, tracker: VisibilityTracker<String>) {
        switch change {
        case .shown:
            if id == GKLocalPlayer.local.displayName {
                DispatchQueue.main.async {
                    self.showMyProfileBottomRow = false
                }
            }
            
        case .hidden:
            if id == GKLocalPlayer.local.displayName {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        self.showMyProfileBottomRow = true
                    }
                    
                }
            }
        }
    }
    
    @ViewBuilder
    private func localPlayerRow(localPlayerEntry: LeaderboardEntry) -> some View {
        LeaderboardRow(
            rank: localPlayerEntry.rank + 1,
            player: localUser.user,
            username: localPlayerEntry.displayName,
            content: content(localPlayerEntry)
        )
        .padding(.horizontal)
        .border(Color.accentColor, width: 4)
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var lastUpdatedView: some View {
        Group {
            if let lastUpdate = viewModel.leaderboard?.updateDate {
                Text("Last updated: \(lastUpdate.formatted())")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}


#Preview {
    
    LeaderboardView(
        viewModel: .preview,
        content: { entry in
            Text(entry.formattedScore)
        }
    )
}
