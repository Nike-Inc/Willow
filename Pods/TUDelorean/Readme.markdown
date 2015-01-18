# TUDelorean

> Marty:  “Wait a minute. Wait a minute. Doc, uh.…  Are you telling me that you built a time machine.… out of a DeLorean?”
>
> Doc:  “Yes, the way I see it, if you’re gonna build a time machine into a car, why not do it with some style?”

A DeLorean helps you test your time-dependent code allowing you travel anywhere
in time.

This simple class provides several class methods to perform diferent time
mannipulations that will modify the behaviour of `NSDate` instances
and how time advances during the span the manipulation effects are enabled.

The intention of this class is to be used during testing, so reproducible
scenarios can be designed and tested. This class should not be used in
production code.

## How to use

### Installing

#### Using CocoaPods

1. Include the following line in your `Podfile`:
   ```
   pod 'TUDelorean', :git => 'https://github.com/tuenti/TUDelorean'
   ```
2. Run `pod install`

#### Manually

1. Clone, add as a submodule or [download](https://github.com/tuenti/TUDelorean/zipball/master) TUDelorean.
2. Add all the files under `Classes/common` to your project.
3. Look at the Requirements section if you are not using ARC.

### Coding

TUDelorean only provides one header that you must import in order to use the
library. Simply add `#import "TUDelorean.h"` at the top of your testing files
where you want to use TUDelorean.

One thing that you must remember is that in any test case you decide to use
TUDelorean you must call `backToThePresent` in its `tearDown` (or equivalent)
method. Otherwise the effects of changing the current time will “leak” to other
tests and also the testing rig.

``` objective-c
- (void)tearDown
{
    [TUDelorean backToThePresent];
}
```

TUDelorean offers three primitives to change the current time. Each of them has
two variants: in one of them the effects of the time manipulation are permanent,
while in the other one the effects of the time manipulation only affects the
block passed as parameter. You are encouraged to use the block-based versions,
to improve the readability of your tests.

The first primitive is “time travelling”. You provide a destination date, and
the current time will be reported from that point as in the past or in the
future.

``` objective-c
NSDate *destination = [NSDate dateWithNaturalLanguageString:@"November 12, 1955"];
[TUDelorean timeTravelTo:destination block:^(NSDate *date) {
    // Inside the block its November 12, 1955
    [marty playGuitar:@"Johnny B. Goode"];
}];
```

The second primitive is a relative “time jump”. You provide an offset from the
current time, and from that point the current time will be displaced the number
of seconds you wanted.

``` objective-c
[timeMachine addOccupant:einstein];
[TUDelorean jump:60 block:^(NSDate *date) {
    // Inside the block its already 60 seconds into the future
    [einstein woof];
}];
[marty say:@"Jesus Christ, Doc. You disintegrated Einstein!"]
```

The final primitive is another time jump, but instead of allowing the time to
keep flowing as normal, the time is frozen in the same moment. This is
particurlaly useful if you need to do time distance calculations, and you want
to test the edge cases.

``` objective-c
NSDate *destination = [NSDate dateWithNaturalLanguageString:@"18pm September 5, 1885"];
[TUDelorean freeze:destination block:^(NSDate *date) {
    // Inside the block is 18pm September 5, 1885.
    [NSThread sleepForTimeInterval:3600.0];
    // Yes, still 18pm September 5, 1885.
}];
```

You can reset the changes done to the current time using `backToThePresent` at
any moment.

## Requirements

TUDelorean should work in any relatively recent iOS/Mac version, but we have
only tested it iOS 6.0 and OS X 10.8. We have only tested TUDelorean with
OCUnit, but it should work in any other testing framework unchanged.

TUDelorean uses ARC, so if you use it in a non-ARC project, and you are not
using CocoaPods, you will need to use `-fobjc-arc` compiler flag on every
TUDelorean source file.

To set a compiler flag in Xcode, go to your desidered target and select the
“Build Phases” tab. Select all TUDelorean source files, press Enter,
add `-fobjc-arc` and then “Done” to enable ARC for TUDelorean.

## Credits & Contact

TUDelorean was created by [iOS team at Tuenti Technologies S.L.](http://github.com/tuenti).
You can follow Tuenti engineering team on Twitter [@tuentieng](http://twitter.com/tuentieng).

TUDelorean was inspired by the similarly named Rubygem [delorean](https://github.com/bebanjo/delorean).
Thanks for the inspiration, and for finding this awesome name.

## License

TUDelorean is available under the Apache License, Version 2.0. See LICENSE file
for more info.
