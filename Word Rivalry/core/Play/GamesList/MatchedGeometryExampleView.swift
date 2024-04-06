//
//  MatchedGeometryExampleView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-02.
//

import SwiftUI

struct MatchedGeometryExampleView: View {
    // Define the namespace for matched geometry effect
    @Namespace private var animationNamespace
    
    // State variable to toggle the view size
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            // Background to dismiss the expanded view
            if isExpanded {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
            }
            
            // Toggle between small and large rectangle
            VStack {
                if !isExpanded {
                    smallRectangle
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                } else {
                    largeRectangle
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                }
            }
        }
    }
    
    // Small rectangle view
    var smallRectangle: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue)
            .frame(width: 150, height: 60)
            .matchedGeometryEffect(id: "rectangle", in: animationNamespace)
    }
    
    // Large rectangle view acting as an overlay
    var largeRectangle: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.blue)
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
            .matchedGeometryEffect(id: "rectangle", in: animationNamespace)
    }
}

#Preview {
    MatchedGeometryExampleView()
}
