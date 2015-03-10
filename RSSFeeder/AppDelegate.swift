//
//  AppDelegate.swift
//  RSSFeeder
//
//  Created by Ahmed Eid on 3/7/15.
//  Copyright (c) 2015 AhmedEid. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        CoreDataManager.shared.loadFeedsFromServer(force: true)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
        CoreDataManager.shared.loadFeedsFromServer(force: false)
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataManager.shared.saveBackgroundContext()
    }
}

