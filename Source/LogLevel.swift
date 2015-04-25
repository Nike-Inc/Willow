//
//  Willow.swift
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
    The `LogLevel` struct defines all the default logging levels for Willow. The default log levels can also be
    overridden using the static override properties. Customized log levels can support up to 32 different unique
    values.
*/
public struct LogLevel: RawOptionSetType {
    
    // MARK: Properties
    
    private let value: RawValue
    
    /// Defines the RawValue type as a UInt to satisfy the `RawRepresentable` protocol.
    public typealias RawValue = UInt
    
    /// Returns the raw bitmask value of the LogLevel and satisfies the `RawRepresentable` protocol.
    public var rawValue: RawValue { return self.value }
    
    /// Returns the zero value bitmask of a LogLevel and satisfies the `BitwiseOperationsType` protocol.
    public static var allZeros: LogLevel { return self(0) }
    
    //========================= Default Log Level Values =========================
    
    private static let offDefault   = LogLevel(0b00000)
    private static let debugDefault = LogLevel(0b00001)
    private static let infoDefault  = LogLevel(0b00010)
    private static let eventDefault = LogLevel(0b00100)
    private static let warnDefault  = LogLevel(0b01000)
    private static let errorDefault = LogLevel(0b10000)
    private static let allDefault   = LogLevel(0b11111)
    
    //======================== Custom Log Level Overrides ========================
    
    /// The raw value used to override the default `.Off` value. `nil` by default.
    public static var offOverride: RawValue?
    
    /// The raw value used to override the default `.Debug` value. `nil` by default.
    public static var debugOverride: RawValue?
    
    /// The raw value used to override the default `.Info` value. `nil` by default.
    public static var infoOverride: RawValue?
    
    /// The raw value used to override the default `.Event` value. `nil` by default.
    public static var eventOverride: RawValue?
    
    /// The raw value used to override the default `.Warn` value. `nil` by default.
    public static var warnOverride: RawValue?
    
    /// The raw value used to override the default `.Error` value. `nil` by default.
    public static var errorOverride: RawValue?
    
    /// The raw value used to override the default `.All` value. `nil` by default.
    public static var allOverride: RawValue?
    
    //============================ Default Log Levels ============================
    
    /// Creates a new default `.Off` instance unless overridden.
    public static var Off: LogLevel {
        return (self.offOverride != nil) ? self(self.offOverride!) : self.offDefault
    }
    
    /// Creates a new default `.Debug` instance unless overridden.
    public static var Debug: LogLevel {
        return (self.debugOverride != nil) ? self(self.debugOverride!) : self.debugDefault
    }
    
    /// Creates a new default `.Info` instance unless overridden.
    public static var Info: LogLevel {
        return (self.infoOverride != nil) ? self(self.infoOverride!) : self.infoDefault
    }
    
    /// Creates a new default `.Event` instance unless overridden.
    public static var Event: LogLevel {
        return (self.eventOverride != nil) ? self(self.eventOverride!) : self.eventDefault
    }
    
    /// Creates a new default `.Warn` instance unless overridden.
    public static var Warn: LogLevel {
        return (self.warnOverride != nil) ? self(self.warnOverride!) : self.warnDefault
    }
    
    /// Creates a new default `.Error` instance unless overridden.
    public static var Error: LogLevel {
        return (self.errorOverride != nil) ? self(self.errorOverride!) : self.errorDefault
    }
    
    /// Creates a new default `.All` instance unless overridden.
    public static var All: LogLevel {
        return (self.allOverride != nil) ? self(self.allOverride!) : self.allDefault
    }
    
    /// Creates a new `LogLevel` instance containing the `.Info`, `.Event`, `.Warn` and `.Error` log levels.
    public static var InfoAndAbove:  LogLevel { return .Debug ^ .All }
    
    /// Creates a new `LogLevel` instance containing the `.Event`, `.Warn` and `.Error` log levels.
    public static var EventAndAbove: LogLevel { return .Event | .Warn ^ .Error }
    
    /// Creates a new `LogLevel` instance containing the `.Warn` and `.Error` log levels.
    public static var WarnAndAbove:  LogLevel { return .Warn | .Error }
    
    // MARK: Initialization Methods
    
    /**
        Creates a log level instance with the given raw value.
        
        :param: rawValue The raw bitmask value for the log level.
        
        :returns: A new log level instance.
    */
    public init(rawValue: RawValue) { self.value = rawValue }
    
    /**
        Creates a log level instance with the given raw value without having to declare the external parameter name.
        
        :param: rawValue The raw bitmask value for the log level.
        
        :returns: A new log level instance.
    */
    public init(_ rawValue: RawValue) { self.value = rawValue }
    
    /**
        Creates a log level instance from a nil literal. The bitmask value defaults to zero.
        
        :param: nilLiteral The nil literal used to create the log level.
        
        :returns: A new log level instance.
    */
    public init(nilLiteral: ()) { self.value = 0 }
}

// MARK: - BooleanType

extension LogLevel: BooleanType {
    
    /// Returns whether the raw bitmask is not equal to zero.
    public var boolValue: Bool { return self.value != 0 }
}

// MARK: - Hashable

extension LogLevel: Hashable {
    
    /// Returns the hash value using the raw bitmask value of the `LogLevel`.
    public var hashValue: Int { return Int(self.value) }
}

// MARK: - Printable

extension LogLevel: Printable {
    
    /// Returns a `String` representation of the `LogLevel`.
    public var description: String {
        switch self {
        case LogLevel.Off:
            return "Off"
        case LogLevel.Debug:
            return "Debug"
        case LogLevel.Info:
            return "Info"
        case LogLevel.Warn:
            return "Warn"
        case LogLevel.Error:
            return "Error"
        case LogLevel.All:
            return "All"
        default:
            return "Unknown"
        }
    }
}

// MARK: - Equatable

/**
    Returns whether the `lhs` and `rhs` instances are equal.

    :param: lhs The left-hand side `LogLevel` instance to compare.
    :param: rhs The right-hand side `LogLevel` instance to compare.

    :returns: Whether the two instances are equal.
*/
public func ==(lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
