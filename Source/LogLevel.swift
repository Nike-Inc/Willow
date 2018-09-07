//
//  LogLevel.swift
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

/// The `LogLevel` struct defines all the default log levels for Willow. Each default log level has a defined bitmask
/// that is used to satisfy the raw value backing the log level. The empty bits that remain allow custom log levels to
/// be inter-mixed with the default log levels very easily.
public struct LogLevel: OptionSet, Equatable, Hashable {

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

    /// Creates a new default `.off` instance with a bitmask where all bits are equal to 0.
    public static let off = LogLevel(rawValue: offBitmask)

    /// Creates a new default `.debug` instance with a bitmask of `1`.
    public static let debug = LogLevel(rawValue: debugBitmask)

    /// Creates a new default `.info` instance with a bitmask of `1 << 1`.
    public static let info = LogLevel(rawValue: infoBitmask)

    /// Creates a new default `.event` instance with a bitmask of `1 << 2`.
    public static let event = LogLevel(rawValue: eventBitmask)

    /// Creates a new default `.warn` instance with a bitmask of `1 << 3`.
    public static let warn = LogLevel(rawValue: warnBitmask)

    /// Creates a new default `.error` instance with a bitmask of `1 << 4`.
    public static let error = LogLevel(rawValue: errorBitmask)

    /// Creates a new default `.all` instance with a bitmask where all bits equal are equal to `1`.
    public static let all = LogLevel(rawValue: allBitmask)

    // MARK: Initialization Methods

    /// Creates a log level instance with the given raw value.
    ///
    /// - Parameter rawValue: The raw bitmask value for the log level.
    ///
    /// - Returns: A new log level instance.
    public init(rawValue: RawValue) { self.rawValue = rawValue }
}

// MARK: - CustomStringConvertible

extension LogLevel: CustomStringConvertible {
    /// Returns a `String` representation of the `LogLevel`.
    public var description: String {
        switch self {
        case LogLevel.off:
            return "Off"
        case LogLevel.debug:
            return "Debug"
        case LogLevel.info:
            return "Info"
        case LogLevel.event:
            return "Event"
        case LogLevel.warn:
            return "Warn"
        case LogLevel.error:
            return "Error"
        case LogLevel.all:
            return "All"
        default:
            return "Unknown"
        }
    }
}
