//
//  LoggerConfigurationTests.swift
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

class LoggerConfigurationTestCase: XCTestCase {
    func testThatLoggerConfigurationCanCreatedPreConfiguredTimestampConfiguration() {
        // Given
        let logLevels: [LogLevel] = [.debug, .info, .event, .warn, .error]

        // Given
        let configuration = LoggerConfiguration.timestampConfiguration()

        // Then
        XCTAssertEqual(configuration.modifiers.count, 32)

        for logLevel in logLevels {
            XCTAssertEqual(configuration.modifiers[logLevel]?.count, 1)

            if let modifiers = configuration.modifiers[logLevel], modifiers.count == 1 {
                XCTAssertTrue(modifiers[0] is TimestampModifier)
            }
        }

        XCTAssertEqual(configuration.writers.count, 32)

        for rawValue in UInt(0)..<UInt(configuration.writers.count) {
            let logLevel = LogLevel(rawValue: rawValue)

            if let writers = configuration.writers[logLevel], writers.count == 1 {
                XCTAssertTrue(writers[0] is ConsoleWriter)
            }
        }
    }
}
