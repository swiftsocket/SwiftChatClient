//
//  AppDelegate.swift
//  AppleChat
//
//  Created by pengyunchou on 14-8-26.
//  Copyright (c) 2014年 swift. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow!
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        self.window=UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window.makeKeyAndVisible()
        self.window.rootViewController=UINavigationController(rootViewController: SettingViewController())
        return true
    }
}

