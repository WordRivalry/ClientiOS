//
//  NavigationBarColorModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-10.
//

import SwiftUI

extension View {
    // https://discussions.apple.com/thread/255346817?sortBy=best
    func navigationBarColor(_ color: UIColor) -> some View {
        self.modifier(NavigationBarColorModifier(color: color))
    }
}

struct NavigationBarColorModifier: ViewModifier {
    var color: UIColor

    func body(content: Content) -> some View {
        content
            .onAppear {
                let coloredAppearance = UINavigationBarAppearance()
                coloredAppearance.largeTitleTextAttributes = [.foregroundColor: color]
 
                UINavigationBar.appearance().standardAppearance = coloredAppearance
                //  UINavigationBar.appearance().compactAppearance = coloredAppearance
                //  UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
            }
    }
}

// #Preview {
  //  NavigationBarColorModifier()
// }
