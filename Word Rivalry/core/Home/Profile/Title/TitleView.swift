//
//  TitleView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct TitleView: View {
    var title: String
    var body: some View {
        Text(title)
            .bold()
            .lineLimit(1) // Ensure the text does not wrap to a new line
            .foregroundColor(.accent)
    }
}

#Preview {
    TitleView(title: Title.newLeaf.rawValue)
}
