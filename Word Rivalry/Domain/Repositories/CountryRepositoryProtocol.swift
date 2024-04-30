//
//  CountryRepository.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-26.
//

import Foundation

protocol CountryAdapterProtocol {
    func getAllCountries() async throws -> [Country]
}
