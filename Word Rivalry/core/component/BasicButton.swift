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
                .background(
//                    ZStack {
                  
                        
                        Color.accent
//                            .opacity(0.2)
//                        
//                        Image("grey")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .scaleEffect(0.5)
//                            .offset(CGSize(width: 60.0, height: 0))
//                            .rotation3DEffect(.degrees(-39), axis: (x: 0, y: 1, z: 0))
//                            .rotation3DEffect(.degrees(30), axis: (x: 0, y: 0, z: 1))
//                            .opacity(0.2)
//                            .clipped()
//                        
//                       
//                    }
                )
//                .overlay {
//                    RoundedRectangle(cornerRadius: 5)
//                        .stroke(lineWidth: 4)
//                }
                      .cornerRadius(8)
                .cornerRadius(8)
                
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    BasicButton(text: "Hi", action: {})
}
