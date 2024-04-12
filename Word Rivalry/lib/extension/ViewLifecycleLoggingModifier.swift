//
//  ViewLifecycleLoggingModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-12.
//

import Foundation
import SwiftUI
import OSLog

struct LifecycleLoggingModifier: ViewModifier {
    let viewName: String

    func body(content: Content) -> some View {
        content
            .onAppear {
                Logger.viewCycle.debug("ViewLC: \(viewName) onAppear")
            }
            .onDisappear {
                Logger.viewCycle.debug("ViewLC: \(viewName) onDisappear")
            }
    }
}

extension View {
    func logLifecycle(viewName: String) -> some View {
        self.modifier(LifecycleLoggingModifier(viewName: viewName))
    }
}
