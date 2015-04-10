# Changelog

The changelog for Willow includes information about the each release including any update notes, release notes as well as bug fixes, updates to existing features and new features. Additionally, Willow follows [semantic versioning](http://semver.org/) (a.k.a semver) which makes it easy to tell whether the release was a MAJOR, MINOR or PATCH revision.

---

## 0.2.0

### Upgrade Notes

This release is only compatible with Swift 1.2. You will need to update your project to build against Swift 1.2 in conjunction with updating to Willow `0.2.0`. Additionally, the log message methods have been deprecated for performance reasons. The log closure methods should be used instead.

### Release Notes

* **UPDATED** all source code and tests for Swift 1.2.
* **UPDATED** Xcode project OS X deployment target to 10.9.
* **DEPRECATED** `Logger` log message methods for performance reasons.

## 0.1.0

### Release Notes

This is the initial release of Willow. Until Willow is publicly released on Github, it will continue evolve with versions being released as closely to semver as possible. The actual `1.0.0` release will not be locked until the public Github release.
