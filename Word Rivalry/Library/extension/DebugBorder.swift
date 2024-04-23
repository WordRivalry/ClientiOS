//
//  DebugBorder.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-18.
//

import Foundation

import SwiftUI

extension ShapeStyle where Self == Color {
    static var debug: Color {
        Color(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1)
        )
    }
}
