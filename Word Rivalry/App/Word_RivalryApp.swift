//
//  Word_RivalryApp.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-01-29.
//

import SwiftUI
import SwiftData
import OSLog
import CloudKit

enum JITDataType: JITServiceType {
    case leaderboard
    case achievements
}

@main
struct Word_RivalryApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    let services: AppServiceManager
    
    init() {
        let jitDataService = JITDataService<JITDataType>()
        jitDataService.registerService(LeaderboardService(), forType: .leaderboard)
        jitDataService.registerService(AchievementsService(), forType: .achievements)
        self.services = AppServiceManager(
            audioService: AudioSessionService(),
            profileDataService: ProfileDataService(),
            jitData: jitDataService
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(services)
            .onChange(of: scenePhase) {
                self.handleScheneChange()
            }
        }
    }
    
    private func handleScheneChange() {
        switch scenePhase {
        case .active:
            Logger.sceneEvents.info("!!! Scene is active !!!")
            NetworkChecker.shared.startMonitoring()
            services.handleAppBecomingActive()
        case .inactive:
            Logger.sceneEvents.info("!!! Scene is inactive !!!")
            services.handleAppGoingInactive()
        case .background:
            Logger.sceneEvents.info("!!! Scene on background !!!")
            NetworkChecker.shared.stopMonitoring()
            services.handleAppInBackground()
        default:
            break
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        debugPrint("Registering for remote notifications")
        UIApplication.shared.registerForRemoteNotifications()

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           debugPrint("Did register for remote notifications")
       }

       func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           debugPrint("ERROR: Failed to register for notifications: \(error.localizedDescription)")
       }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
           guard let zoneNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKRecordZoneNotification else {
               print("CloudKit database changed")
               Task {
                   await PPLocalService.sharedInstace.fetchData()
               }
               if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
                   
                   debugPrint(notification.debugDescription)
                   
                   debugPrint(userInfo.debugDescription)
                  // NotificationCenter.default.post(name: .change, object: nil)
                   completionHandler(.newData)
                   return
               }
             
               completionHandler(.noData)
               return
           }

           debugPrint("Received zone notification: \(zoneNotification)")

           Task {
               do {
                   debugPrint(try await PublicDatabase.shared.fetchOwnPublicProfile().debugDescription)
                   completionHandler(.newData)
               } catch {
                   debugPrint("Error in fetchLatestChanges: \(error)")
                   completionHandler(.failed)
               }
           }
       }
}
