# Changelog

All notable changes to this project will be documented in this file.
`Willow` adheres to [Semantic Versioning](http://semver.org/).

#### 4.x Releases

- `4.0.x` Releases - [4.0.0](#400)

#### 3.x Releases

- `3.0.x` Releases - [3.0.0](#300) | [3.0.1](#301) | [3.0.2](#302)

#### 2.x Releases

- `2.0.x` Releases - [2.0.0](#200)

#### 1.x Releases

- `1.2.x` Releases - [1.2.0](#120)
- `1.1.x` Releases - [1.1.0](#110)
- `1.0.x` Releases - [1.0.0](#100)

---

## [4.0.0](https://github.com/Nike-Inc/Willow/releases/tag/4.0.0)

#### Added

- Support for structured messages and simplified `Logger` setup.
  - Added by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).

#### Updated

- The Xcode project and source code to Swift 4.0.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).
- The log level enabled check to run prior to acquiring the lock or async dispatch queue resulting in a small performance gain.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).
- The example frameworks to not have a default logger instance.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).
- The example app configuration logic to match the new APIs.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).
- The `LogMessageWriter` protocol by splitting it into two new protocols: `LogWriter` and `LogModifierWriter`. The former is a basic writer. The latter is a writer that also accepts an array of modifiers to apply to incoming messages.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).
- Example frameworks to show intended usage of the new `LogMessage` APIs.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).

#### Removed

- `LoggerConfiguration` entirely. `Logger` construction now takes a log level, writers array, and execution method which greatly simplifies setup and usage.
  - Removed by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#28](https://github.com/Nike-Inc/Willow/pull/28).

## [3.0.2](https://github.com/Nike-Inc/Willow/releases/tag/3.0.2)

