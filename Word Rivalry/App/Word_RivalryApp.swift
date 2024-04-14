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
  //  case matchHistoric
}

@main
struct Word_RivalryApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    let network = Network()
    let services: AppServiceManager
    
    init() {
        let jitDataService = JITDataService<JITDataType>()
        jitDataService.registerService(LeaderboardService(), forType: .leaderboard)
       // jitDataService.registerService(MatchHistoryService(), forType: .matchHistoric)
        self.services = AppServiceManager(
            audioService: AudioSessionService(),
            profileDataService: ProfileDataService(),
            jitData: jitDataService
        )
        debugPrint("~~~ Word_RivalryApp init ~~~")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(services)
                .environment(network)
                .environment(SYPData<MatchHistoric>())
                .environment(InGameDisplaySettings())
                .onAppear(perform: self.services.handleViewDidAppear)
                .onDisappear(perform: self.services.handleViewDidDisappear)
                .onChange(of: scenePhase) {
                    self.handleScheneChange()
                }
                .logLifecycle(viewName: "Word_RivalryApp")
        }
    }
    
    private func handleScheneChange() {
        switch scenePhase {
        case .active:
            Logger.sceneEvents.notice("!!! Scene is active !!!")
            services.handleAppBecomingActive()
        case .inactive:
            Logger.sceneEvents.notice("!!! Scene is inactive !!!")
            services.handleAppGoingInactive()
        case .background:
            Logger.sceneEvents.notice("!!! Scene on background !!!")
            services.handleAppInBackground()
        default:
            break
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Logger.network.info("Registering for remote notifications")
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.network.info("Did register for remote notifications")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.network.error("ERROR: Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let zoneNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKRecordZoneNotification else {
            Logger.network.info("CloudKit database changed")
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
        
        Logger.network.info("Received zone notification: \(zoneNotification)")
        
        Task {
            do {
                debugPrint(try await PublicDatabase.shared.fetchOwnPublicProfile().debugDescription)
                completionHandler(.newData)
            } catch {
                Logger.network.error("Error in fetchLatestChanges: \(error)")
                completionHandler(.failed)
            }
        }
    }
}
