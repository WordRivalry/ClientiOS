//
//  AchievementRow.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

struct AchievementRow: View {
    var achievement: Achievement
    var progression: AchievementProgression?
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(achievement.name.rawValue)
                        .font(.headline)
                    Text(achievement.desc)
                        .font(.subheadline)
                }
                Spacer()
                
                Image(systemName: progression?.isComplete ?? false ? "lock.open" : "lock")
                    .foregroundColor(
                        progression?.isComplete ?? false ? .green : .red
                    )
            }
            .padding(.horizontal)
            
            if (progression != nil) {
                ProgressView(
                    value: Float(progression!.current),
                    total: Float(progression!.target)
                ) {
                    Text( "Progression ")
                        .font(.callout)
                } currentValueLabel: {
                    Text("\(progression!.current)/\(progression!.target)")
                }
                .padding(.top)
                .padding(.horizontal)
                .progressViewStyle(.linear)
            }
        }
        .cardBackground()
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        AchievementRow(
            achievement: AchievementsManager.shared.forKey(.ButtonClicker),
            progression: AchievementsManager.shared.newProgression(for: .ButtonClicker)
        )
        .environment(AchievementsProgression.preview)
        .padding(.horizontal)
    }
}
