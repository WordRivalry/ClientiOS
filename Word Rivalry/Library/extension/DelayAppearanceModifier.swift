//
//  DelayAppearanceModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import SwiftUI

struct DelayAppearanceModifier: ViewModifier {
    @State var shouldDisplay = false
    
    let delay: Double
    
    func body(content: Content) -> some View {
        render(content)
            .onAppear {
                Task { @MainActor in
                    try? await Task.sleep(until: .now + .seconds(delay))
                    self.shouldDisplay = true
                }
            }
    }
    
    @ViewBuilder
    private func render(_ content: Content) -> some View {
        if shouldDisplay {
            content
        } else {
            content
                .hidden()
        }
    }
}

public extension View {
    func delayAppearance(bySeconds seconds: Double) -> some View {
        modifier(DelayAppearanceModifier(delay: seconds))
    }
}
