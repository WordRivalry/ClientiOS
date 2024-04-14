//
//  TrieService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-02-02.
//

import Foundation
import OSLog


extension Logger {
    /// Bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Logs the JIT Data events from the app
    static let wordChecker = Logger(subsystem: subsystem, category: "WordChecker")
}

@Observable class WordChecker: ViewLifeCycle {
    private var root: TrieNode?
    static let shared = WordChecker()
    private init() {}
    
    func loadTrieFromFile(rss: String) {
        guard let url = Bundle.main.url(forResource: rss, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            Logger.wordChecker.error("Erreur lors du chargement du fichier JSON")
            return
        }
        
        do {
            root = try JSONDecoder().decode(TrieNode.self, from: data)
        } catch {
            Logger.wordChecker.error("Erreur lors de la désérialisation : \(error)")
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
    
    private var isRequired: Bool = false
    
    func handleViewDidAppear() {
        Logger.wordChecker.info("Dictionnary loading needed!")
        self.isRequired = true
        if !self.isHealthy {
            Task {
                self.loadTrieFromFile(rss: "french_trie_serialized")
                Logger.wordChecker.info("Dictionnary loaded!")
            }
        }
    }
    
    func handleViewDidDisappear() {
        self.isRequired = false
        // Dont unload yet, since we might use rss again.
    }
}

extension WordChecker: AppService {

    var isHealthy: Bool {
        get {root != nil}
        set {}
    }
    
    var identifier: String {
        "WordChecker"
    }
    
    var startPriority: ServiceStartPriority {
        .nonCritical(.max)
    }
    
    func start() async -> String {
        if isRequired {
            self.loadTrieFromFile(rss: "french_trie_serialized")
        }
        
        return "Load take place on demande"
    }
    
    func handleAppBecomingActive() { 
        if !self.isHealthy && self.isRequired {
            Task {
                await self.recover()
            }
        }
    }
    
    func handleAppGoingInactive() {}
    
    func handleAppInBackground() {
        if !self.isRequired {
            self.isHealthy = false
            self.root = nil // Release
        }
    }
}

