//
//  PlayerNameView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct PlayerNameView: View {
    var playerName: String
    
    var body: some View {
        Text(playerName)
    }
}

#Preview {
    PlayerNameView(playerName: "Lighthouse")
}
