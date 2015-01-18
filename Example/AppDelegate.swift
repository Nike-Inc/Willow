//
//  AppDelegate.swift
//  Example
//
//  Created by Christian Noon on 1/18/15.
//  Copyright (c) 2015 Nike. All rights reserved.
//

import UIKit
import Timber

var log: Logger!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var window = UIWindow(frame: UIScreen.mainScreen().bounds)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configureTimberLogger()
        
        window.rootViewController = UINavigationController(rootViewController: ViewController())
        window.backgroundColor = UIColor.whiteColor()
        window.makeKeyAndVisible()
        
        return true
    }
    
    func configureTimberLogger() {
        log = Logger(
            name: "Timber-Example",
            logLevel: Logger.LogLevel.All,
            printTimestamp: true,
            printLogLevel: true,
            timestampFormatter: nil,
            writer: nil
        )
    }
}
