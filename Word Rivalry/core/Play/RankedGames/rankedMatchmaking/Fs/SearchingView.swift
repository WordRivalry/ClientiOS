//
//  SearchView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

struct SearchingView: View {
    var viewModel: SearchModel
    @Environment(\.dismiss) var dismiss
    
    @State private var textScale = 0.1 // Start scaled down
    @State private var textOpacity = 0.0 // Start almost invisible
    
    // Define specific animation durations for better control
    let textAppearDuration = 0.5
    let blinkDuration = 3.0
    
    var body: some View {
        ZStack {
            AnimatedCirclesView()
            
            VStack {
                Text(viewModel.modeType.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Spacer()
                
                // "Searching" text with varying opacity
                Text("Searching")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .padding()
                    .opacity(textOpacity)
                    .scaleEffect(textScale)
                    .shadow(radius: 10)
                    .onAppear {
                        // Pop effect: scale up then down
                        withAnimation(.easeOut(duration: textAppearDuration)) {
                            textScale = 1.2
                            textOpacity = 1.0
                        }
                        withAnimation(.easeOut(duration: textAppearDuration).delay(textAppearDuration)) {
                            textScale = 1.0
                        }
                        // Start blinking after initial animations
                        DispatchQueue.main.asyncAfter(deadline: .now() + textAppearDuration * 2) {
                            withAnimation(.easeInOut(duration: blinkDuration / 2).repeatForever(autoreverses: true)) {
                                textOpacity = 0.2 // Adjust opacity for the blinking effect
                            }
                        }
                    }
                
                Spacer()
                
                BasicButton(text: "Cancel Search") {
                    do {
                        try viewModel.cancelSearch()
                    } catch {
                        print("Error occurred: \(error)")
                    }
                    dismiss()
                }
                .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SearchingView(viewModel: SearchModel(modeType: ModeType.NORMAL))
}
