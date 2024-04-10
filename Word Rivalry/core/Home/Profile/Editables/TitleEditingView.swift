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
    
    @Environment(AchievementsProgression.self) private var progs: AchievementsProgression
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
        let isUnlocked = content.isUnlocked(using: progs, title)
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                TitleView(title: title.rawValue)
                if titleSelected == title.rawValue {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                Spacer()
                Group {
                    Image(systemName: "clock")
                        .foregroundColor(isUnlocked ? .green : .red)
                    Text(isUnlocked ? "Permanent": "Not obtained")
                }
              
                    .modifier(ShakeEffect(
                        animatableData: shakeManager.itemToShake == title ? 1 : 0)
                    )
            }
           
            
            Text(content.getDescription(for: title))
            
           
            
            if let achievementName = content.getAchievement(for:title) {
                Divider()
                HStack {
                    Text("Achievement :")
                    Text("\(achievementName.rawValue)")
                        .foregroundStyle(.cyan)
                        .onTapGesture {
                           print("Tapped")
                        }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1.0)
        )
        .onTapGesture {
            if isUnlocked {
                titleSelected = title.rawValue
                profile.title = title.rawValue
            } else {
                withAnimation {
                    shakeManager.triggerShake(for: title)
                }
            }
        }
        
    }
}

struct ProgressionView: View {
    var progression: AchievementProgression
    var body: some View {
        ProgressView(
            value: Float(progression.current),
            total: Float(progression.target)
        ) {
            Text("Need to do some things")
        } currentValueLabel: {
            Text("\(progression.current)/\(progression.target)")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(4)
                .background(Color.orange.opacity(0.85))
                .cornerRadius(4)
                .foregroundColor(.white)
        }
        .padding()
        .tint(.accent)
        .progressViewStyle(.linear)
        .frame(width: 250)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .fill(.bar)
                
        )
   
    }
}

#Preview {
    TitleEditingView(
        titleSelected: .constant(Title.newLeaf.rawValue),
        profile: PublicProfile.preview
    )
    .frame(height: 450)
    .environment(AchievementsProgression.preview)
}
