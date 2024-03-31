//
//  EventSystem.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-03-30.
//

import Foundation

protocol AnyEvent {
    var anyType: AnyEventType { get }
    var data: [String: Any] { get }
    var timestamp: Date { get }
}

protocol AnyEventType {
    var rawValue: String { get }
}

protocol EventSubscriber {
    func handleEvent(_ event: AnyEvent)
}

class EventSystem {
    static let shared = EventSystem()

    private var subscribers: [String: [EventSubscriber]] = [:]

    func subscribe(_ subscriber: EventSubscriber, to eventTypes: [AnyEventType]) {
        for eventType in eventTypes {
            let key = eventType.rawValue
            if subscribers[key] == nil {
                subscribers[key] = []
            }
            subscribers[key]?.append(subscriber)
        }
    }

    func publish(event: AnyEvent) {
        guard let subs = subscribers[event.anyType.rawValue] else { return }
        for sub in subs {
            sub.handleEvent(event)
        }
        
        // Achievement hook
        AchievementsManager.shared.handleEvent(event)
    }
}

enum AchievementEventType: String, AnyEventType {
    case achievementUnlocked, pointsEarned
}

enum WordAction: String, AnyEventType, Equatable {
    case word, notAWord, alreadyDoneWord, word6Letters, word7Letters, word8Letters
}
 
enum PlayerActionEventType: AnyEventType, Equatable {
    case word(WordAction)
    case buttonClick
    case login
    
    var rawValue: String {
         switch self {
         case .word(let action):
             return "word.\(action.rawValue)"
         case .buttonClick:
             return "buttonClick"
         case .login:
             return "login"
         }
     }
}

struct AchievementEvent: AnyEvent {
    var type: AchievementEventType
    var anyType: AnyEventType { return type }
    var data: [String: Any]
    var timestamp: Date
}

struct PlayerActionEvent: AnyEvent {
    var type: PlayerActionEventType
    var anyType: AnyEventType { return type }
    var data: [String: Any]
    var timestamp: Date
}
