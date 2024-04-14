//
//  AppTabView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import Combine
import os.log

struct AppTabView: View {
    @Binding var selection: AppScreen?
    @State private var isOverlayOpen: Bool = false
    
    init(selection: Binding<AppScreen?>) {
        _selection = selection
        debugPrint("~~~ AppTabView init ~~~")
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .animation(.easeIn,value: selection)
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
            }
        }
        .blur(radius: isOverlayOpen ? 3 : 0)
        .allowsHitTesting(isOverlayOpen ? false : true)
        .overlay {
            if isOverlayOpen {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundStyle(.clear)
                    .background(.black.opacity(0.3))
                    .overlay {
                        NoInternetConnectionView()
                    }
            }
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .navigationBarColor(.white)
        .handleNetworkChanges(
            onDisconnect: {
                isOverlayOpen = true
            }, onConnect:  {
                isOverlayOpen = false
            }
        )
        .logLifecycle(viewName: "AppTabView")
    }
}

#Preview {
    ViewPreview {
        AppTabView(selection: .constant(.home))
    }
}
