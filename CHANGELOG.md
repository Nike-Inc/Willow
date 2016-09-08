# Changelog

All notable changes to this project will be documented in this file.
`Willow` adheres to [Semantic Versioning](http://semver.org/).

#### 2.x Releases

- `2.0.x` Releases - [2.0.0](#200)

#### 1.x Releases

- `1.2.x` Releases - [1.2.0](#120)
- `1.1.x` Releases - [1.1.0](#110)
- `1.0.x` Releases - [1.0.0](#100)

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
