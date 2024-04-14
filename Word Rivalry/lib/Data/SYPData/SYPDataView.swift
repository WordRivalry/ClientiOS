//
//  SYPDataView.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-13.
//

import SwiftUI
import OSLog
import SwiftData

extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the SYP Data events from the app
    static let SYPDataView = Logger(subsystem: subsystem, category: "SYPDataView")
}

struct SYPDataView<T: PersistentModel & DataPreview, Content: View>: View {
    @Environment(SYPData<T>.self) private var sypData: SYPData<T>
    let content: (SYPData<T>) -> Content
    
    var body: some View {
        content(sypData)
    }
}

#Preview {
    ViewPreview {
        VStack {
            SYPDataView<Profile, VStack> { sypData  in
                VStack {
                    Text(sypData.fetchItems().debugDescription)
                }
            }
            
            SYPDataView<MatchHistoric, VStack> { sypData  in
                VStack {
                    Text(sypData.fetchItems().debugDescription)
                }
            }
        }
    }
}
