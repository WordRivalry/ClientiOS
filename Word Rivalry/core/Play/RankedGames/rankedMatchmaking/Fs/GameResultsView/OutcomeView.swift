//
//  GameSummaryView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-23.
//

import SwiftUI

enum GameOutcome {
    case victory
    case draw
    case defeat
}

struct OutcomeView: View {
    var gameOutcome: GameOutcome
  
    var body: some View {
        OutcomeBackgroundView(imageName: backgroundImageName) {
            switch gameOutcome {
            case .victory:
                victoryView
            case .draw:
                drawView
            case .defeat:
                defeatView
            }
        }
    }
    
    private var backgroundImageName: String {
        switch gameOutcome {
        case .victory:
            return "VictoryBackground"
        case .draw:
            return "DrawBackground"
        case .defeat:
            return "DefeatBackground"
        }
    }
    
    @ViewBuilder
    var victoryView: some View {
        VStack {
            ZStack {
                Image(systemName: "star.fill")
                    .scaleEffect(1.5)
                    .onAppearAnimate(animation: .bouncy(extraBounce: 0.2), delay: 0.1)
                    .onAppearAnimateOpacity(from: 0, delay: 1)
                    .onAppearAnimateOffset(from: CGSizeMake(0, -20), to: CGSizeMake(-50, 0), delay: 1.3)
                Image(systemName: "star.fill")
                    .scaleEffect(2)
                    .offset(x: 0, y: -25)
                    .onAppearAnimate(animation: .bouncy(extraBounce: 0.2), delay: 0.2)
                Image(systemName: "star.fill")
                    .scaleEffect(1.5)
                    .onAppearAnimate(animation: .bouncy(extraBounce: 0.2), delay: 0.3)
                    .onAppearAnimateOpacity(from: 0, delay: 1)
                    .onAppearAnimateOffset(from: CGSizeMake(0, -20), to: CGSizeMake(50, 0), delay: 1.3)
            }
            
            OutcomeMessageView(message: "Victory")
            
            Image(systemName: "star.fill")
                .offset(CGSize(width: 0, height: 25))
                .onAppearAnimate(animation: .bouncy(extraBounce: 0.2), delay: 0.4)
        }
    }
    
    @ViewBuilder
    var drawView: some View {
        VStack {
            Image(systemName: "star.fill")
                .scaleEffect(2)
                .onAppearAnimate(animation: .bouncy(extraBounce: 0.2), delay: 1.3)
                .onAppearAnimateOpacity(from: 0, delay: 1.3)
                .onAppearAnimateOffset(from: CGSizeMake(0, 0), to: CGSizeMake(0, -25), delay: 1.3)
             
            OutcomeMessageView(message: "Draw")
            
            Image(systemName: "star.fill")
                .offset(CGSize(width: 0, height: 25))
                .onAppearAnimate(animation: .bouncy(extraBounce: 0.2), delay: 0.4)
        }
    }
    
    @ViewBuilder
    var defeatView: some View {
        OutcomeMessageView(message: "Defeat")
    }
}

struct OutcomeMessageView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 60, weight: .bold))
            .onAppearAnimateScale(from: 0, to: 1, delay: 0.3)
            .onAppearAnimateOpacity(from: 0, to: 1, delay: 0.3)
            .onAppearAnimateOffset(from: CGSize(width: 0, height: 100), delay: 0.2)
            .onAppearAnimate(animation: .bouncy(extraBounce: 0.2), delay: 0.4)
    }
}


struct OutcomeBackgroundView<Content: View>: View {
    var imageName: String
    let content: Content
    
    init(imageName: String, @ViewBuilder content: () -> Content) {
        self.imageName = imageName
        self.content = content()
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .foregroundStyle(.clear)
            .frame(width: 300, height: 200)
            .overlay(
                Image(imageName)
                    .resizable()
                    .mask(content)
            )
            .shadow(radius: 10)
    }
}

#Preview {
    VStack{
        OutcomeView(gameOutcome: .victory)
        Spacer()
        Divider()
        Spacer()
        OutcomeView(gameOutcome: .draw)
        Spacer()
        Divider()
        Spacer()
        OutcomeView(gameOutcome: .defeat)
    }
}
