//
//  AppDelegate.swift
//
//  Copyright (c) 2015 Christian Noon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
        
        log = Logger(logLevel: .Debug, formatters: colorFormatters)
    }
}
