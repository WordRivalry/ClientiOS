//
//  AchievementsView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import SwiftUI

struct AchievementsView: View {
    @Environment(AchievementsProgression.self) private var progressions: AchievementsProgression
    let achievementsByCategory = AchievementsManager.shared.getAllAchievements()

    var body: some View {
        VStack {
            List {
                ForEach(Array(achievementsByCategory.keys), id: \.rawValue) { category in
                    Section(header: Text(category.rawValue)) {
                        ForEach(achievementsByCategory[category] ?? [], id: \.name) { achievement in
                            AchievementRowView(
                                achievement: achievement,
                                progression: progressions.progressions.first(where: { progression in
                                    progression.name == achievement.name.rawValue
                                })
                            )
                        }
                    }
                }
            }
            /// List Modifiers
            .listStyle(.automatic)
            .environment(\.defaultMinListRowHeight, 70)
            .scrollContentBackground(.hidden)
            
            BasicDissmiss()
        }
    }
} 

struct AchievementRowView: View { 
    var achievement: Achievement
    var progression: AchievementProgression?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(achievement.name.rawValue)
                    .font(.headline)
                Text(achievement.desc)
                    .font(.subheadline)
                
                if (progression != nil) {
                    AchievmentProgressBar(progress: Float(progression!.current) / Float(progression!.target))
                        .frame(height: 10)
                }
            
            }
            
            Spacer()
            
            Image(systemName: progression?.isComplete ?? false ? "lock.open" : "lock")
                .foregroundColor(
                    progression?.isComplete ?? false ? .green : .red
                )
        }
    }
}

struct AchievmentProgressBar: View {
    var progress: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.progress)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.easeInOut, value: progress)
            }.cornerRadius(45.0)
        }
    }
}

#Preview {
    ModelContainerPreview {
        previewContainer
    } content: {
        AchievementsView()
            .environment(AchievementsProgression.preview)
    }
}
