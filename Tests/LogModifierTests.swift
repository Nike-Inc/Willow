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
        let actualMessages = logLevels.map { modifier.modifyMessage(message, with: $0) }

        // Then
        for (index, _) in logLevels.enumerated() {
            let actualMessage = actualMessages[index]
            let expectedSuffix = " \(message)"
            XCTAssertTrue(actualMessage.hasSuffix(expectedSuffix), "Actual message should contain expected suffix")
            XCTAssertEqual(actualMessage.count, 36, "Actual message 36 characters")
        }
    }
}

class PropertyExpansionModifierTestCase: XCTestCase {
    func testThatAttributeExpansionWorks() {
        // Given
        let modifier = PropertyExpansionModifier()
        let message = "Method timed out: {attributes.reason}"
        let attributes = [ "reason": "Service unavailable" ]
        let logLevels: [LogLevel] = [.error, .warn, .event, .info, .debug]
        
        // When
        let modifiedMessages = logLevels.map { modifier.modifyMessage(message, with: $0, attributes: attributes)}
        
        // Then
        for (index, _) in logLevels.enumerated() {
            let actualMessage = modifiedMessages[index]
            let expectedSuffix = "Service unavailable"
            XCTAssertTrue(actualMessage.hasSuffix(expectedSuffix), "Acutal message should contain expected suffix")
        }
    }
    
    func testThatContextExpansionWorks() {
        // Given
        let modifier = PropertyExpansionModifier()
        let message = "Entered function: {context.function}"
        let context = LogMessageContext(logLevel: .error, timestamp: Date().timeIntervalSince1970, file: #file, function: #function, line: #line)
        
        // When
        let modifiedMessage = modifier.modifyMessage(message, with: context, attributes: [:])
        
        // Then
        let expectedSuffix = #function
        XCTAssertTrue(modifiedMessage.hasSuffix(expectedSuffix), "Acutal message should contain expected suffix")
    }
    
    func testThatContextAndAttributeExpansionWorks() {
        // Given
        let modifier = PropertyExpansionModifier()
        let message = "Method timed out in {context.function}: {attributes.reason}"
        let context = LogMessageContext(logLevel: .error, timestamp: Date().timeIntervalSince1970, file: #file, function: #function, line: #line)
        let attributes = [ "reason": "Service unavailable" ]

        // When
        let modifiedMessage = modifier.modifyMessage(message, with: context, attributes: attributes)
        
        // Then
        let expectedMessage = "Method timed out in \(#function): Service unavailable"
        XCTAssertEqual(expectedMessage, modifiedMessage, "Actual message should have expanded function name and reason.")
    }
}
