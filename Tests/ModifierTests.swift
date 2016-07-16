//
//  ModifierTests.swift
//
//  Copyright (c) 2015-2016 Nike, Inc. (https://www.nike.com)
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

import Foundation
import Willow
import XCTest

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

class TimestampModifierTestCase: XCTestCase {
    func testThatItModifiesMessagesAsExpected() {
        // Given
        let modifier = TimestampModifier()
        let message = "Test Message"
        let logLevels: [LogLevel] = [.error, .warn, .event, .info, .debug]

        // When
        var actualMessages = logLevels.map { modifier.modifyMessage(message, with: $0) }

        // Then
        for (index, _) in logLevels.enumerated() {
            let actualMessage = actualMessages[index]
            let expectedSuffix = " \(message)"
            XCTAssertTrue(actualMessage.hasSuffix(expectedSuffix), "Actual message should contain expected suffix")
            XCTAssertEqual(actualMessage.characters.count, 36, "Actual message 36 characters")
        }
    }
}

// MARK:

class ColorModifierTestCase: XCTestCase {

    // MARK: Properties

    var message = ""
    let escape = "\u{001b}["
    let reset = "\u{001b}[;"

    // MARK: Setup and Teardown

    override func setUp() {
        message = "Test Message"
    }

    override func tearDown() {
        message = ""
    }

    // MARK: Tests

    func testThatItAppliesForegroundColors() {
        // Given
        let red = Color(red: 0.95, green: 0.0, blue: 0.0, alpha: 1.0)
        let colorModifier = ColorModifier(foregroundColor: red, backgroundColor: nil)

        // When
        let coloredMessage = colorModifier.modifyMessage(message, with: LogLevel.debug)

        // Then
        let expectedMessage = "\(escape)fg242,0,0;Test Message\(reset)"
        XCTAssertEqual(coloredMessage, expectedMessage, "Applying the foreground color formatting failed")
    }

    func testThatItAppliesBackgroundColors() {
        // Given
        let blue = Color(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
        let colorModifier = ColorModifier(foregroundColor: nil, backgroundColor: blue)

        // When
        let coloredMessage = colorModifier.modifyMessage(message, with: LogLevel.debug)

        // Then
        let expectedMessage = "\(escape)bg45,145,255;Test Message\(reset)"
        XCTAssertEqual(coloredMessage, expectedMessage, "Applying the background color formatting failed")
    }

    func testThatItAppliesBothColors() {
        // Given
        let purple = Color(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
        let green = Color(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        let colorModifier = ColorModifier(foregroundColor: purple, backgroundColor: green)

        // When
        let coloredMessage = colorModifier.modifyMessage(message, with: LogLevel.debug)

        // Then
        let expectedMessage = "\(escape)fg153,63,255;\(escape)bg136,207,8;Test Message\(reset)"
        XCTAssertEqual(coloredMessage, expectedMessage, "Applying color formatting for both colors failed")
    }
}
