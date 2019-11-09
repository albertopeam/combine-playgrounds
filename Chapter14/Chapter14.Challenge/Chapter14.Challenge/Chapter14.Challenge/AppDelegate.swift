//
//  AppDelegate.swift
//  Chapter14.Challenge
//
//  Created by Alberto Penas Amor on 07/11/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = StoriesViewController()
        window?.makeKeyAndVisible()
        return true
    }

}

