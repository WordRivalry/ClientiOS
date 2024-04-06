//
//  RankedGameCardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-01.
//

import SwiftUI

struct RankedGameCardView: View {
    var cardName: String
    var action: () -> Void
    @State private var showDetails = false
    @Namespace private var namespace

    var body: some View {
        ZStack(alignment: .topLeading) {
            if !showDetails {
                // Compact View
                compactView
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            showDetails = true
                        }
                    }
            } else {
                // Expanded Detailed View
                detailedView
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            showDetails = false
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var compactView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(cardName)
                .font(.headline.weight(.semibold))
                .padding(.bottom, 5)
                .matchedGeometryEffect(id: "cardName\(cardName)", in: namespace)
            
            HStack {
                Spacer()
                ActionButton(title: "FIND MATCH", action: action)
                    .matchedGeometryEffect(id: "actionButtom\(cardName)", in: namespace)
            }
            .padding(.vertical)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private var detailedView: some View {
        VStack(alignment: .center, spacing: 10)  {
            Text(cardName)
                .font(.headline.weight(.bold))
                .padding(.top, 20)
                .matchedGeometryEffect(id: "cardName\(cardName)", in: namespace)
            Spacer()
            detailsByModeType
            Spacer()
            ActionButton(title: "FIND MATCH", action: action)
                .padding(.bottom, 20)
                .matchedGeometryEffect(id: "actionButtom\(cardName)", in: namespace)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @ViewBuilder
    private var detailsByModeType: some View {
        switch cardName {
        case ModeType.NORMAL.rawValue:
            CardDetailsView(
                time: 90,
                numRounds: 1,
                wordMultiplicator: true,
                letterMultiplicator: true
            )
          case ModeType.BLITZ.rawValue:
            CardDetailsView(
                time: 30,
                numRounds: 3,
                wordMultiplicator: true,
                letterMultiplicator: true
            )
        default:
            fatalError("Ops: detailedByModeType")
        }
    }
}

// MARK: ActionButton
struct ActionButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .cornerRadius(8)
        }
    }
}

// MARK: Details
struct CardDetailsView: View {
    var time: Int
    var numRounds: Int
    var wordMultiplicator: Bool
    var letterMultiplicator: Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Temps :")
                Text("\(time) seconds")
            }
            HStack {
                Text("Number of Rounds :")
                Text("\(numRounds)")
            }
            HStack {
                Text("Word Multiplicateur :")
                Text(wordMultiplicator ? "Yes" : "No")
            }
            HStack {
                Text("Letter Multiplicateur :")
                Text(wordMultiplicator ? "Yes" : "No")
            }
        }

    }
}

#Preview {
    return RankedGameCardView(
        cardName: "NORMAL",
        action: {}
    )
}
