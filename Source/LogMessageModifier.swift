//
//  LogMessageModifier.swift
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

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias Color = UIColor
#elseif os(OSX)
import Cocoa
public typealias Color = NSColor
#endif

/// The LogMessageModifier protocol defines a single method for modifying a log message after it has been constructed.
/// This is very flexible allowing any object that conforms to modify messages in any way it wants.
public protocol LogMessageModifier {
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String
}

// MARK: -

/// The TimestampModifier class applies a timestamp to the beginning of the message.
open class TimestampModifier: LogMessageModifier {
    private let timestampFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    /// Initializes a `TimestampModifier` instance.
    ///
    /// - returns: A new `TimestampModifier` instance.
    public init() {}

    /// Applies a timestamp to the beginning of the message.
    ///
    /// - parameter message:  The original message to format.
    /// - parameter logLevel: The log level set for the message.
    ///
    /// - returns: A newly formatted message.
    open func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        let timestampString = timestampFormatter.string(from: Date() as Date)
        return "\(timestampString) \(message)"
    }
}

// MARK: -

/// The ColorModifier class takes foreground and background colors and applies them to a given message. It uses the
/// XcodeColors plugin color formatting scheme.
///
/// NOTE: These should only be used with the XcodeColors plugin.
open class ColorModifier: LogMessageModifier {

    // MARK: Helper Types

    private struct ColorConstants {
        static let ESCAPE = "\u{001b}["
        static let RESET_FG = ESCAPE + "fg;"
        static let RESET_BG = ESCAPE + "bg;"
        static let RESET = ESCAPE + ";"
    }

    // MARK: Properties

    private let foregroundText: String
    private let backgroundText: String

    // MARK: Initialization

    /// Returns a fully constructed `ColorModifier` from the specified `Color` objects.
    ///
    /// - parameter foregroundColor: The color to apply to the foreground.
    /// - parameter backgroundColor: The color to apply to the background.
    ///
    /// - returns: A new `ColorModifier` instance.
    public init(foregroundColor: Color?, backgroundColor: Color?) {
        let foregroundTextString = ColorModifier.textString(from: foregroundColor)
        let backgroundTextString = ColorModifier.textString(from: backgroundColor)

        if !foregroundTextString.isEmpty {
            foregroundText = "\(ColorConstants.ESCAPE)fg\(foregroundTextString);"
        } else {
            foregroundText = ""
        }

        if !backgroundTextString.isEmpty {
            backgroundText = "\(ColorConstants.ESCAPE)bg\(backgroundTextString);"
        } else {
            backgroundText = ""
        }
    }

    // MARK: Modifier

    /// Applies the foreground, background and reset color modifier values to the given message.
    ///
    /// - parameter message: The message to apply the color modification to.
    ///
    /// - returns: A new string with all the color modifier values added.
    open func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        return "\(foregroundText)\(backgroundText)\(message)\(ColorConstants.RESET)"
    }

    // MARK: Private - Helper Methods

    private class func textString(from color: Color?) -> String {
        var textString = ""

        if let color = color {
            var redValue: CGFloat = 0.0
            var greenValue: CGFloat = 0.0
            var blueValue: CGFloat = 0.0

            // Since the colorspace on OSX is not guaranteed to be `deviceRGBColorSpace`, the color must be converted
            // to guarantee that the `getRed(_:green:blue:alpha:)` call will succeed.
            #if os(OSX)
                if let rgbColor = color.usingColorSpace(NSColorSpace.deviceRGB) {
                    rgbColor.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: nil)
                }
            #else
                color.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: nil)
            #endif

            let maxValue: CGFloat = 255.0

            let redInt = UInt8(round(redValue * maxValue))
            let greenInt = UInt8(round(greenValue * maxValue))
            let blueInt = UInt8(round(blueValue * maxValue))

            textString = "\(redInt),\(greenInt),\(blueInt)"
        }

        return textString
    }
}
