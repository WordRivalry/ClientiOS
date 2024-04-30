//
//  RatingUpdateView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-25.
//

import SwiftUI

struct RankUpdateView: View {
    let minRating: Int = 1000  // Minimum rating value for the progress bar scale
    let maxRating: Int = 1500  // Maximum rating value for the progress bar scale
    var oldRating: Int
    var newRating: Int
    
    @State private var progress: CGFloat = 0.0
    @State private var displayedRating: Int
    
    init(oldRating: Int, newRating: Int) {
        self.oldRating = oldRating
        self.newRating = newRating
        // Initialize the displayedRating with the oldRating
        // And calculate initial progress based on oldRating
        self._displayedRating = State(initialValue: oldRating)
        self._progress = State(initialValue: CGFloat(oldRating - minRating) / CGFloat(maxRating - minRating))
    }
    
    var body: some View {
        VStack {
            Text("Your Rating")
                .font(.headline)
                .padding()
            
            // Display the current rating
            Text("\(displayedRating)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .animation(.none, value: displayedRating)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle() // Background of the progress bar
                        .foregroundColor(Color.gray.opacity(0.3))
                    Rectangle() // Animated progress fill
                        .frame(width: progress * geometry.size.width)
                        .foregroundColor(.accentColor)
                        .animation(.easeOut(duration: 2), value: progress)
                   
                  
                }
            }
            .frame(height: 20)
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack {
                
                Image("BronzeShield")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.horizontal)
                Spacer()
                
                Image("SilverShield")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.horizontal)
                
            }
        }
        .onAppear {
            // Calculate the final progress based on newRating
            let finalProgress = CGFloat(newRating - minRating) / CGFloat(maxRating - minRating)
            withAnimation(.easeOut(duration: 2)) {
                self.progress = finalProgress
            }
            
            // Animate the numerical rating increment/decrement
            withAnimation(.linear(duration: 2)) {
                displayedRating = newRating
            }
        }
    }
}

// ProgressBar View
struct ProgressBar3: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.progress)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear, value: progress)
            }.cornerRadius(45.0)
        }
    }
}

#Preview {
    RankUpdateView(oldRating: 1100, newRating: 1200)
}
