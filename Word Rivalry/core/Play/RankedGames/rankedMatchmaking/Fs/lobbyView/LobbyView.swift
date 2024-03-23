//
//  LobbyView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-20.
//

import SwiftUI

struct LobbyView: View {
    var opponentPlayerName: String
    var myPlayerName: String
    var opponentEloRating: Int
    var myEloRating: Int
    
    let eloRange: ClosedRange<Int> = 1000...1500
    
    @Binding var waitingForOpponent: Bool
    
    var body: some View {
        // Floating circles background
        ZStack {
            
            ZStack {
                // Linear gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3),
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                    .ignoresSafeArea()
                
                // Floating circles
                FloatingCirclesView()
                    .blur(radius: 10)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 25.0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .background(.white.opacity(0.1))
            }
            
            // Main content
            VStack {
                Spacer()
                
                // Match Found Announcement
                BlinkingTextView(text: "Match Found!", isBlinking: $waitingForOpponent)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Player Information
                VStack {
                    PlayerInfoView(playerName: opponentPlayerName, eloRating: opponentEloRating, color: .red)
                    
                    ELORatingBarView(myEloRating: myEloRating, opponentEloRating: opponentEloRating, eloRange: eloRange)
                        .frame(height: 20)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct ELORatingBarView: View {
    var myEloRating: Int
    var opponentEloRating: Int
    var eloRange: ClosedRange<Int>
    
    private func calculatePosition(rating: Int, geometry: GeometryProxy) -> CGFloat {
        let totalRange = CGFloat(eloRange.upperBound - eloRange.lowerBound)
        let ratingOffset = CGFloat(rating - eloRange.lowerBound)
        return (geometry.size.width * ratingOffset) / totalRange
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.gray)
                    .cornerRadius(geometry.size.height / 2)
                
                // My ELO Rating Marker
                Image(systemName: "arrowtriangle.up.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height)
                    .foregroundColor(.green)
                    .position(x: calculatePosition(rating: myEloRating, geometry: geometry), y: geometry.size.height / 2)
                
                // Opponent ELO Rating Marker
                Image(systemName: "arrowtriangle.up.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height)
                    .foregroundColor(.red)
                    .position(x: calculatePosition(rating: opponentEloRating, geometry: geometry), y: geometry.size.height / 2)
            }
        }
    }
}

struct RatingBarView: View {
    var rating: Int
    var maxRating: Int
    
    private var ratingFraction: CGFloat {
        return min(CGFloat(rating) / CGFloat(maxRating), 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: geometry.size.width * ratingFraction, height: geometry.size.height)
                    .foregroundColor(.blue)
                    .animation(.easeInOut, value: ratingFraction)
            }
            .cornerRadius(geometry.size.height / 2)
        }
    }
}


#Preview {
    LobbyView(
        opponentPlayerName: "Neytherland",
        myPlayerName: "lighthouse",
        opponentEloRating: 1230,
        myEloRating: 1140, 
        waitingForOpponent: .constant(true)
    )
}
