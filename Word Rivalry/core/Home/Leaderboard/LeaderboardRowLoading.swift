//
//  LeaderboardRowLoading.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-09.
//

import SwiftUI

struct LeaderboardLoadingView: View {
    var body: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { _ in
                LeaderboardRowLoading()
                    .padding(.horizontal)
            }
        }
    }
}

struct LeaderboardRowLoading: View {
    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                rankImageLoadingView
                    .offset(x: 10)
                    .frame(width: 36, height: 36)
                portraitLoadingView
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                playerLoadingView
                Spacer()
            }
            .padding(.vertical)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .blur(radius: 1)
    }
    
    private var rankImageLoadingView: some View {
        ShimmerView()
            .frame(width: 36, height: 36)
    }
    
    private var portraitLoadingView: some View {
        ShimmerView()
            .clipShape(Circle())
    }
    
    private var playerLoadingView: some View {
        VStack(alignment: .leading, spacing: 4) {
            ShimmerView().frame(height: 20)
            ShimmerView().frame(height: 15)
        }
    }
}

struct ShimmerView: View {
    // Define the gradient with transparent and less transparent sections
    let gradient = Gradient(colors: [Color.clear, Color.white.opacity(0.3), Color.clear])
    
    // Initial positions of the gradient, outside of the visible area of the view
    @State private var gradientStart = UnitPoint(x: -1, y: 0.5)
    @State private var gradientEnd = UnitPoint(x: 0, y: 0.5)

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(gradient: gradient, startPoint: gradientStart, endPoint: gradientEnd)
            )
            .animation(
                // Define the animation for the gradient transition
                Animation.linear(duration: 5)
                    .repeatForever(autoreverses: false),
                value: gradientStart // Animation is triggered based on the change of this value
            )
            .onAppear {
                // Move the gradient from left to right by changing start and end points
                gradientStart = UnitPoint(x: 1, y: 0.5)
                gradientEnd = UnitPoint(x: 2, y: 0.5)
            }
    }
}

#Preview {
    LeaderboardRowLoading()
}
