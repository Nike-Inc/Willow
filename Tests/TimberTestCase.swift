//
//  TimberTestCase.swift
//  Timber
//
//  Created by Christian Noon on 1/19/15.
//  Copyright (c) 2015 Nike. All rights reserved.
//

import UIKit
import XCTest

class TimberTestCase: XCTestCase {
    
    override func setUp() {
        let calendar = NSCalendar.currentCalendar()
        
        var components = NSDateComponents()
        components.year = 2014
        components.month = 10
        components.day = 3
        components.hour = 8
        components.minute = 20
        components.second = 45
        
        let frozenDate = calendar.dateFromComponents(components)
        
        TUDelorean.freeze(frozenDate)
    }
    
    override func tearDown() {
        TUDelorean.backToThePresent()
    }
}
