//
//  ServiceEnvironmentModifier.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-11.
//

import Foundation
import SwiftUI

struct ServiceEnvironmentModifier: ViewModifier {
    let coordinator: ServiceCoordinator

    func body(content: Content) -> some View {
        injectServices(from: coordinator, into: content)
    }

    
    private func injectServices(from coordinator: ServiceCoordinator, into content: Content) -> some View {
        var currentContent = content  // Start with the content passed in

        let mirror = Mirror(reflecting: coordinator)
        for child in mirror.children {
            if let observableService = child.value as? Observable & AnyObject {
                // Check if the service is both Observable and a class instance
                currentContent = currentContent.environment(observableService) as! ServiceEnvironmentModifier.Content  // Directly assign to currentContent
            } else if let nestedCoordinator = child.value as? ServiceCoordinator {
                // Recursively handle nested ServiceCoordinators
                currentContent = injectServices(from: nestedCoordinator, into: currentContent) as! ServiceEnvironmentModifier.Content  // Recurse and assign
            }
        }

        return currentContent  // Return the modified content
    }
}






extension View {
    func environmentServices(coordinator: ServiceCoordinator) -> some View {
        self.modifier(ServiceEnvironmentModifier(coordinator: coordinator))
    }
}
