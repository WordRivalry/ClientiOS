//
//  HeaderModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI

struct HeaderModifier: ViewModifier {
    var backgroundColor: Color = .accentColor  //.lightGreen
    var height: CGFloat = 100
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: height)
            .padding(.horizontal)
            .background(backgroundColor)
            .foregroundColor(.white)
            .font(.title)
            .shadow(radius: 2, x: 2, y: 2)
    }
}

extension View {
    func headerStyle(backgroundColor: Color = .accentColor, height: CGFloat = 100) -> some View {
        self.modifier(HeaderModifier(backgroundColor: backgroundColor, height: height))
    }
}


#Preview {
    Text("Hi")
        .headerStyle()
       // .background(.red)
}
