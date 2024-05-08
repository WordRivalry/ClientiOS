//
//  RandomCaseProvidable.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-07.
//

import Foundation

protocol RandomCaseProvidable: CaseIterable {
    static func random() -> Self
}

extension RandomCaseProvidable {
    static func random() -> Self {
        guard let randomElement = allCases.randomElement() else {
            fatalError("Cannot access random element from an empty collection")
        }
        return randomElement
    }
}
