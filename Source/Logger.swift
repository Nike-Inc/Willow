//
//  Logger.swift
//
//  Copyright (c) 2015, Christian Noon
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

/**
    The Logger class is a fully thread-safe, asynchronous logging solution using dependency injection to allow custom
    Formatters and Writers. It also manages all the logic to determine whether to log a particular message with a given
    log level.

    Loggers can only be configured during initialization. If you need to change a logger at runtime, it is advised to
    create an additional logger with a custom configuration to fit your needs.
*/
public class Logger {

    // MARK: - LogLevel Enum
    
    /**
        The LogLevel enum defines all the possible logging levels for Timber.
    
        - Error: Allows Error messages to be logged.
        - Warn:  Allows Warn and Error messages to be logged.
        - Event: Allows Event, Warn and Error messages to be logged.
        - Info:  Allows Info, Event, Warn and Error messages to be logged.
        - Debug: Allows Debug, Info, Event, Warn and Error messages to be logged.
    */
    public enum LogLevel: UInt, Printable {
        case Error = 0, Warn, Event, Info, Debug
        
        public var description: String {
            switch self {
            case .Error:
                return "Error"
            case .Warn:
                return "Warn"
            case .Event:
                return "Event"
            case .Info:
                return "Info"
            case .Debug:
                return "Debug"
            }
        }
    }

    // MARK: - Properties
    
    /// Controls whether to allow log messages to be sent to the writers.
    public var enabled = true
    
    // MARK: - Private - Properties
    
    private let logLevel: LogLevel
    private let formatters: [LogLevel: [Formatter]]
    private let writers: [Writer]
    private let queue: dispatch_queue_t
    
    // MARK: - Initialization Methods
    
    /**
        Initializes a logger instance.
    
        :param: logLevel   The logging level used to determine which messages are written. `.Info` by default.
        :param: formatters The dictionary of formatters to apply to each associated log level. `nil` by default.
        :param: writers    The writers to use when messages are written. `[ConsoleWriter()]` by default.
        :param: queue      A custom queue to swap out for the default one. This allows sharing queues between multiple
                           logger instances. `nil` by default.
    
        :returns: A fully initialized logger instance.
    */
    public init(
        logLevel: LogLevel = .Info,
        formatters: [LogLevel: [Formatter]]? = nil,
        writers: [Writer] = [ConsoleWriter()],
        queue: dispatch_queue_t? = nil)
    {
        self.logLevel = logLevel
        self.formatters = formatters ?? [LogLevel: [Formatter]]()
        self.writers = writers
        self.queue = queue ?? {
            let label = NSString(format: "com.timber.logger-%08x%08x", arc4random(), arc4random())
            return dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL)
        }()
    }
    
    // MARK: - Logging Methods
    
    /**
        Writes out the given message with the logger configuration if the debug log level is allowed.
        
        :param: message The message to write out.
    */
    public func debug(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Debug)
            }
        }
    }

    /**
        Writes out the given message closure string with the logger configuration if the debug log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func debug(closure: () -> String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Debug)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the info log level is allowed.
        
        :param: message The message to write out.
    */
    public func info(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Info)
            }
        }
    }

    /**
        Writes out the given message closure string with the logger configuration if the info log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func info(closure: () -> String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Info)
            }
        }
    }

    /**
        Writes out the given message with the logger configuration if the event log level is allowed.
        
        :param: message The message to write out.
    */
    public func event(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Event)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the event log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func event(closure: () -> String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Event)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the warn log level is allowed.
        
        :param: message The message to write out.
    */
    public func warn(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Warn)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the warn log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func warn(closure: () -> String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Warn)
            }
        }
    }

    /**
        Writes out the given message with the logger configuration if the error log level is allowed.
        
        :param: message The message to write out.
    */
    public func error(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Error)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the error log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func error(closure: () -> String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Error)
            }
        }
    }
    
    // MARK: - Private - Logging Helper Methods
    
    private func logMessageIfAllowed(message: String, logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            logMessage(message, logLevel: logLevel)
        }
    }
    
    private func logMessageIfAllowed(closure: () -> String, logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            logMessage(closure(), logLevel: logLevel)
        }
    }
    
    private func logLevelAllowed(logLevel: LogLevel) -> Bool {
        return logLevel.rawValue <= self.logLevel.rawValue
    }
    
    private func logMessage(var message: String, logLevel: LogLevel) {
        let formatters = self.formatters[logLevel]
        self.writers.map { $0.writeMessage(message, logLevel: logLevel, formatters: formatters) }
    }
}
