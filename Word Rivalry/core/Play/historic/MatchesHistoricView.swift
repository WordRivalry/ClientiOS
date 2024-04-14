//
//  MatchesHistoricView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-13.
//

import SwiftUI

struct MatchesHistoricView: View {
    @Environment(SYPData<MatchHistoric>.self) private var sypData: SYPData<MatchHistoric>
    
    var body: some View {
        VStack {
            header
            listView(matchHistoric: sypData.fetchItems())
        }
        .logLifecycle(viewName: "MatchesHistoricView")
    }
    
    @ViewBuilder  
    private var header: some View {
        Text("Match historic")
            .font(.largeTitle)
    }
    
    @ViewBuilder
    private func listView(matchHistoric: [MatchHistoric]) -> some View {
        ScrollView {
            LazyVStack {
                ForEach(matchHistoric.indices, id: \.self) { index in
                    GameHistoryRowView(gameHistory: matchHistoric[index])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .coordinateSpace(.named("LeaderboardScroll"))
    }
}

#Preview {
    ViewPreview {
        MatchesHistoricView()
    }
}
