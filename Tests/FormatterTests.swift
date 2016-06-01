//
//  FormatterTests.swift
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

import Willow
import XCTest

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

class TimestampFormatterTestCase: XCTestCase {
    func testThatItFormatsMessagesAsExpected() {
        // Given
        let formatter = TimestampFormatter()
        let message = "Test Message"
        let logLevels: [LogLevel] = [.Error, .Warn, .Event, .Info, .Debug]

        // When
        var actualMessages = logLevels.map { formatter.formatMessage(message, logLevel: $0) }

        // Then
        for (index, _) in logLevels.enumerate() {
            let actualMessage = actualMessages[index]
            let expectedSuffix = " \(message)"
            XCTAssertTrue(actualMessage.hasSuffix(expectedSuffix), "Actual message should contain expected suffix")
            XCTAssertEqual(actualMessage.characters.count, 36, "Actual message 36 characters")
        }
    }
}

// MARK: -

class ColorFormatterTestCase: XCTestCase {
    var message = ""
    let escape = "\u{001b}["
    let reset = "\u{001b}[;"

    override func setUp() {
        self.message = "Test Message"
    }

    override func tearDown() {
        self.message = ""
    }

    func testThatItAppliesForegroundColors() {
        // Given
        let red = Color(red: 0.95, green: 0.0, blue: 0.0, alpha: 1.0)
        let colorFormatter = ColorFormatter(foregroundColor: red, backgroundColor: nil)

        // When
        let coloredMessage = colorFormatter.formatMessage(self.message, logLevel: .Debug)

        // Then
        let expectedMessage = "\(self.escape)fg242,0,0;Test Message\(self.reset)"
        XCTAssertEqual(coloredMessage, expectedMessage, "Applying the foreground color formatting failed")
    }

    func testThatItAppliesBackgroundColors() {
        // Given
        let blue = Color(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
        let colorFormatter = ColorFormatter(foregroundColor: nil, backgroundColor: blue)

        // When
        let coloredMessage = colorFormatter.formatMessage(self.message, logLevel: .Debug)

        // Then
        let expectedMessage = "\(self.escape)bg45,145,255;Test Message\(self.reset)"
        XCTAssertEqual(coloredMessage, expectedMessage, "Applying the background color formatting failed")
    }

    func testThatItAppliesBothColors() {
        // Given
        let purple = Color(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
        let green = Color(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        let colorFormatter = ColorFormatter(foregroundColor: purple, backgroundColor: green)

        // When
        let coloredMessage = colorFormatter.formatMessage(self.message, logLevel: .Debug)

        // Then
        let expectedMessage = "\(self.escape)fg153,63,255;\(self.escape)bg136,207,8;Test Message\(self.reset)"
        XCTAssertEqual(coloredMessage, expectedMessage, "Applying color formatting for both colors failed")
    }
}
