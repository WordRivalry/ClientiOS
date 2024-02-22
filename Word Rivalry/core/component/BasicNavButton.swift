//
//  GlassyButton.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

// Reusable GlassyButton component
struct BasicNavButton<Destination: View>: View {
    var text: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(text)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(8)
            
//                .frame(width: 350)
//                .foregroundColor(.primary)
//                .font(.title3.bold())
//                .padding(.vertical, 22)
//                .background(.ultraThinMaterial)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    BasicNavButton(text: "Hi", destination: Text("Hi"))
}
