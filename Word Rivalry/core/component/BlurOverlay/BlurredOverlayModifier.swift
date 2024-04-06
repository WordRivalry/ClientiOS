//
//  BlurredOverlayModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-24.
//

import SwiftUI

struct BlurredOverlayModifier<OverlayContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let overlayContent: OverlayContent
    var blurStyle: UIBlurEffect.Style
    var backgroundOpacity: Double
    
    init(
        isPresented: Binding<Bool>,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        backgroundOpacity: Double = 0.8,
        @ViewBuilder overlayContent: () -> OverlayContent) {
            self._isPresented = isPresented
            self.overlayContent = overlayContent()
            self.blurStyle = blurStyle
            self.backgroundOpacity = backgroundOpacity
        }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isPresented ? 4 : 0)
            if isPresented {
                VisualEffectView(effect: UIBlurEffect(style: .regular))
                    .ignoresSafeArea()
                    .opacity(backgroundOpacity)
                overlayContent
                    .padding()
            }
            
        }
    }
}


struct BlurredOverlayModifierWithAnimation<OverlayContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let overlayContent: OverlayContent
    var blurStyle: UIBlurEffect.Style
    var backgroundOpacity: Double
    @Environment(\.colorScheme) var colorScheme
    
    init(
        isPresented: Binding<Bool>,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        backgroundOpacity: Double = 0.8,
        @ViewBuilder overlayContent: () -> OverlayContent) {
            self._isPresented = isPresented
            self.overlayContent = overlayContent()
            self.blurStyle = blurStyle
            self.backgroundOpacity = backgroundOpacity
        }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isPresented ? 4 : 0)
            if isPresented {
                
                if colorScheme == .dark {
                    StarryNightViewWrapper()
                        .ignoresSafeArea()
                        .opacity(backgroundOpacity)
                }
                
                VisualEffectView(effect: UIBlurEffect(style: .regular))
                    .ignoresSafeArea()
                    .opacity(backgroundOpacity)
                
                overlayContent
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}


extension View {
    func blurredOverlay<OverlayContent: View>(
        isPresented: Binding<Bool>,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        backgroundOpacity: Double = 0.8,
        @ViewBuilder overlayContent: @escaping () -> OverlayContent) -> some View {
            
            self.modifier(BlurredOverlayModifier(
                isPresented: isPresented,
                blurStyle: blurStyle,
                backgroundOpacity: backgroundOpacity,
                overlayContent: overlayContent)
            )
        }
    
    func blurredOverlayWithAnimation<OverlayContent: View>(isPresented: Binding<Bool>, blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark, backgroundOpacity: Double = 0.8, @ViewBuilder overlayContent: @escaping () -> OverlayContent) -> some View {
        self.modifier(BlurredOverlayModifierWithAnimation(
            isPresented: isPresented,
            blurStyle: blurStyle,
            backgroundOpacity: backgroundOpacity,
            overlayContent: overlayContent)
        )
    }
}

#Preview(body: {
    VStack {
        Text("My Overlay")
        
        Spacer()
        
        RoundedRectangle(cornerRadius: 25)
            .fill(.accent)
            .frame(width: 300, height: 400)
            .overlay {
                Text("My rounded rectangle")
            }
    }
    .blurredOverlayWithAnimation(isPresented: .constant(true)) {
        VStack {
            Text("My Overlay")
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 25)
                .stroke()
                .frame(width: 300, height: 100)
                .overlay {
                    Text("My rounded rectangle")
                }
            Spacer()
        }
    }
})
