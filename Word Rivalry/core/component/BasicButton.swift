//
//  GlassyButton.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

// Reusable GlassyButton component
struct BasicButton<Destination: View>: View {
    var text: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(text)
                .frame(width: 350)
                .foregroundColor(.primary)
                .font(.title3.bold())
                .padding(.vertical, 22)
                .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    BasicButton(text: "Hi", destination: Text("Hi"))
}