Released on 2017-08-30. All issues associated with this milestone can be found using this
[filter](https://github.com/Nike-Inc/Willow/milestone/7?closed=1).

#### Updated

- Xcode project to be compatible with Xcode 9 and Swift 3.2.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#30](https://github.com/Nike-Inc/Willow/pull/30).
- The `.swift-version` file to `3.2` to support CocoaPods deployment.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#30](https://github.com/Nike-Inc/Willow/pull/30).

## [3.0.1](https://github.com/Nike-Inc/Willow/releases/tag/3.0.1)

Released on 2017-08-17. All issues associated with this milestone can be found using this
[filter](https://github.com/Nike-Inc/Willow/milestone/6?closed=1).

#### Updated

- Network example framework to WebServices to avoid a name collision with an iOS 11 private framework with the same name.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#27](https://github.com/Nike-Inc/Willow/pull/27).
- SWIFT_VERSION to 3.2 in all targets. All targets still build with Swift 3.1/Xcode 8.3.x.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#27](https://github.com/Nike-Inc/Willow/pull/27).
- Copyright dates to 2017.
  - Updated by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#27](https://github.com/Nike-Inc/Willow/pull/27).
- ExecutionMethod enum casing in example.
  - Updated by [Eric Jensen](https://github.com/ejensen) in Pull Request
  [#22](https://github.com/Nike-Inc/Willow/pull/22).

#### Fixed

- Compiler error for Swift 3.2/4.0.
  - Fixed by [Dave Camp](https://github.com/atomiccat) in Pull Request
  [#27](https://github.com/Nike-Inc/Willow/pull/27).
- Remove redundant cast from Date to Date
  - Fixed by [Eric Jensen](https://github.com/ejensen) in Pull Request
  [#23](https://github.com/Nike-Inc/Willow/pull/23).

## [3.0.0](https://github.com/Nike-Inc/Willow/releases/tag/3.0.0)

Released on 2017-01-13. All issues associated with this milestone can be found using this
[filter](https://github.com/Nike-Inc/Willow/milestone/4?closed=1).

#### Added

- A new `.swift-version` file for CocoaPods pointed at Swift 3.0.
  - Added by [Christian Noon](https://github.com/cnoon).
- A migration guide for the Willow 3.0 release.
  - Added by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Willow/pull/21).
- Support for `OSLogWriter` on macOS 10.12+ by removing preprocessor guards.
  - Added by [Silvan Mosberger](https://github.com/Infinisil) in Pull Request
  [#19](https://github.com/Nike-Inc/Willow/pull/19).

#### Updated

- The Travis-CI YAML file to Xcode 8.2 and the latest SDKs and destinations.
  - Added by [Silvan Mosberger](https://github.com/Infinisil) in Pull Request
  [#19](https://github.com/Nike-Inc/Willow/pull/19).
- The Travis-CI YAML file by re-enabling `pod lib lint` since lint issue is resolved.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Willow/pull/21).
- The Xcode projects to Xcode 8.2 and disabled automatic signing on frameworks.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Willow/pull/21).
- Instances of `OSX` with `macOS` including the framework and target names.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Willow/pull/21).
- `ExecutionMethod` enum cases to be lowercased to match Swift API Design Guidelines.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Willow/pull/21).

#### Fixed

- Crash in WriterTests on iOS and tvOS 9 where `os_log` APIs are not available.
  - Fixed by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Willow/pull/21).
- Compiler warnings in the example app around private and fileprivate ACLs.
  - Fixed by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#21](https://github.com/Nike-Inc/Willow/pull/21).

---

## [2.0.0](https://github.com/Nike-Inc/Willow/releases/tag/2.0.0)

Released on 2016-09-07. All issues associated with this milestone can be found using this
[filter](https://github.com/Nike-Inc/Willow/milestone/3?closed=1).

#### Added

- `OSLogWriter` to use the `os_log` APIs indirectly through a `Logger` instance.
  - Added by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#14](https://github.com/Nike-Inc/Willow/pull/14).
- The `Method` enumeration on `ConsoleWriter` to switch between `print` and `NSLog` functions.
  - Added by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#15](https://github.com/Nike-Inc/Willow/pull/15).
- A Willow 2.0 Migration Guide detailing all breaking changes between 1.x and 2.0.
  - Added by [Christian Noon](https://github.com/cnoon).

#### Updated

- All source, test and example logic and project settings to compile against Swift 3.0.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Requests
  [#8](https://github.com/Nike-Inc/Willow/pull/8),
  [#9](https://github.com/Nike-Inc/Willow/pull/9) and
  [#13](https://github.com/Nike-Inc/Willow/pull/13).
- The `Formatter` protocol to be `LogMessageModifier` to avoid naming collisions with Foundation.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#9](https://github.com/Nike-Inc/Willow/pull/9).
- The `Writer` protocol to be `LogMessageWriter` to match `LogMessageModifier` naming convention.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#9](https://github.com/Nike-Inc/Willow/pull/9).
- The README and all sample code to match the new APIs and conventions.
  - Updated by [Christian Noon](https://github.com/cnoon).

#### Removed

- Code generation from all framework targets by default due to instability issues.
  - Removed by [Christian Noon](https://github.com/cnoon).

---

## [1.2.0](https://github.com/Nike-Inc/Willow/releases/tag/1.2.0)

Released on 2016-09-07. All issues associated with this milestone can be found using this
[filter](https://github.com/Nike-Inc/Willow/milestone/2?closed=1).

#### Updated

- All source, test and example logic to compile against Swift 2.3 and Xcode 8.
  - Updated by [Christian Noon](https://github.com/cnoon).
- The Travis CI yaml file to build against iOS 10 and the new suite of simulators.
  - Updated by [Christian Noon](https://github.com/cnoon).
- The iOS Example app to use emoticons in the `PrefixFormatter`.
  - Updated by [Christian Noon](https://github.com/cnoon).

#### Removed

- Slather reporting from the test suite due to instability issues with Xcode and Travis CI.
  - Removed by [Christian Noon](https://github.com/cnoon).
- CocoaPods linting from the Travis CI yaml file due to current instabilities with Xcode 8.
  - Removed by [Christian Noon](https://github.com/cnoon).
- The `ColorFormatter` and all logic associated with it since plugins are no longer supported.
  - Removed by [Christian Noon](https://github.com/cnoon).
- Removed the color formatting section and examples from the README.
  - Removed by [Christian Noon](https://github.com/cnoon).

---

## [1.1.0](https://github.com/Nike-Inc/Willow/releases/tag/1.1.0)

Released on 2016-07-11. All issues associated with this milestone can be found using this
[filter](https://github.com/Nike-Inc/Willow/milestone/1?closed=1).

#### Added

- New `autoclosure(escaping)` variants of the logging methods.
  - Added by [Dave Camp](https://github.com/AtomicCat) in Pull Request
  [#3](https://github.com/Nike-Inc/Willow/pull/3).

#### Updated

- The README to explain the differences between autoclosure and closure APIs.
  - Updated by [Christian Noon](https://github.com/cnoon) in Pull Request
  [#4](https://github.com/Nike-Inc/Willow/pull/4).

---

## [1.0.0](https://github.com/Nike-Inc/Willow/releases/tag/1.0.0)

Released on 2016-06-27.

#### Added

- Initial release of Willow.
  - Added by [Christian Noon](https://github.com/cnoon).
