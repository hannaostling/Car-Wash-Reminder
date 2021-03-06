//
//  AppDelegate.swift
//  Car Wash Reminder
//
//  Created by Hanna Östling on 2018-10-08.
//  Copyright © 2018 Hanna Östling. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        window = UIApplication.shared.keyWindow!
        let navigationController = window?.rootViewController as! UINavigationController
        if let homeVC = navigationController.viewControllers[0] as? HomeViewController {
            let logic = Logic.sharedInstance
            logic.readUserDefaults()
            let cityName = logic.user.lastSearchedCity
            let url = logic.FORECAST_URL
            let cityParams = logic.user.cityParams
            let positionParams = logic.user.positionParams
            if cityName != "" {
                homeVC.getWeatherData(url: url, parameters: cityParams)
                homeVC.notifyUser(washToday: homeVC.logic.washToday)
                completionHandler(.newData)
                print("")
                print("Succeeded to get data with city params")
            } else if homeVC.logic.user.lastSearchedCity == "" {
                homeVC.getWeatherData(url: url, parameters: positionParams)
                homeVC.notifyUser(washToday: homeVC.logic.washToday)
                completionHandler(.newData)
                print("")
                print("Succeeded to get data with position params")
            } else {
                completionHandler(.failed)
                print("Failed to get data")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
