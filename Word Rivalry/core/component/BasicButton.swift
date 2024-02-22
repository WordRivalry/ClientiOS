//
//  FindMatchButton.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-22.
//

import SwiftUI

struct BasicButton: View {
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor.opacity(0.6))
                .cornerRadius(8)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    BasicButton(text: "Hi", action: {})
}
