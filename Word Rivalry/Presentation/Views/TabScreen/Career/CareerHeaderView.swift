//
//  CareerHeaderView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI

struct CareerHeaderView: View {
    var body: some View {
        HStack {
            Image("Career/Header")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("Career")
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white)
                .shadow(radius: 2, x: 2, y: 2)
            
            Spacer()
        }
    }
}

#Preview {
    CareerHeaderView()
}
