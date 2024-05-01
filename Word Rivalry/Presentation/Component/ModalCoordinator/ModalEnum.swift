//
//  SheetEnum.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import Foundation
import SwiftUI

/// Protocol defining the requirements for a sheet with a custom view, where the type is `RawRepresentable` with a `String` raw value.
protocol ModalEnum: Identifiable, RawRepresentable where RawValue == String {
    associatedtype Body: View

    /// Creates a view using the provided coordinator.
    /// - Parameter coordinator: Coordinator managing the modal's behavior.
    /// - Returns: A view conforming to the `View` protocol.
    @ViewBuilder
    func view(coordinator: ModalCoordinator<Self>) -> Body
}

/// Default implementation for `Identifiable` ID using `rawValue`.
extension ModalEnum {
    var id: String { rawValue }
}

