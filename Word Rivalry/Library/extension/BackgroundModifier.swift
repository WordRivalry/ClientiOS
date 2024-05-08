//
//  BackgroundModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI

/// A SwiftUI view modifier that applies comprehensive background styling to a view.
///
/// This modifier configures a view's background with two layers:
/// 1. A solid rectangle using a predefined style from the app's theme called "bar".
/// 2. A resizable background image that extends to cover the entire available space, including the safe areas of the device.
///
/// The `BackgroundModifier` stretches the background to fill the width of the device by default and
/// ignores the safe area insets at the bottom of the device, ensuring the background extends behind
/// system UI elements like the home indicator on iPhones with Face ID.
///
/// The first layer is a `RoundedRectangle` with a `cornerRadius` of zero, making it a perfect rectangle.
/// This rectangle is styled with a foreground style defined as `.bar` in the app's assets or color settings,
/// ensuring it matches the app's design theme.
///
/// The second layer is an image loaded from the app's asset catalog named "bg". This image is made
/// resizable, which allows it to stretch and fill the entire background of the view, adapting to different
/// screen sizes and orientations.
///
/// This modifier is particularly useful for views that require a complex, layered background with both
/// color and imagery that extends into the device's safe areas.
///
/// Usage:
/// To apply this background style to any SwiftUI view, you can use the `customBackground()` convenience
/// method defined in the `View` extension. This method abstracts away the complexity of the background
/// setup and provides a clean interface for applying the background style.
///
/// Example:
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         VStack {
///             Text("Hello, World!")
///                 .padding()
///             Spacer()
///         }
///         .customBackground()  // Applying the custom background modifier
///     }
/// }
/// ```
///
/// - Authors: [Benoit Barbier]
/// - Since: [May 1 2024]
struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .foregroundStyle(.bar)
            }
            .ignoresSafeArea(edges: .bottom)
            .background(
                Image("bg")
                    .resizable()
                    .ignoresSafeArea()
            )
        
    }
}

extension View {
    
    /// Applies the custom background styling defined by `BackgroundModifier`.
    ///
    /// This convenience method extends any SwiftUI view to include a two-layer background
    /// with a styled rectangle and a full-screen image. It simplifies the application of
    /// a consistent background style across multiple views within an application.
    ///
    /// Example usage:
    /// ```swift
    /// Text("Sample Text").customBackground()
    /// ```
    ///
    /// - Returns: A view modified with the `BackgroundModifier` style.
    func defaultBackgroundIgnoreSafeBottomArea() -> some View {
        modifier(BackgroundModifier())
    }
}

#Preview {
    VStack {
        Text("Hello, World!")
            .padding()
        Spacer()
    }
    .defaultBackgroundIgnoreSafeBottomArea()
}
