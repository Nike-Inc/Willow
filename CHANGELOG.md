# Changelog

All notable changes to this project will be documented in this file.
`Willow` adheres to [Semantic Versioning](http://semver.org/).

#### 1.x Releases

- `1.2.x` Releases - [1.2.0](#120)
- `1.1.x` Releases - [1.1.0](#110)
- `1.0.x` Releases - [1.0.0](#100)

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
