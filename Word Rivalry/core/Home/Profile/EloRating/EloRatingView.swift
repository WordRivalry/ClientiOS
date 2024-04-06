//
//  EloRatingView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct EloRatingView: View {
    var eloRating: Int
    var body: some View {
        Text("Rating: \(eloRating)")
    }
}

#Preview {
    EloRatingView(eloRating: 800)
}
