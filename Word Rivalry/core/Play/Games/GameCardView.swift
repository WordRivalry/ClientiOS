//
//  RankedGameCardView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-01.
//

import SwiftUI

struct GameCardView: View {
    var cardName: String
    var action: () -> Void
    @State private var showDetails = false
    @Namespace private var namespace

    init(cardName: String, action: @escaping () -> Void) {
        self.cardName = cardName
        self.action = action
        debugPrint("~~~ GameCardView init ~~~")
    }
    
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
        .padding(.horizontal)
        .cornerRadius(12)
        .shadow(radius: 2)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.bar)
        )
    }

    @ViewBuilder
    private var compactView: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(cardName)
                .font(.headline.weight(.semibold))
                .matchedGeometryEffect(id: "cardName\(cardName)", in: namespace)
            
            Spacer()
                ActionButton(title: "FIND MATCH", action: action)
                    .matchedGeometryEffect(id: "actionButtom\(cardName)", in: namespace)
        }
        .frame(width: 300, height: 80)
    }

    @ViewBuilder
    private var detailedView: some View {
        VStack(alignment: .center, spacing: 10)  {
            Text(cardName)
                .foregroundStyle(.primary)
                .font(.headline.weight(.bold))
                .padding(.top, 20)
                .matchedGeometryEffect(id: "cardName\(cardName)", in: namespace)
            Spacer()
            detailsByModeType
                .foregroundStyle(.secondary)
            Spacer()
            ActionButton(title: "FIND MATCH", action: action)
                .padding(.bottom, 20)
                .matchedGeometryEffect(id: "actionButtom\(cardName)", in: namespace)
        }
        .frame(width: 300, height: 300)
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
    return GameCardView(
        cardName: "NORMAL",
        action: {}
    )
}
