//
//  CountdownOverlayView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

struct CountdownOverlayView: View {
    @Binding var countdown: Int 
    // Added to trigger the scale animation
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            if countdown > 0 {
                Text("\(countdown)")
                    .font(.system(size: 90, weight: .bold))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.0) // Fade effect
                    // Ensure the animation triggers scale and opacity changes
                    .animation(.easeInOut(duration: 0.5), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                        // Reset animation state after it's complete to prepare for next countdown
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isAnimating = false
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .edgesIgnoringSafeArea(.all)
                    // Trigger the countdown decrease and restart the animation
                    .onChange(of: countdown) {
                        isAnimating = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isAnimating = false
                        }
                    }
            }
            
        }
        
    }
}

#Preview {
    CountdownOverlayView(countdown: .constant(10))
}
