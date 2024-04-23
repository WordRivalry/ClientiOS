//
//  Last5WordsView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-19.
//

import SwiftUI

struct LastFiveWordsView: View {
    @State var alreadyDoneWords: [String] = []
    
    var lastFiveWords: [String] {
        alreadyDoneWords.suffix(5).reversed()
    }
    
    var body: some View {
        VStack {
            ForEach(lastFiveWords, id: \.self) { word in
                Text(word)
                    .font(.callout)
                    .frame(width: 150, alignment: .bottomLeading)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(.bar))
            }
        }
    }
}

#Preview {
    ViewPreview {
        LastFiveWordsView(alreadyDoneWords: [
            "Timelapse",
            "Downtime",
            "hi",
            "Done",
            "Farewell",
            "Valid",
            "Police"
        ])
    }
}
