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

// MARK: Custom Log Levels Using Extensions

extension LogLevel {
    
    static var Verbose: LogLevel { return self(0b0000001) }
    static var Summary: LogLevel { return self(0b0001000) }
    
    static func overrideDefaults() {
        
        // Off     = 0b0000000
        // Verbose = 0b0000001
        // Debug   = 0b0000010
        // Info    = 0b0000100
        // Summary = 0b0001000
        // Event   = 0b0010000
        // Warn    = 0b0100000
        // Error   = 0b1000000
        // All     = 0b1111111
        
        LogLevel.debugOverride = 0b0000010
        LogLevel.infoOverride  = 0b0000100
        LogLevel.eventOverride = 0b0010000
        LogLevel.warnOverride  = 0b0100000
        LogLevel.errorOverride = 0b1000000
        LogLevel.allOverride   = 0b1111111
    }
    
    static func restoreDefaults() {
        LogLevel.debugOverride = nil
        LogLevel.infoOverride  = nil
        LogLevel.eventOverride = nil
        LogLevel.warnOverride  = nil
        LogLevel.errorOverride = nil
        LogLevel.allOverride   = nil
    }
}

extension Logger {
    
    public func verbose(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Verbose)
            }
        }
    }
    
    public func summary(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Summary)
            }
        }
    }
}

// MARK: - Helper Test Classes

class TestWriter: Writer {
    
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    
    func writeMessage(var message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        self.message = message
        ++self.actualNumberOfWrites
    }
}

// MARK: - Test Cases

class CustomLogLevelTestCase: XCTestCase {
    
    // MARK: Set Up and Tear Down
    
    override func setUp() {
        LogLevel.overrideDefaults()
    }
    
    override func tearDown() {
        LogLevel.restoreDefaults()
    }

    // MARK: Private - Helper Methods
    
    func logger(logLevel: LogLevel = .All, formatters: [LogLevel: [Formatter]]? = nil) -> (Logger, TestWriter) {
        let writer = TestWriter()
        
        let configuration = LoggerConfiguration(logLevel: logLevel, formatters: formatters, writers: [writer])
        let logger = Logger(configuration: configuration)
        
        return (logger, writer)
    }
    
    // MARK: Tests
    
    func testThatItLogsAsExpectedWithAllLogLevel() {
        
        // Given
        let (log, writer) = logger(logLevel: .All)
        
        // When / Then
        log.verbose { "verbose message" }
        XCTAssertEqual("verbose message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.debug { "debug message" }
        XCTAssertEqual("debug message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.info { "info message" }
        XCTAssertEqual("info message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.summary { "summary message" }
        XCTAssertEqual("summary message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.event { "event message" }
        XCTAssertEqual("event message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.warn { "warn message" }
        XCTAssertEqual("warn message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.error { "error message" }
        XCTAssertEqual("error message", writer.message ?? "", "Expected message should match actual writer message")
        
        // Then
        XCTAssertEqual(7, writer.actualNumberOfWrites, "Actual number of writes should be 7")
    }
    
    func testThatItLogsAsExpectedWithOrdLogLevels() {
        
        // Given
        let (log, writer) = logger(logLevel: .Verbose | .Info | .Summary | .Warn)
        
        // When / Then
        log.verbose { "verbose message" }
        XCTAssertEqual("verbose message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.debug { "debug message" }
        XCTAssertEqual("verbose message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.info { "info message" }
        XCTAssertEqual("info message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.summary { "summary message" }
        XCTAssertEqual("summary message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.event { "event message" }
        XCTAssertEqual("summary message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.warn { "warn message" }
        XCTAssertEqual("warn message", writer.message ?? "", "Expected message should match actual writer message")
        
        log.error { "error message" }
        XCTAssertEqual("warn message", writer.message ?? "", "Expected message should match actual writer message")
        
        // Then
        XCTAssertEqual(4, writer.actualNumberOfWrites, "Actual number of writes should be 4")
    }
}
