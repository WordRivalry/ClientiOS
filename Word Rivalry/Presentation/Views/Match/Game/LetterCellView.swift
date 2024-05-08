//
//  LetterCellView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import SwiftUI

struct LetterCellView: View {
    let letter: Letter
    let row: Int
    let col: Int
    let isHighlighted: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 10.0)
            .fill(isHighlighted ? Color.blue : Color.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Text(letter.letter)
                    .font(.title)
                    .foregroundColor(isHighlighted ? .white : .black)
            )
    }
}



#Preview {
    LetterCellView(
        letter: Letter(
            letter: "A",
            value: 3,
            letterMultiplier: 1,
            wordMultiplier: 2
        ),
        row: 0,
        col: 0,
        isHighlighted: true
    )
}
