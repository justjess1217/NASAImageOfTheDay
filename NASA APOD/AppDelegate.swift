//
//  AppDelegate.swift
//  NASA APOD
//
//  Created by Nathan Hosselton on 7/18/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import CBNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CBNetworking.APOD.apiAuthKey = "4BSCHvrqBaQOhZ3mXGG3FeHaqX6B3aGtnoEQr7iX"
        return true
    }
}
