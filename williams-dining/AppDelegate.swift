//
//  AppDelegate.swift
//  williams-dining
//
//  Created by Nathan Andersen on 4/13/16.
//  Copyright © 2016 Gladden Labs. All rights reserved.
//

import UIKit
import CoreData



extension NSDate {
    func dayIsEarlierThan(otherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let thisComponents = calendar.components([.Day, .Month, .Year], fromDate: self)
        let otherComponents = calendar.components([.Day, .Month, .Year], fromDate: otherDate)
        if thisComponents.year < otherComponents.year {
            return true
        } else {
            if thisComponents.month < otherComponents.month {
                return true
            } else {
                return thisComponents.day < otherComponents.day
            }
        }
    }
}

let lastUpdatedAtKey = "lastUpdatedAt"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var controller: CentralNavigationController?
//    var controller: CentralTabBarController?

    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

    /**
     This function is called when loading the data had an error.
     */
    internal func loadingDataHadError() {
        print("not saved")
        let yesterday = NSDate(timeInterval: -86400, sinceDate: NSDate())
        defaults.setValue(yesterday, forKey: lastUpdatedAtKey)

        if controller != nil {
            controller!.hideLoadingScreenWithError()
        }
    }

    internal func updateData() {
        print("starting update")
        controller!.displayLoadingScreen()
        updateData() {(result: UIBackgroundFetchResult) in
            if result == .NewData {
                self.controller!.hideLoadingScreen()


                NSNotificationCenter.defaultCenter().postNotificationName(reloadFavoritesTableKey, object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("reloadMealTableView", object: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("reloadDiningHallTableView", object: nil)
            } else {
                self.loadingDataHadError()
            }
            self.registerForPushNotifications(self.controller!.application)
        }
    }

    private func updateData(completionHandler: (UIBackgroundFetchResult) -> Void) {
        MenuLoader.fetchMenusFromAPI(completionHandler)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        // set the status bar to white, and add a purple BG
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        let view = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,20))
        view.backgroundColor = Style.primaryColor
        self.window?.rootViewController!.view.addSubview(view)


        // set the background fetching interval
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)

        let yesterday = NSDate(timeInterval: -86400, sinceDate: NSDate())
        defaults.registerDefaults([lastUpdatedAtKey:yesterday])
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        controller = (storyboard.instantiateViewControllerWithIdentifier("CentralController") as? CentralNavigationController)!
        controller!.application = application
        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (defaults.valueForKey(lastUpdatedAtKey) as! NSDate).dayIsEarlierThan(NSDate()) {
            print("updating data")
            self.updateData()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        print("attempting to save")
        self.saveContext()
    }

    // Support for background fetch
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if (defaults.valueForKey(lastUpdatedAtKey) as! NSDate).dayIsEarlierThan(NSDate()) {
            print("updating data")
            updateData(completionHandler)
        } else {
            completionHandler(.NoData)
        }

    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("williams-dining", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("PROJECTNAME.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                defaults.setValue(NSDate(), forKey: lastUpdatedAtKey)
            } catch {
                print("not saved")
                let yesterday = NSDate(timeInterval: -86400, sinceDate: NSDate())
                defaults.setValue(yesterday, forKey: lastUpdatedAtKey)
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
            }
        }
    }

    /**
     Push notifications settings
    */

    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""

        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
//        print("Device Token:", tokenString)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
}

