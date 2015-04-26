//
//  CustomLogLevels.playground
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

import Foundation
import Willow

//======================================================================================================================

// Define some custom log levels to use. Make sure to keep them private or internal to avoid exposing
// them to other frameworks or applications.

extension LogLevel {
    
    // Off      = 0b00000000_00000000_00000000_00000000
    // Verbose  = 0b00000000_00000000_00000000_00000100 // custom
    // Debug    = 0b00000000_00000000_00000000_00010000
    // Info     = 0b00000000_00000000_00000010_00000000
    // Summary  = 0b00000000_00000000_00001000_00000000 // custom
    // Event    = 0b00000000_00000000_01000000_00000000
    // Warn     = 0b00000000_00001000_00000000_00000000
    // Error    = 0b00000001_00000000_00000000_00000000
    // Critical = 0b00001000_00000000_00000000_00000000 // custom
    // All      = 0b11111111_11111111_11111111_11111111
    
    private static var Verbose: LogLevel { return self(0b00000000_00000000_00000000_00000100) }
    private static var Summary: LogLevel { return self(0b00000000_00000000_00001000_00000000) }
    private static var Critical: LogLevel { return self(0b00001000_00000000_00000000_00000000) }
}

//======================================================================================================================

// Create a `Logger` extension and add a custom method for each new custom log level. Make sure to keep these 
// methods private or internal to avoid exposing the methods to other frameworks or applications.

extension Logger {
    
    private func verbose(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Verbose)
            }
        }
    }
    
    private func summary(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Summary)
            }
        }
    }
    
    private func critical(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Critical)
            }
        }
    }
}

//======================================================================================================================

// Create a new log instance

let logLevel = LogLevel.All
//let logLevel = LogLevel.Info | LogLevel.Summary | LogLevel.Event | LogLevel.Error

// Needs XcodeColors plugin
let log = Logger(configuration: LoggerConfiguration.coloredTimestampConfiguration(logLevel: logLevel))

// Use if missing XcodeColors plugin, use this logger instead
//let log = Logger(configuration: LoggerConfiguration.timestampConfiguration())

//======================================================================================================================

// Test out all the log methods that are available

log.verbose { "verbose message" }
log.debug { "debug message" }
log.info { "info message" }
log.summary { "summary message" }
log.event { "event message" }
log.warn { "warn message" }
log.error { "error message" }
log.critical { "critical message" }

//======================================================================================================================

// Closures are also useful for encapsulating logic that is only required to construct the log message. If the
// `.Verbose` log level is not enabled, then none of the logic inside the closure will execute making this logic
// incredibly efficient.

log.verbose {
    var sum: UInt = 0
    
    for _ in 1...100 {
        let randomValue = UInt(arc4random_uniform(1000))
        sum += randomValue
    }
    
    return "Today's Date: [\(NSDate())] with random number sum: \(sum)"
}
