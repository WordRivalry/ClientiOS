//
//  RiveTest.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-27.
//

import SwiftUI
import RiveRuntime

struct UberMenu: View {
    
    let viewModel = RiveViewModel(fileName: "RiveAsset/Hambergeur")
    @Binding var isOpen: Bool
    
    var body: some View {
       
        hambergeur
            .frame(width: 50, height: 50)
     //       .mask(Circle())
            .shadow(color: .accent.opacity(1), radius: 10, x: 0, y: 5)
          
            .onTapGesture {
                viewModel.setInput("isOpen", value: isOpen)
                isOpen.toggle()
            }
            // Placement
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
    }
    
    @ViewBuilder
    private var hambergeur: some View {
        viewModel.view()
    }
}

#Preview {
    UberMenu(isOpen: .constant(true))
}
