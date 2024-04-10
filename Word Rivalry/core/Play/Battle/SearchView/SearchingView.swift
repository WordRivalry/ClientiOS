//
//  SearchView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI
import os.log

struct SearchingView: View {
    private let logger = Logger(subsystem: "com.WordRivalry", category: "SearchingView")
    @State private var textScale = 0.1 // Start scaled down
    @State private var textOpacity = 0.0 // Start almost invisible
    @Environment(BattleOrchestrator.self) private var battleOrchestrator: BattleOrchestrator
    let textAppearDuration = 0.5
    let blinkDuration = 3.0
    
    init() {
        self.logger.debug("*** SearchingView INITIATED ***")
    }
    
    var body: some View {
        ZStack {
            AnimatedCirclesView()
            
            VStack {
                
                Text(battleOrchestrator.modeType.rawValue)
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
                
                BasicDissmiss(text: "Cancel") {
                    do {
                        try SearchService.shared.cancelSearch()
                        self.logger.debug("SearchView Dissmissed")
                    } catch {
                        self.logger.error("Error occurred: \(error)")
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            self.logger.debug("* SearchingView Appeared *")
        }.onDisappear {
            self.logger.debug("* SearchingView Disappeared *")
        }
    }
}

#Preview {
    return ModelContainerPreview {
        previewContainer
    } content: {
        SearchingView()
    }
}
