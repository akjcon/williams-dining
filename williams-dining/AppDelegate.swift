//
//  AppDelegate.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Andersen Labs. All rights reserved.
//

import UIKit
import CoreData



extension Date {
    func dayIsEarlierThan(otherDate:

        Date) -> Bool {
        let calendar = Calendar.current
        let thisComponents = calendar.dateComponents([.day, .month, .year], from: self)
        let otherComponents = calendar.dateComponents([.day, .month, .year], from: otherDate)
        if thisComponents.year! < otherComponents.year! {
            return true
        } else {
            if thisComponents.month! < otherComponents.month! {
                return true
            } else {
                return thisComponents.day! < otherComponents.day!
            }
        }
    }
}

let lastUpdatedAtKey = "lastUpdatedAt"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var controller: CentralNavigationController?

    var defaults: UserDefaults = UserDefaults.standard

    private func setColors() {
//        UILabel.appearance().tintColor = Style.secondaryColor
//        UILabel.appearance().backgroundColor = Style.defaultColor

        // UITabBarController

        // UITableView

        // UITableViewCell

        // UIButton

        // UIProgressBar

        // UILoadingIndicator (or whatever it is)

//        UITableView.appearance().tintColor

    }

    /**
     This function is called when loading the data had an error.
     */
    internal func loadingDataHadError() {
        print("Loading the data had an errror.")
        let yesterday = Date(timeInterval: -86400, since: Date())
        defaults.setValue(yesterday, forKey: lastUpdatedAtKey)

        if controller != nil {
            controller!.hideLoadingScreenWithError()
        }
    }

    internal func updateData() {
        print("Starting to update the data.")
        controller!.displayLoadingScreen()
        updateData() {(result: UIBackgroundFetchResult) in
            // eventually this will have to actually map to "new data" for real
            if result == .newData {
                self.controller!.hideLoadingScreen()

                NotificationCenter.default.post(name: reloadFavoritesTableKey, object: nil)
                NotificationCenter.default.post(name: reloadMealTableViewKey as NSNotification.Name, object: nil)
                NotificationCenter.default.post(name: reloadDiningHallTableViewKey as NSNotification.Name, object: nil)
                print("should have reloaded")
            } else {
                self.loadingDataHadError()
            }
        }
    }

    private func updateData(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        MenuLoader.fetchMenusFromAPI(completionHandler: completionHandler)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // set the status bar to white, and add a purple BG
        UIApplication.shared.statusBarStyle = .lightContent

        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20)
        let view = UIView(frame: frame)
        view.backgroundColor = Style.defaultColor
        self.window?.rootViewController!.view.addSubview(view)

        // set the background fetching interval
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)

        let yesterday = Date(timeInterval: -86400, since: Date())
        defaults.register(defaults: [lastUpdatedAtKey:yesterday])
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        controller = (storyboard.instantiateViewController(withIdentifier: "CentralController") as? CentralNavigationController)!
        controller!.application = application
        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()
        self.registerForPushNotifications(application: self.controller!.application)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        let lastUpdatedAt: Date? = defaults.value(forKey: lastUpdatedAtKey) as? Date
        guard let updatedAt = lastUpdatedAt else {
            print("updating data")
            self.updateData()
            return
        }
        if updatedAt.dayIsEarlierThan(otherDate: Date()) {
            print("updating data")
            self.updateData()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        print("attempting to save")
        self.saveContext()
    }

    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (defaults.value(forKey: lastUpdatedAtKey) as! Date).dayIsEarlierThan(otherDate: Date()) {
            print("updating data")
            updateData(completionHandler: completionHandler)
        } else {
            completionHandler(.noData)
        }

    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "williams-dining", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("PROJECTNAME.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                defaults.setValue(Date(), forKey: lastUpdatedAtKey)
            } catch {
                print("Data failed to save. Setting 'last updated' as yesterday to refresh data later.")
                let yesterday = Date(timeInterval: -86400, since: Date())
                defaults.setValue(yesterday, forKey: lastUpdatedAtKey)
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    /**
     Push notifications settings
    */

    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // all this does is prints it...
/*        let tokenChars = UnsafePointer<CChar>(deviceToken)
        var tokenString = ""

        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        */
//        print("Device Token:", tokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }

}
