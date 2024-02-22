//
//  IntroView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import SwiftUI

struct IntroView: View {
    @State private var intros: [Intro] = []
    var onFinished: () -> Void
    @State var activeIntro: Intro?
    @State private var isAnimating: Bool = false
    @State private var animationTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            bubble
        }
        .ignoresSafeArea()
        .onAppear {
            intros = [
                .init(
                    text: "Welcome!",
                    textColor: Color.accentColor,
                    circleColor:Color.accentColor
                ),
                .init(
                    text: "Enjoy!",
                    textColor: Color.accentColor,
                    circleColor: Color.accentColor
                ),
                .init(
                    text: "",
                    textColor: Color.accentColor,
                    circleColor: Color.accentColor
                ),
            ]
        }
    }
    
    var bubble: some View {
        VStack(spacing: 0) {
            if let activeIntro {
                if isAnimating {
                    Rectangle()
                        .fill(.clear)
                        .blur(radius: 3.0)
                        .overlay {
                            Circle()
                                .fill(activeIntro.circleColor)
                                .frame(width: 38, height: 38)
                                .background {
                                    Text(activeIntro.text)
                                        .font(.largeTitle)
                                        .foregroundStyle(activeIntro.textColor)
                                        .frame(width: textSize(activeIntro.text))
                                        .offset(x: textSize(activeIntro.text) / 2)
                                        // Moving Text based on text Offset
                                        .offset(x: activeIntro.textOffset)
                                        .mask(
                                            Rectangle()
                                                .offset(x: -(textSize(activeIntro.text) / 2 ) - 20)
                                        )
                                }
                                // Moving Circle in the Opposite Direction
                                .offset(x: -activeIntro.circleOffset)
                        }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            isAnimating = true
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    func startAnimation() {
        animationTask?.cancel()
        animationTask = Task {
            if activeIntro == nil {
                activeIntro = intros.first
                let nanoSeconds = UInt64(1_000_000_000 * 0.25)
                
                try? await Task.sleep(nanoseconds: nanoSeconds)
            }
            animate(0, false)
        }
    }
    
    func stopAnimation() {
        animationTask?.cancel()
        isAnimating = false
    }
    
    /// Animating Intros
    func animate(_ index: Int, _ loop: Bool = true) {
        
        if !isAnimating {
            return
        }
        
        
        if intros.indices.contains(index + 1) {
            /// Updating Text and Text Color
            activeIntro?.text = intros[index].text
            activeIntro?.textColor = intros[index].textColor
            
            /// Animating Offsets
            withAnimation(.snappy(duration: 1), completionCriteria: .removed) {
                activeIntro?.textOffset = -(textSize(intros[index].text) + 20)
                activeIntro?.circleOffset = -(textSize(intros[index].text) + 20) / 2
            } completion: {
                /// Resetting the Offset with Next Slide Color Change
                withAnimation(.snappy(duration: 0.8), completionCriteria: .logicallyComplete) {
                    activeIntro?.textOffset = 0
                    activeIntro?.circleOffset = 0
                    activeIntro?.circleColor = intros[index + 1].circleColor
                 //   activeIntro?.bgColor = intros[index + 1].bgColor
                } completion: {
                    /// Going to Next Slide
                    /// Simply Recursion
                    animate(index + 1, loop)
                }
            }
        } else {
            /// Looping
            /// If looping Applied, Then Reset the Index to 0
            if loop {
                animate(0, loop)
            } else {
                isAnimating = false
                onFinished()
            }
        }
    }
    
    /// Fetching Text Size based on Fonts
    func textSize(_ text: String) -> CGFloat {
        return NSString(string: text).size(withAttributes:
                                            [.font: UIFont.preferredFont(forTextStyle:
                                                    .largeTitle)]).width
    }
}

#Preview {
    IntroView(onFinished: {})
}

/// Intro Model
struct Intro: Identifiable {
    var id: UUID = .init()
    var text: String
    var textColor: Color
    var circleColor: Color
    var circleOffset: CGFloat = 0
    var textOffset: CGFloat = 0
}

