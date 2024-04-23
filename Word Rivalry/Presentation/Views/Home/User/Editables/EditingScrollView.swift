//
//  EditingScrollView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-05.
//

import Foundation
import SwiftUI


struct EditingScrollView<Content: View>: View {
    let regularNum: Int
    let compactNum: Int
    let columns: [GridItem]
    let content: Content

    
    @Environment(\.verticalSizeClass) var verticalSizeClass

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                content
                    .containerRelativeFrame(.vertical,
                                            count: verticalSizeClass == .regular ? regularNum : compactNum,
                                            spacing: 0
                    )
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .scaleEffect(phase.isIdentity ? 1 : 0.3)
                           // .offset(y: phase.isIdentity ? 0 : -25)
                    }
            }
                .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .contentMargins(10, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
    
    init(
        regularNum: Int,
        compactNum: Int,
        columnsCount: Int,
        @ViewBuilder content: () -> Content
    ) {
        self.regularNum = regularNum
        self.compactNum = compactNum

        self.columns = Array(
            repeating: .init(.flexible(), spacing: 20),
            count: columnsCount
        )

   
        self.content = content()
    }
}

