//
//  MatchesHistoricView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-13.
//

import SwiftUI
import SwiftData

struct MatchesHistoricView: View {
    @Query var matchHistoric: [MatchHistoric]
    
    var body: some View {
        VStack {
            header
            listView(matchHistoric: matchHistoric)
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
                    MatchDetailsRowView(matchDetails: matchHistoric[index])
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
