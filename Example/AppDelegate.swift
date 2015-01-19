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
        
        // Creates a Timber logger without colors
//        configureTimberLogger()
        
        // If you want to use colored logging, you will need to have the XcodeColors plugin installed from Alcatraz
        // - XcodeColors: https://github.com/robbiehanson/XcodeColors
        // - Alcatraz: http://alcatraz.io/
        configureColoredTimberLogger()
        
        window.rootViewController = UINavigationController(rootViewController: ViewController())
        window.backgroundColor = UIColor.whiteColor()
        window.makeKeyAndVisible()
        
        return true
    }
    
    func configureTimberLogger() {
        log = Logger(logLevel: .Debug)
    }
    
    func configureColoredTimberLogger() {
        let purple = UIColor(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
        let blue = UIColor(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
        let green = UIColor(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        let orange = UIColor(red: 233.0 / 255.0, green: 165.0 / 255.0, blue: 47.0 / 255.0, alpha: 1.0)
        let red = UIColor(red: 230.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
        let white = UIColor.whiteColor()
        let black = UIColor.blackColor()
        
        let defaultFormatter = DefaultFormatter()
        
        let colorFormatters: [Logger.LogLevel: [Formatter]] = [
            .Debug: [defaultFormatter, ColorFormatter(foregroundColor: purple, backgroundColor: nil)],
            .Info: [defaultFormatter, ColorFormatter(foregroundColor: blue, backgroundColor: nil)],
            .Event: [defaultFormatter, ColorFormatter(foregroundColor: green, backgroundColor: nil)],
            .Warn: [defaultFormatter, ColorFormatter(foregroundColor: black, backgroundColor: orange)],
            .Error: [defaultFormatter, ColorFormatter(foregroundColor: white, backgroundColor: red)]
        ]
        
        log = Logger(
            logLevel: .Debug,
            formatters: colorFormatters,
            writers: nil
        )
    }
}
