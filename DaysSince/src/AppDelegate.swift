//
//  AppDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    
    // TODO:
    // Possibly rename app based on existing apps in AppStore
    //  - Daysago
    
    var window: UIWindow?
    var dataManager: DataModelManager?
    var notificationManager: NotificationManager?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
        
        // Initalize CoreData
        dataManager = DataModelManager()
        
        // Initialize the user notifications
        notificationManager = NotificationManager(dataManager: dataManager!)

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.dataManager = dataManager
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        if let dm = dataManager {
//            try? dm.saveContext()
//        }

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
        if let dm = dataManager {
            try? dm.saveContext()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url.absoluteString)

        guard let dm = dataManager else {
            return false
        }
        
        let importManager = JSONImportManager()
        guard let baseModel = importManager.buildBaseModel(from: url) else {
            // Show an error message
            let alert = UIAlertController(title: NSLocalizedString("importJSON.error.title", value: "Import failed", comment: ""), message: NSLocalizedString("importJSON.error.msg", value: "An error occurred while attempting to import the data. Either the file is not available or the contents are invalid.", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: nil))
            
            let splitViewController = self.window!.rootViewController as! UISplitViewController
            splitViewController.present(alert, animated: true, completion: nil)

            return false
        }
        
        let importTableViewController = UIStoryboard(name: "Import", bundle: nil).instantiateViewController(withIdentifier: String(describing: ImportTableViewController.self)) as! ImportTableViewController
        importTableViewController.baseModel = baseModel
        importTableViewController.dataManager = dm
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController

        navigationController.popToRootViewController(animated: false)
        navigationController.pushViewController(importTableViewController, animated: true)

        return true;
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    

}

