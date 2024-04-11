//
//  AdaptiveForegroundStyleModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

// https://developer.apple.com/documentation/swiftui/environmentvalues/backgroundprominence

struct AdaptiveForegroundStyleModifier: ViewModifier {
    @Environment(\.backgroundProminence) var backgroundProminence

    func body(content: Content) -> some View {
        content
            .foregroundStyle(resolveForegroundStyle())
    }

    private func resolveForegroundStyle() -> some ShapeStyle {
        switch backgroundProminence {
        case .increased:
            return AnyShapeStyle(Color.red)
        default:
            return AnyShapeStyle(Color.accentColor)
        }
    }
}

extension View {
    func adaptiveForegroundStyle() -> some View {
        self.modifier(AdaptiveForegroundStyleModifier())
    }
}

#Preview {
    RecipeListView()
}

// Dummy data model
struct Recipe: Identifiable {
    let id: UUID = UUID()
    var name: String
    var rating: Int // 1 to 5
}

// Main view that lists recipes
struct RecipeListView: View {
    let recipes: [Recipe] = [
        Recipe(name: "Spaghetti Carbonara", rating: 5),
        Recipe(name: "Chicken Alfredo", rating: 4),
        Recipe(name: "Margherita Pizza", rating: 5)
    ]
    
    @State private var selectedRecipeID: UUID?
    
    var body: some View {
        NavigationView {
            List(recipes, selection: $selectedRecipeID) { recipe in
                RecipeListRow(recipe: recipe)
                    .environment(\.backgroundProminence, selectedRecipeID == recipe.id ? .increased : .standard)
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipeListRow: View {
    var recipe: Recipe
    
    var body: some View {
        HStack {
            Text(recipe.name)
                .adaptiveForegroundStyle()
            Spacer()
            StarRating(rating: recipe.rating)
                .adaptiveForegroundStyle()
        }
    }
}

struct StarRating: View {
    var rating: Int
    
    var body: some View {
        HStack {
            ForEach(0..<rating, id: \.self) { _ in
                Image(systemName: "star.fill")
            }
        }
        .adaptiveForegroundStyle()
    }
}
