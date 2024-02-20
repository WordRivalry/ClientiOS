//
//  ThemeService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-31.
//

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "ThemeService", category: "Theme")

//enum Theme: String, CaseIterable {
//    case basic
//    
//    var name: String {
//        return rawValue.capitalized
//    }
//    
//    var productId: String {
//        switch self {
//        case .basic:
//            return "theme.basic"
//        }
//    }
//    
//    var themeTitle: String {
//        switch self {
//        case .basic:
//            return "Basic Theme"
//        }
//    }
//}


enum ColorScheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }

    var scheme: SwiftUI.ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}

class ThemeService: ObservableObject {
    
    // MARK: - Published
    @Published var currentTheme: ColorScheme
    
    init() {
        currentTheme = .system // default
        logger.notice("ThemeService init")
    }
    
    // Public interface
    
    func loadInitialTheme() -> ColorScheme {
        let savedTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? ColorScheme.system.rawValue
        
        currentTheme = ColorScheme(rawValue: savedTheme) ?? .system
        
        logger.notice("Loading theme: \(self.currentTheme.rawValue)")
        return currentTheme
    }
    
    func themedColor(_ name: String) -> Color {
        return Color("\(currentTheme.rawValue.capitalized)_\(name)")
    }
    
    func themedImage(_ name: String) -> Image {
        return Image("\(currentTheme.rawValue.capitalized)_\(name)")
    }
    
    func themedSong(_ name: String) -> String {
        return "\(currentTheme.rawValue.capitalized)_\(name)"
    }
    
    func themedFont(_ name: String) -> String {
        return "\(currentTheme.rawValue.capitalized)_\(name)"
    }
    
    var allThemes: [ColorScheme] {
        ColorScheme.allCases
    }
}

extension ThemeService {
    var currentThemeRaw: String {
        get { currentTheme.rawValue }
        set {
            if let newTheme = ColorScheme(rawValue: newValue) {
                currentTheme = newTheme
            }
        }
    }
}



