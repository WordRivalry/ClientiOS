//
//  TitleEditingView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-04.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit: CGFloat = 2
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}

@Observable class ShakeStateManager<T> where T: Hashable {
    var itemToShake: T?
    func triggerShake(for item: T) {
        itemToShake = item
        // Reset after animation if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.itemToShake = nil
        }
    }
}

struct TitleEditingView: View {
    @Binding var titleSelected: String
    @State var profile: PublicProfile
    
    let shakeManager = ShakeStateManager<Title>()
    let content = ContentRepository.shared

    var body: some View {
        List() {
            ForEach(Title.allCases, id: \.self) { title in
                titleCard(for: title)
            }
        }
        /// List Modifiers
        .listStyle(.automatic)
        .environment(\.defaultMinListRowHeight, 70)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func titleCard(for title: Title) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TitleView(title: title.rawValue)
            Text(content.getDescription(for: title))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1.0)
        )
        .onTapGesture {
            titleSelected = title.rawValue
            profile.title = title.rawValue
        }
    }
}

#Preview {
    TitleEditingView(
        titleSelected: .constant(Title.newLeaf.rawValue),
        profile: PublicProfile.preview
    )
    .frame(height: 450)
}
