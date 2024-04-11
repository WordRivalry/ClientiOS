//
//  OnAppearAnimate.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-25.
//

import Foundation
import SwiftUI

//    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing))

extension View {
    
    func onAppearAnimate(animation: Animation? = .default, delay: Double = 0) -> some View {
        self.modifier(OnAppearAnimationModifier(animation: animation, delay: delay))
    }
    
    func onAppearAnimateOpacity(from initialOpacity: Double = 0, to finalOpacity: Double = 1, animation: Animation = .default, delay: Double = 0) -> some View {
        modifier(OpacityAnimationModifier(initialOpacity: initialOpacity, finalOpacity: finalOpacity, animation: animation, delay: delay))
    }
    
    func onAppearAnimateScale(from initialScale: CGFloat = 0.5, to finalScale: CGFloat = 1, animation: Animation = .default, delay: Double = 0) -> some View {
        modifier(ScaleAnimationModifier(initialScale: initialScale, finalScale: finalScale, animation: animation, delay: delay))
    }
    
    func onAppearAnimateOffset(from initialOffset: CGSize = CGSize(width: -100, height: 0), to finalOffset: CGSize = .zero, animation: Animation = .default, delay: Double = 0) -> some View {
        modifier(OffsetAnimationModifier(initialOffset: initialOffset, finalOffset: finalOffset, animation: animation, delay: delay))
    }
}

struct OnAppearAnimationModifier: ViewModifier {
    var animation: Animation? = .default
    var delay: Double
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(self.animation) {
                        isVisible = true
                    }
                }
            }
    }
}

struct OpacityAnimationModifier: ViewModifier {
    var initialOpacity: Double
    var finalOpacity: Double
    var animation: Animation
    var delay: Double
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? finalOpacity : initialOpacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(animation) {
                        isVisible = true
                    }
                }
            }
    }
}

struct ScaleAnimationModifier: ViewModifier {
    var initialScale: CGFloat
    var finalScale: CGFloat
    var animation: Animation
    var delay: Double
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? finalScale : initialScale)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(animation) {
                        isVisible = true
                    }
                }
            }
    }
}

struct OffsetAnimationModifier: ViewModifier {
    var initialOffset: CGSize
    var finalOffset: CGSize
    var animation: Animation
    var delay: Double
    @State private var isVisible: Bool = false

    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? finalOffset.width : initialOffset.width, y: isVisible ? finalOffset.height : initialOffset.height)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(animation) {
                        isVisible = true
                    }
                }
            }
    }
}


