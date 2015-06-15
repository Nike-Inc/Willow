//
//  FormatterTests.swift
//
//  Copyright (c) 2015, Nike
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
//

import Willow
import XCTest

#if os(iOS)
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
        let expected = "\(self.escape)fg242,0,0;Test Message\(self.reset)"
        XCTAssertEqual(expected, coloredMessage, "Applying the foreground color formatting failed")
    }

    func testThatItAppliesBackgroundColors() {

        // Given
        let blue = Color(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
        let colorFormatter = ColorFormatter(foregroundColor: nil, backgroundColor: blue)

        // When
        let coloredMessage = colorFormatter.formatMessage(self.message, logLevel: .Debug)

        // Then
        let expected = "\(self.escape)bg45,145,255;Test Message\(self.reset)"
        XCTAssertEqual(expected, coloredMessage, "Applying the background color formatting failed")
    }

    func testThatItAppliesBothColors() {

        // Given
        let purple = Color(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
        let green = Color(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        let colorFormatter = ColorFormatter(foregroundColor: purple, backgroundColor: green)

        // When
        let coloredMessage = colorFormatter.formatMessage(self.message, logLevel: .Debug)

        // Then
        let expected = "\(self.escape)fg153,63,255;\(self.escape)bg136,207,8;Test Message\(self.reset)"
        XCTAssertEqual(expected, coloredMessage, "Applying color formatting for both colors failed")
    }
}
