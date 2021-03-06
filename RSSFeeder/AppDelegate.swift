//
//  AppDelegate.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/10/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        CoreDataManager.shared.loadFeedsFromServer(forceDownload: true)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
        //Change to false if you wish to not auto refresh all feeds in app entering foreground.
        
        CoreDataManager.shared.loadFeedsFromServer(forceDownload: true)
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataManager.shared.saveBackgroundContext()
    }
}

