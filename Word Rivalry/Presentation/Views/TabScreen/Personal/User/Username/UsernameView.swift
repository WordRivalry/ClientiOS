//
//  PlayerNameView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct UsernameView: View {
    var username: String
    
    var body: some View {
        Text(username)
    }
}

#Preview {
    UsernameView(username: "Lighthouse")
}
