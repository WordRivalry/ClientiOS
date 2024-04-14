//
//  DataPreview.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-14.
//

import Foundation

/// `DataPreview` protocol defines a blueprint for types that need to provide a preview of their data.
/// This is typically used in scenarios where a mock or sample instance of the type is required for
/// preview purposes in development environments, such as SwiftUI previews.
///
/// Conforming to `DataPreview`:
/// Implement this protocol to provide a static preview instance of your type. This can be particularly
/// useful when working with SwiftUI views in the Xcode canvas, where you want to render previews of
/// your custom views with representative data.
///
/// - Requires:
///     - `preview`: A static property that returns a settable instance of the conforming type.
///
/// - Example:
/// ```swift
/// struct UserProfile: DataPreview {
///     var name: String
///     var age: Int
///     var bio: String
///
///     static var preview: UserProfile {
///         get { UserProfile(name: "Jane Doe", age: 29, bio: "SwiftUI Developer") }
///         set { /* Customize how the new value affects the preview */ }
///     }
/// }
///
/// // Usage in SwiftUI preview
/// #Preview {
///    UserProfileView(profile: UserProfile.preview)
/// }
/// ```
///
protocol DataPreview {
    static var preview: Self { get set }
}
