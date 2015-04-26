//
//  Logger.swift
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

/**
    The Logger class is a fully thread-safe, synchronous or asynchronous logging solution using dependency injection
    to allow custom Formatters and Writers. It also manages all the logic to determine whether to log a particular
    message with a given log level.

    Loggers can only be configured during initialization. If you need to change a logger at runtime, it is advised to
    create an additional logger with a custom configuration to fit your needs.
*/
public class Logger {
    
    // MARK: - Properties
    
    /// Controls whether to allow log messages to be sent to the writers.
    public var enabled = true
    
    /// The configuration to use when determining how to log messages.
    public let configuration: LoggerConfiguration
    
    /// The dispatch method used when executing a log operation on the internal dispatch queue.
    public let dispatch_method: (dispatch_queue_t, dispatch_block_t) -> Void
    
    // MARK: - Initialization Methods
    
    /**
        Initializes a logger instance.
        
        :param: configuration The configuration to use when determining how to log messages. Creates a default
                              `LoggerConfiguration()` by default.
        
        :returns: A fully initialized logger instance.
    */
    public init(configuration: LoggerConfiguration = LoggerConfiguration()) {
        self.configuration = configuration
        self.dispatch_method = self.configuration.asynchronous ? dispatch_async : dispatch_sync
    }
    
    // MARK: - Log Methods
    
    /**
        Writes out the given message closure string with the logger configuration if the debug log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func debug(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Debug)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the info log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func info(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Info)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the event log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func event(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Event)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the warn log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func warn(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Warn)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the error log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func error(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) {
                self.logMessageIfAllowed(closure, logLevel: .Error)
            }
        }
    }
    
    // MARK: - Log Level Allowed Methods
    
    /**
        Executes the closure and logs the resulting message if the log level is allowed.
        
        :param: closure  The closure returning the message to log.
        :param: logLevel The log level associated with the closure.
    */
    public func logMessageIfAllowed(closure: () -> String, logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            logMessage(closure(), logLevel: logLevel)
        }
    }
    
    // MARK: - Private - Helper Methods
    
    private func logLevelAllowed(logLevel: LogLevel) -> Bool {
        return logLevel & self.configuration.logLevel ? true : false
    }
    
    private func logMessage(var message: String, logLevel: LogLevel) {
        let formatters = self.configuration.formatters[logLevel]
        self.configuration.writers.map { $0.writeMessage(message, logLevel: logLevel, formatters: formatters) }
    }
}
