//
//  MenuCard.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-27.
//

import SwiftUI


struct MenuCard: View {
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 25.0)
                    .background(.bar)
                    .frame(maxWidth: 200)
                Spacer()
            }
        }
       
    }
}

#Preview {
    MenuCard()
}
