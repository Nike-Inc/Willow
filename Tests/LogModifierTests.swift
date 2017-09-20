//
//  LogModifierTests.swift
//
//  Copyright (c) 2015-present Nike, Inc. (https://www.nike.com)
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
