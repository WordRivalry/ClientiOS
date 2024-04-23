//
//  ColorSchemeManager.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-21.
//

import Foundation
import SwiftUI

class ColorSchemeManager: ObservableObject {
    static let shared = ColorSchemeManager()
    @AppStorage("colorScheme") var selectedColorScheme: String = "system"
    
    func getPreferredColorScheme() -> ColorScheme? {
        switch selectedColorScheme {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil
        }
    }
}
