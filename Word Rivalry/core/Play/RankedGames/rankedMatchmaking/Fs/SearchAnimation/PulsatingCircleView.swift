//
//  PulsatingCircleView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI


struct PulsatingCircleView: View {
    var animatePulse: Bool
    let animationDuration: Double

    var body: some View {
        Circle()
            .stroke(Color.blue.opacity(0.5), lineWidth: 5)
            .scaleEffect(animatePulse ? 1.5 : 1)
            .opacity(animatePulse ? 0 : 1)
            // Ensure the animation only starts once `animatePulse` is true
            .animation(animatePulse ? Animation.easeOut(duration: animationDuration).repeatForever(autoreverses: false) : nil, value: animatePulse)
            .frame(width: 200, height: 200)
    }
}

#Preview {
    PulsatingCircleView(animatePulse: false, animationDuration: 1)
}
