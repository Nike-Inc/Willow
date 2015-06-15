//
//  LogLevel.swift
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
    The `LogLevel` struct defines all the default log levels for Willow. Each default log level has a defined bitmask
    that is guaranteed to have at least four empty bits above and below the next default log level. This allows for
    custom log levels to be inter-mixed with the default log levels very easily.
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

    private static let offBitmask  : RawValue = 0b00000000_00000000_00000000_00000000
    private static let debugBitmask: RawValue = 0b00000000_00000000_00000000_00010000 // (1 << 4)
    private static let infoBitmask : RawValue = 0b00000000_00000000_00000010_00000000 // (1 << 9)
    private static let eventBitmask: RawValue = 0b00000000_00000000_01000000_00000000 // (1 << 14)
    private static let warnBitmask : RawValue = 0b00000000_00001000_00000000_00000000 // (1 << 19)
    private static let errorBitmask: RawValue = 0b00000001_00000000_00000000_00000000 // (1 << 24)
    private static let allBitmask  : RawValue = 0b11111111_11111111_11111111_11111111

    /// Creates a new default `.Off` instance with a bitmask where all bits are equal to 0.
    public static var Off: LogLevel { return self(self.offBitmask) }

    /// Creates a new default `.Debug` instance with a bitmask of `1 << 4`.
    public static var Debug: LogLevel { return self(self.debugBitmask) }

    /// Creates a new default `.Info` instance with a bitmask of `1 << 9`.
    public static var Info: LogLevel { return self(self.infoBitmask) }

    /// Creates a new default `.Event` instance with a bitmask of `1 << 14`.
    public static var Event: LogLevel { return self(self.eventBitmask) }

    /// Creates a new default `.Warn` instance with a bitmask of `1 << 19`.
    public static var Warn: LogLevel { return self(self.warnBitmask) }

    /// Creates a new default `.Error` instance with a bitmask of `1 << 24`.
    public static var Error: LogLevel { return self(self.errorBitmask) }

    /// Creates a new default `.All` instance with a bitmask where all bits equal are equal to 1.
    public static var All: LogLevel { return self(self.allBitmask) }

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
