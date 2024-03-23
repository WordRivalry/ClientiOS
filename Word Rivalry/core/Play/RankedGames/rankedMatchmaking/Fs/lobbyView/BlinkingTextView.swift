//
//  BlinkingTextView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

struct BlinkingTextView: View {
    var text: String
    @Binding var isBlinking: Bool
    
    var body: some View {
        Text(text)
            .opacity(isBlinking ? 1.0 : 0.2)
            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isBlinking)
            .onAppear { self.isBlinking = true }
    }
}

#Preview {
    BlinkingTextView(text: "Hello, World!", isBlinking: .constant(false))
}
