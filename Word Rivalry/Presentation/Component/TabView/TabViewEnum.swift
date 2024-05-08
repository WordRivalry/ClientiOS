//
//  TabC.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-05-01.
//

import Foundation

protocol TabViewEnum: Identifiable, RawRepresentable, CaseIterable where RawValue == String { }


/// Default implementation for `Identifiable` ID using `rawValue`.
extension TabViewEnum {
    var id: String { rawValue }
}
