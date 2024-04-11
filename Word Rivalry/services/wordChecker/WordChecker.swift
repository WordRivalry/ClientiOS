//
//  TrieService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import Foundation

@Observable class WordChecker {
    private var root: TrieNode?
    static let shared = WordChecker()
    private init() {}
    
    func loadTrieFromFile(rss: String) {
        guard let url = Bundle.main.url(forResource: rss, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Erreur lors du chargement du fichier JSON")
            return
        }
        
        do {
            root = try JSONDecoder().decode(TrieNode.self, from: data)
        } catch {
            print("Erreur lors de la désérialisation : \(error)")
        }
    }
    
    func wordExists(_ word: String) -> Bool {
        guard let root = root else { return false }
        var currentNode = root
        for char in word {
            if let nextNode = currentNode.children[String(char)] {
                currentNode = nextNode
            } else {
                // Si un caractère n'est pas trouvé dans les enfants, le mot n'existe pas
                return false
            }
        }
        // Le mot existe si le dernier nœud visité marque la fin d'un mot
        return currentNode.isEndOfWord
    }
}

extension WordChecker: AppService {
    var isReady: Bool {
        root != nil
    }
    
    var isCritical: Bool {
        true
    }
    
    func start() async -> String {
        self.loadTrieFromFile(rss: "french_trie_serialized")
        return "French Dictionnary Loaded"
    }
    
    func handleAppBecomingActive() { }
    func handleAppGoingInactive() { }
    func handleAppInBackground() { } // Should release
}

