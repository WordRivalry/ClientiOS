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
    @State private var selectedCategory: AchievementCategory? // Assuming AchievementCategory is your enum type

    var body: some View {
        VStack {
            // Tabs for categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(achievementsByCategory.keys), id: \.self) { category in
                        Text(category.rawValue)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(self.selectedCategory == category ? Color.accentColor : Color.clear)
                            .foregroundColor(self.selectedCategory == category ? .white : .accentColor)
                            .cornerRadius(15)
                            .onTapGesture {
                                withAnimation {
                                    self.selectedCategory = category
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color.gray.opacity(0.2)) // Optional: Adds a slight background color to the tab bar area
            .padding(.top)

            // Content
            ScrollView {
                if let selectedCategory = selectedCategory, let achievements = achievementsByCategory[selectedCategory] {
                    ForEach(achievements, id: \.name) { achievement in
                        AchievementRow(
                            achievement: achievement,
                            progression: progressions.progressions.first(where: { $0.name == achievement.name.rawValue })
                        )
                        .padding(.horizontal)
                    }
                } else {
                    Text("Please select a category.")
                        .padding()
                }
            }
            .listStyle(.automatic)
            .environment(\.defaultMinListRowHeight, 70)
            .scrollContentBackground(.hidden)
            
            BasicDissmiss()
        }
        .onAppear {
            // Optionally select the first category by default
            self.selectedCategory = achievementsByCategory.keys.first
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
