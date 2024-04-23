//
//  BlinkingEffectModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

struct BlinkingEffectModifier: ViewModifier {
    @State private var isVisible = true
    var duration: Double = 0.7          // Default duration
    var minOpacity: Double = 0.0        // Default minimum opacity
    var maxOpacity: Double = 1.0        // Default maximum opacity
    var repeatAnimation: Bool = true    // Default repeat
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? maxOpacity : minOpacity)
            .onAppear {
                guard repeatAnimation else { return }
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: true)) {
                    isVisible.toggle()
                }
            }
    }
}

extension View {
    func blinkingEffect(duration: Double = 0.7, minOpacity: Double = 0.0, maxOpacity: Double = 1.0, repeatAnimation: Bool = true) -> some View {
        self.modifier(BlinkingEffectModifier(duration: duration, minOpacity: minOpacity, maxOpacity: maxOpacity, repeatAnimation: repeatAnimation))
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Default Blinking")
            .blinkingEffect()
        
        Text("Slow Blinking")
            .blinkingEffect(duration: 1.5)
        
        Text("Quick Fading")
            .blinkingEffect(duration: 0.3, minOpacity: 0.3, maxOpacity: 0.9)
        
        Text("Non-Repeating Blink")
            .blinkingEffect(repeatAnimation: false)
        
        Image(systemName: "star.fill")
            .resizable()
            .frame(width: 50, height: 50)
            .blinkingEffect(duration: 0.5, minOpacity: 0.1, maxOpacity: 0.5)
    }
}
