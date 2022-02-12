//
//  AppDelegate.swift
//  MyHome
//
//  Created by Benoit Briatte on 18/11/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: StartViewController())
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

