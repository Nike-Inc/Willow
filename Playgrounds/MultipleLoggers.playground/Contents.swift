//
//  MultipleLoggers.playground
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
import UIKit
import Willow

//======================================================================================================================

// Let's create a custom `PrefixFormatter` to add a prefix to each log message

struct PrefixFormatter: Formatter {
    let prefix: String
    
    init(prefix: String) {
        self.prefix = prefix
    }
    
    func formatMessage(message: String, logLevel: LogLevel) -> String {
        return "[\(self.prefix)] => \(message)"
    }
}

//======================================================================================================================

// Create a serial dispatch queue to share between the different loggers

let queue: dispatch_queue_t = {
    let label = String(format: "com.nike.surge.example-%08x%08x", arc4random(), arc4random())
    return dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL)
}()

//======================================================================================================================

// The following loggers are all configured with different prefixes and are meant to represent different frameworks 
// linked into an application.

let timestampFormatter = TimestampFormatter()

let networkLog: Logger = {
    let prefixFormatter = PrefixFormatter(prefix: "Network")
    let formatterArray: [Formatter] = [prefixFormatter, timestampFormatter]
    
    let formatters: [LogLevel: [Formatter]] = [
        .Debug: formatterArray,
        .Info: formatterArray,
        .Event: formatterArray,
        .Warn: formatterArray,
        .Error: formatterArray
    ]
    
    let configuration = LoggerConfiguration(logLevel: .All, formatters: formatters)
    return Logger(configuration: configuration)
}()

let dataLog: Logger = {
    let prefixFormatter = PrefixFormatter(prefix: "Data")
    let formatterArray: [Formatter] = [prefixFormatter, timestampFormatter]
    
    let formatters: [LogLevel: [Formatter]] = [
        .Debug: formatterArray,
        .Info: formatterArray,
        .Event: formatterArray,
        .Warn: formatterArray,
        .Error: formatterArray
    ]
    
    let configuration = LoggerConfiguration(logLevel: .All, formatters: formatters)
    return Logger(configuration: configuration)
}()

let appLog: Logger = {
    let prefixFormatter = PrefixFormatter(prefix: "App")
    
    let formatters: [LogLevel: [Formatter]] = [
        .Debug: [prefixFormatter, timestampFormatter],
        .Info: [prefixFormatter, timestampFormatter],
        .Event: [prefixFormatter, timestampFormatter],
        .Warn: [prefixFormatter, timestampFormatter],
        .Error: [prefixFormatter, timestampFormatter]
    ]
    
    let configuration = LoggerConfiguration(logLevel: .All, formatters: formatters)
    return Logger(configuration: configuration)
}()

//======================================================================================================================

// The log message below demonstrate a common scenario of a user searching for additional items in
// a list. This example shows how the different loggers may be used in combination between multiple
// frameworks.

appLog.debug { "User scrolling through current list of items" }
appLog.event { "Search Button Tapped" }
appLog.info { "Starting search request" }

networkLog.event { "Search - request beginning" }
networkLog.debug { "Search - response received" }
networkLog.debug { "Search - parsing response data" }
networkLog.event { "Search request complete" }

appLog.info { "Search request results received" }

appLog.debug { "Starting to write search request results to disk" }

for index in 1...10 {
    dataLog.event { "Creating search result object \(index)" }
    dataLog.debug { "Starting to write search result object \(index) to disk" }
    dataLog.debug { "Finished writing search result object \(index) to disk" }
}

appLog.debug { "Finished writing search request results to disk" }

appLog.event { "Updating search results display for user" }
