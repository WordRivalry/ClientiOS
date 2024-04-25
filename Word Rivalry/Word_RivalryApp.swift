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

@main
struct Word_RivalryApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var colorSchemeManager = ColorSchemeManager.shared
    @State private var showLaunchView = false
    @State private var purchaseManager = PurchaseManager()
    @State private var userViewModel = UserViewModel()
    
//    let network = Network()
 //   let appServices = AppServiceManager()
    
    init() {
        Logger.appEvents.notice("~~~ Word_RivalryApp init ~~~")
    }
    
    var body: some Scene {
        WindowGroup {
            
//            ZStack {
                ContentView()
            
//                ZStack {
//                    if showLaunchView {
//                        LaunchView()
//                            .transition(.move(edge: .leading))
//                    }
//                }
//                .zIndex(2.0)
//            }
      //      .onAppear(perform: self.appServices.handleViewDidAppear)
    //        .onDisappear(perform: self.appServices.handleViewDidDisappear)
            .onChange(of: scenePhase) {
                self.handleScheneChange()
            }
            .preferredColorScheme(colorSchemeManager.getPreferredColorScheme())
            .modelContainer(for: [MatchRecord.self])
       //     .environment(appServices)
            .environment(purchaseManager)
            .environment(userViewModel)
            .environment(GlobalOverlay.shared)
     //       .environment(network)
            .logLifecycle(viewName: "Word_RivalryApp")
        }
    }
    
    private func handleScheneChange() {
        switch scenePhase {
        case .active:
            Logger.appEvents.notice("!!! Scene is active !!!")
   //         appServices.handleAppBecomingActive()
        case .inactive:
            Logger.appEvents.notice("!!! Scene is inactive !!!")
    //        appServices.handleAppGoingInactive()
        case .background:
            Logger.appEvents.notice("!!! Scene on background !!!")
   //         appServices.handleAppInBackground()
        default:
            break
        }
    }
}

extension Notification.Name {
    static let modelUpdated = Notification.Name("modelUpdated")
}


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Logger.appDelegate.info("Registering for remote notifications")
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.appDelegate.info("Did register for remote notifications")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.appDelegate.error("ERROR: Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // First, log the incoming userInfo for debugging
        Logger.appDelegate.notice("Received remote notification: \(userInfo.debugDescription)")
        
        // Attempt to parse the notification as a CKNotification
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            Logger.appDelegate.error("Failed to parse CKNotification from userInfo")
            completionHandler(.noData)
            return
        }
        
        switch notification.notificationType {
        case .query:
            handleQueryNotification(notification as? CKQueryNotification, completionHandler: completionHandler)
        case .recordZone:
            handleRecordZoneNotification(notification as? CKRecordZoneNotification, completionHandler: completionHandler)
        default:
            Logger.appDelegate.info("Received unsupported notification type")
            completionHandler(.noData)
        }
    }
    
    private func handleQueryNotification(_ notification: CKQueryNotification?, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let queryNotification = notification,
              let recordID = queryNotification.recordID else {
            Logger.appDelegate.error("Notification is not a valid CKQueryNotification")
            completionHandler(.noData)
            return
        }
        
        Logger.appDelegate.info("Handling query notification for record changes \(notification.debugDescription)")
        
        NotificationCenter.default.post(
            name: .modelUpdated,
            object: queryNotification.recordFields, // dict of fiels that have changed
            userInfo: ["recordID": recordID]
        )
        completionHandler(.newData)
    }
    
    private func handleRecordZoneNotification(_ notification: CKRecordZoneNotification?, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let zoneNotification = notification else {
            Logger.appDelegate.error("Notification is not a valid CKRecordZoneNotification")
            completionHandler(.noData)
            return
        }
        
        Logger.appDelegate.info("Received zone notification: \(zoneNotification.recordZoneID)")
        Task {
            Logger.appDelegate.info("No work is done from zone notification received.")
            completionHandler(.newData)
        }
    }
}
