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
        let logSource = LogSource(file: #file, function: #function, line: #line, column: #column)

        // When
        let actualMessages = logLevels.map { modifier.modifyMessage(message, with: $0, at: logSource) }

        // Then
        for (index, _) in logLevels.enumerated() {
            let actualMessage = actualMessages[index]
            let expectedSuffix = " \(message)"
            XCTAssertTrue(actualMessage.hasSuffix(expectedSuffix), "Actual message should contain expected suffix")
            XCTAssertEqual(actualMessage.count, 36, "Actual message 36 characters")
        }
    }
}

class SourceModifierTestCase: XCTestCase {
    func testThatItModifiesAMessageLogLevelIndependent() {
        // Given
        let modifier = SourceModifier()
        let message = "A Message"
        let logLevels: [LogLevel] = [.error, .warn, .event, .info, .debug]
        let logSource = LogSource(file: "File", function: "Function", line: 1, column: 2)

        // When
        let actualMessages = logLevels.map { modifier.modifyMessage(message, with: $0, at: logSource) }

        // Then
        let messageSet = Set(actualMessages)
        XCTAssertEqual(1, messageSet.count, "All actual messages should be equal")
    }

    func testThatItModifiesAMessageRespectingFileAndLineOfSource() {
        // Given
        let modifier = SourceModifier()
        let message = "Test Message"
        let logLevel = LogLevel.debug
        let logFile: StaticString = "LogFile"
        let logLine: UInt = 42
        let logSource = LogSource(file: logFile, function: "", line: logLine, column: 0)

        // When
        let actualMessage = modifier.modifyMessage(message, with: logLevel, at: logSource)

        // Then
        let expectedMessage = "\(logFile):\(logLine) \(message)"
        XCTAssertEqual(actualMessage, expectedMessage, "Actual message should equal the expected")
    }
}
