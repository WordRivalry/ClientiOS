//
//  HeaderTabView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import SwiftUI

struct HeaderTabView<EnumType: TabViewEnum>: View where EnumType.AllCases: RandomAccessCollection {
    @Binding var selectedTab: EnumType
    @Namespace private var namespace
    
    var body: some View {
        HStack {
            ForEach(EnumType.allCases, id: \.id) { tab in
                Spacer()
                Text(tab.rawValue)
                    .bold()
                    .foregroundColor(selectedTab == tab ? .lightGreen : .fontColor)
                    .padding(.vertical, 10)
                  
                    .background(
                        //  Draw a rectangle for the selected tab
                        Group {
                            if selectedTab == tab {
                                Rectangle()
                                    .frame(height: 5)
                                    .foregroundColor(.lightGreen)
                                    .matchedGeometryEffect(id: "underline", in: namespace)
                            }
                        },
                        alignment: .bottom
                    )
                    .background(
                        
                        // Draw lighter rectangle for other selected tab
                        Rectangle()
                            .frame(height: 5)
                            .foregroundColor(.lightTint),
                        alignment: .bottom
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selectedTab = tab
                        }
                    }
                Spacer()
            }
        }
        .background(.white)
    }
}

enum TabEnumExample: String, TabViewEnum {
    case technology = "Technology"
    case business = "Business"
    case arts = "Arts"
}


#Preview {
    @State var selected: TabEnumExample = .technology
    return  HeaderTabView<TabEnumExample>(selectedTab: $selected)
}
