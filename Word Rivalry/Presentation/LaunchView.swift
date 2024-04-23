//
//  LaunchView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-23.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack {
            Text("Word Rivalry")
            Text("Unleashing Words, Unveiling Minds")
            loadingText
        }
    }
    
    @ViewBuilder
    var loadingText: some View {
        Text("Loading...")
            .blinkingEffect()
    }
}

#Preview {
    LaunchView()
}
