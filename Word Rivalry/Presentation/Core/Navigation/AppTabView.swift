//
//  AppTabView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import Combine
import OSLog

struct AppTabView: View {
    @Binding var selection: AppScreen?
    @Environment(MyPublicProfile.self) private var profile
 
    init(selection: Binding<AppScreen?>) {
        _selection = selection
        Logger.viewCycle.debug("~~~ AppTabView init ~~~")
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                ForEach(AppScreen.allCases) { screen in
                    screen.destination
                        .animation(.easeIn,value: selection)
                        .tag(screen as AppScreen?)
                        .id(screen as AppScreen?)
                        .tabItem { screen.label }
                }
            }
        //    .border(.debug)
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .navigationBarColor(.white)
        .logLifecycle(viewName: "AppTabView")
    }
}

#Preview {
    ViewPreview {
        AppTabView(selection: .constant(.home))
    }
}
