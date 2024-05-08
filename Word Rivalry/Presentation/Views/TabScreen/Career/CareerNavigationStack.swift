//
//  HomeNavigationStack.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-01.
//

import SwiftUI
import OSLog

enum CareerTabs: String, TabViewEnum {
    case general = "General"
    case seasonal = "Seasonal"
}

struct CareerNavigationStack: View {
    @Environment(LocalUser.self) private var localUser
    
    @State private var selectedCareerTab: CareerTabs = .general
    
    init() {
        Logger.viewCycle.debug("~~~ HomeNavigationStack init ~~~")
    }
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
                CareerHeaderView()
                    .headerStyle()
                HeaderTabView(selectedTab: $selectedCareerTab)
                contentView
            }
            .defaultBackgroundIgnoreSafeBottomArea()
        }
        .logLifecycle(viewName: "HomeNavigationStack")
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Divider()
                Text("General")
                    .padding(.horizontal)
                    .font(.title)
                HStack {
                    Text("Experience : ")
                    Text("\(localUser.user.experience)")
                }
                Divider()
                Text("All time")
                    .padding(.horizontal)
                    .font(.title)
                HStack {
                    Text("Points : ")
                    Text("\(localUser.user.allTimeStars)")
                }
                HStack {
                    Text("Solo match : ")
                    Text("\(localUser.user.soloMatch)")
                }
                HStack {
                    Text("Solo win : ")
                    Text("\(localUser.user.soloWin)")
                }
                HStack {
                    Text("Team match : ")
                    Text("\(localUser.user.teamMatch)")
                }
                HStack {
                    Text("Team win : ")
                    Text("\(localUser.user.teamWin)")
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ViewPreview {
        CareerNavigationStack()
    }
}
