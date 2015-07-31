//
//  AppDelegate.swift
//  Willow
//
//  Created by Christian Noon on 1/18/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import UIKit
import Willow

var log: Logger!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Creates a Willow logger without colors
//        configureWillowLogger()

        // If you want to use colored logging, you will need to have the XcodeColors plugin installed from Alcatraz
        // - XcodeColors: https://github.com/robbiehanson/XcodeColors
        // - Alcatraz: http://alcatraz.io/
        configureColoredWillowLogger()

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        self.window?.rootViewController = UINavigationController(rootViewController: ViewController())
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()

        return true
    }

    func configureWillowLogger() {
        log = Logger()
    }

    func configureColoredWillowLogger() {
        log = Logger(configuration: LoggerConfiguration.coloredTimestampConfiguration())
    }
}
