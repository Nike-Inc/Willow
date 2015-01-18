//
//  TUDelorean.h
//  TUDelorean
//
//  Copyright 2013 Tuenti Technolgies S.L.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

/**
 * Defines the signature for the block accepted for TUDelorean operations.
 *
 * The statements during the span of the block will be affected by time
 * modification done by TUDelorean, but anything outside it will behave the
 * same as before invoking the TUDelorean modification.
 *
 * The `date` parameter will start with the value specified in the operation but
 * depending on the operation the current time will stay fixed during the span
 * of the block, or will advance at the normal rate, differing from the initial
 * `date`.
 *
 * @param date The initial date when the block started executing.
 */
typedef void(^TUDeloreanBlock)(NSDate *date);

/**
 * A DeLorean is a machine that allows you travel in time.
 * 
 * This helper class provides several class methods to perform
 * diferent time operations that will modify the behaviour of NSDate instances
 * and how time advances during the span the operations effects are enabled.
 *
 * The intention of this class is to be used during testing, so reproducible
 * scenarios can be designed and tested.
 *
 * The operations are three:
 *
 * - *time travelling*: the current time will jump back or forward to the given
 *   date. Time will advance as normal.
 * - *jump*: the current time will be offset by the given number of seconds.
 *   Time will advance as normal.
 * - *freeze*: the current time will be frozen to the given date. The time will
 *   not advance at all.
 *
 * @warning This class is not thread safe and its effects could be seen by other
 * threads concurrent to the execution of the methods of this class (including
 * the methods with blocks as parameters).
 *
 * @warning As soon as any of the methods of this class is invoked, several
 * methods of NSDate will be modified to provide the right results when the
 * operations are performed. backToThePresent also modifies the methods. The
 * methods will stay modified until the end of the execution, even if their
 * effects will be disabled as soon as backToThePresent is called.
 *
 * This class is not intented to be shipped in a production build of your
 * application or library.
 *
 * The modified methods of NSDate are the following:
 *
 * - `-init`
 * - `-initWithTimeIntervalSinceNow:`
 * - `-timeIntervalSinceNow`
 * - `+date`
 * - `+dateWithTimeIntervalSinceNow:`
 */
@interface TUDelorean : NSObject

/** @name Time travelling */

/**
 * Travels to the given date.
 * 
 * The time will change to the given date and will advance at the normal rate.
 *
 * The effects of this time travel will affect the current time until another
 * time operation is performed.
 *
 * @param date The destination date of the journey.
 */
+ (void)timeTravelTo:(NSDate *)date;

/**
 * Travels to the given date and invokes the given block.
 *
 * The time will change to the given date, and then the block will be invoked.
 * During the block span the time will advance as normal, and when the block
 * finish, the time will be restored to the time it was before invoking this
 * operation.
 *
 * Invocations to this method can be nested one inside the other. The inner
 * block will not be aware of the outer block current time.
 *
 * The effects of this time travel will only affect the block invocation, or
 * until another time operation is performed.
 *
 * @param date The destination date of the journey.
 * @param block The block to invoke where the current time will be modified.
 */
+ (void)timeTravelTo:(NSDate *)date block:(TUDeloreanBlock)block;

/** @name Jumps */

/**
 * Jumps in time the given timeInterval.
 *
 * The time will change by the given amount of seconds and will advance at the
 * normal rate.
 *
 * The effects of this jump will affect the current time until another time
 * operation is performed.
 *
 * @param timeInterval The number of seconds to jump forward (if positive), or
 * backward (if negative) from the current time.
 */
+ (void)jump:(NSTimeInterval)timeInterval;

/**
 * Jumps in time the given timeInterval and invokes the given block.
 *
 * The time will change by the given amount of seconds, and then the block will
 * be invoked. During the block span the time will advance as normal, and when
 * the block finish, the time will be restored to the time it was before
 * invoking this operation.
 *
 * Invocations to this method can be nested one inside the other. The inner
 * block will not be aware of the outer block current time.
 *
 * The effects of this time travel will only affect the block invocation, or
 * until another time operation is performed.
 *
 * @param timeInterval The number of seconds to jump forward (if positive), or
 * backward (if negative) from the current time.
 * @param block The block to invoke where the current time will be modified.
 */
+ (void)jump:(NSTimeInterval)timeInterval block:(TUDeloreanBlock)block;

/** @name Freeze time */

/**
 * Freezes the time at the given date.
 *
 * The time will change to the given date and will not advance at all.
 *
 * The effects of this time freeze will affect the current time until another
 * time operation is performed.
 *
 * @param date The date when the time will be frozen.
 */
+ (void)freeze:(NSDate *)date;

/**
 * Freezes the time at the given date and invokes the given block.
 *
 * The time will change to the given date, and then the block will be invoked.
 * During the block span the time will not advance at all, and when the block
 * finish, the time will be restored to the time and the pace it had before
 * invoking this operation.
 *
 * Invocations to this method can be nested one inside the other. The inner
 * block will not be aware of the outer block frozen time.
 *
 * The effects of this time freeze will affect the block invocation, or until
 * another time operation is performed.
 *
 * @param date The date when the time will be frozen.
 * @param block The block to invoke where the current time will be modified.
 */
+ (void)freeze:(NSDate *)date block:(TUDeloreanBlock)block;

/** @name Reset effects */

/**
 * Undoes any active time jumps and restores the real current time.
 *
 * It is strongly advised that you invoke this method during your test tear down
 * method, otherwise the current time will be modified outside the test scope,
 * and every class of the framework will see your time modification.
 */
+ (void)backToThePresent;

@end
