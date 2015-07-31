//
//  LogLevel.swift
//  Willow
//
//  Created by Christian Noon on 1/18/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

/**
    The `LogLevel` struct defines all the default log levels for Willow. Each default log level has a defined bitmask
    that is used to satisfy the raw value backing the log level. The empty bits that remain allow custom log levels to
    be inter-mixed with the default log levels very easily.
*/
public struct LogLevel: OptionSetType {

    // MARK: Properties

    /// Defines the RawValue type as a UInt to satisfy the `RawRepresentable` protocol.
    public typealias RawValue = UInt

    /// Returns the raw bitmask value of the LogLevel and satisfies the `RawRepresentable` protocol.
    public let rawValue: RawValue

    private static let offBitmask  : RawValue = 0b00000000_00000000_00000000_00000000
    private static let debugBitmask: RawValue = 0b00000000_00000000_00000000_00000001 // (1 << 0)
    private static let infoBitmask : RawValue = 0b00000000_00000000_00000000_00000010 // (1 << 1)
    private static let eventBitmask: RawValue = 0b00000000_00000000_00000000_00000100 // (1 << 2)
    private static let warnBitmask : RawValue = 0b00000000_00000000_00000000_00001000 // (1 << 3)
    private static let errorBitmask: RawValue = 0b00000000_00000000_00000000_00010000 // (1 << 4)
    private static let allBitmask  : RawValue = 0b11111111_11111111_11111111_11111111

    /// Creates a new default `.Off` instance with a bitmask where all bits are equal to 0.
    public static let Off = LogLevel(rawValue: offBitmask)

    /// Creates a new default `.Debug` instance with a bitmask of `1`.
    public static let Debug = LogLevel(rawValue: debugBitmask)

    /// Creates a new default `.Info` instance with a bitmask of `1 << 1`.
    public static let Info = LogLevel(rawValue: infoBitmask)

    /// Creates a new default `.Event` instance with a bitmask of `1 << 2`.
    public static let Event = LogLevel(rawValue: eventBitmask)

    /// Creates a new default `.Warn` instance with a bitmask of `1 << 3`.
    public static let Warn = LogLevel(rawValue: warnBitmask)

    /// Creates a new default `.Error` instance with a bitmask of `1 << 4`.
    public static let Error = LogLevel(rawValue: errorBitmask)

    /// Creates a new default `.All` instance with a bitmask where all bits equal are equal to `1`.
    public static let All = LogLevel(rawValue: allBitmask)

    // MARK: Initialization Methods

    /**
        Creates a log level instance with the given raw value.

        - parameter rawValue: The raw bitmask value for the log level.

        - returns: A new log level instance.
    */
    public init(rawValue: RawValue) { self.rawValue = rawValue }
}

// MARK: - Hashable

extension LogLevel: Equatable, Hashable {

    /// Returns the hash value using the raw bitmask value of the `LogLevel`.
    public var hashValue: Int { return Int(self.rawValue) }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {

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

    - parameter lhs: The left-hand side `LogLevel` instance to compare.
    - parameter rhs: The right-hand side `LogLevel` instance to compare.

    - returns: Whether the two instances are equal.
*/
public func ==(lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
