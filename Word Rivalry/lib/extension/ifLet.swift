//
//  iflet.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import Foundation
import SwiftUI

// Extension to conditionally apply modifiers
extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, @ViewBuilder content: (Self, T) -> Content) -> some View {
        if let value = value {
            content(self, value)
        } else {
            self
        }
    }
    
    // A custom modifier that checks for the presence of both values
    @ViewBuilder
    func ifLet<T, U, Content: View>(_ value1: T?, _ value2: U?, @ViewBuilder content: (Self, T, U) -> Content) -> some View {
        if let value1 = value1, let value2 = value2 {
            content(self, value1, value2) // Both values are present
        } else {
            self // One or both values are nil
        }
    }
}
