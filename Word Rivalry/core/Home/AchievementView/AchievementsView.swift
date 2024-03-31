//
//  AchievementsView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import SwiftUI

struct AchievementsView: View {
    let achievementsByCategory = AchievementsManager.shared.getAllAchievements()
    let unlockedAchievementIDs: Set<String>
    @State private var selectedCategory: AchievementCategory? = nil
    
    var body: some View {
        
        List {
                   ForEach(Array(achievementsByCategory.keys), id: \.self) { category in
                       Section(header: Text(category.rawValue)) {
                           ForEach(achievementsByCategory[category] ?? [], id: \.name) { achievement in
                               AchievementRowView(achievement: achievement)
                           }
                       }
                   }
               }
    }
}

struct AchievementRowView: View {
    var achievement: Achievement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(achievement.name)
                    .font(.headline)
                Text(achievement.desc)
                    .font(.subheadline)
                
                if let progression = achievement.progression {
                    ProgressBar2(progress: Float(progression.current) / Float(progression.target))
                        .frame(height: 10)
                }
            }
            Spacer()
            Image(systemName: achievement.progression?.isComplete ?? false ? "lock.open" : "lock")
                .foregroundColor(
                    achievement.progression?.isComplete ?? false ? .green : .red
                )
        }
    }
}

struct ProgressBar2: View {
    var progress: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.progress)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                 //   .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}

#Preview {
    AchievementsView(unlockedAchievementIDs: [AchievementName.wordConqueror.rawValue])
}
