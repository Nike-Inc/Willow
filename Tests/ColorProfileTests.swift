//
//  ColorProfileTests.swift
//  Timber
//
//  Created by Christian Noon on 11/24/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

import UIKit
import XCTest

import Timber

class ColorProfileTests: XCTestCase {
    
    // MARK: - Private Properties
    
    var message = ""
    let escape = "\u{001b}["
    let reset = "\u{001b}[;"
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        self.message = "Test Message"
    }
    
    override func tearDown() {
        self.message = ""
    }
    
    // MARK: - Color Profile Tests
    
    func testThatItAppliesForegroundColors() {
        
        // Given
        let red = UIColor(red: 0.95, green: 0.0, blue: 0.0, alpha: 1.0)
        let colorProfile = ColorProfile(foregroundColor: red, backgroundColor: nil)
        
        // When
        let coloredMessage = colorProfile.applyColorFormattingToMessage(self.message)
        
        // Then
        XCTAssertEqual("\(self.escape)fg242,0,0;Test Message\(self.reset)", coloredMessage, "Applying the foreground color formatting failed")
    }
    
    func testThatItAppliesBackgroundColors() {

        // Given
        let blue = UIColor(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
        let colorProfile = ColorProfile(foregroundColor: nil, backgroundColor: blue)
        
        // When
        let coloredMessage = colorProfile.applyColorFormattingToMessage(self.message)
        
        // Then
        XCTAssertEqual("\(self.escape)bg45,145,255;Test Message\(self.reset)", coloredMessage, "Applying the background color formatting failed")
    }
    
    func testThatItAppliesBothColors() {

        // Given
        let purple = UIColor(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
        let green = UIColor(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        let colorProfile = ColorProfile(foregroundColor: purple, backgroundColor: green)
        
        // When
        let coloredMessage = colorProfile.applyColorFormattingToMessage(self.message)
        
        // Then
        XCTAssertEqual("\(self.escape)fg153,63,255;\(self.escape)bg136,207,8;Test Message\(self.reset)", coloredMessage, "Applying color formatting for both colors failed")
    }
    
    func testThatItAppliesNoColors() {

        // Given
        let colorProfile = ColorProfile(foregroundColor: nil, backgroundColor: nil)
        
        // When
        let coloredMessage = colorProfile.applyColorFormattingToMessage(self.message)
        
        // Then
        XCTAssertEqual("Test Message\(self.reset)", coloredMessage, "Applying color formatting with no colors failed")
    }
}
