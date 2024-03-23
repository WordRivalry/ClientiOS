//
//  AnimatedCirclesViewModel.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-22.
//

import Foundation
import SwiftUI


class AnimatedCirclesViewModel: ObservableObject {
    @Published var tiers: [Double] = [100.0, 150.0, 200.0]
    @Published var maxScale: CGFloat = 1.2
    @Published var minScale: CGFloat = 0.8
    @Published var colors: [Color] = [Color.blue.opacity(0.7), Color.purple.opacity(0.7), Color.blue.opacity(0.5)]
    
    // Additional parameters can be added here as needed
}
