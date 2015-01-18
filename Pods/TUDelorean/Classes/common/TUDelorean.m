//
//  TUDelorean.m
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

#import "TUDelorean.h"

#import <objc/runtime.h>

static void TUSwizzleInstanceMethods(Class cls, SEL originalSel, SEL newSel)
{
	Method originalMethod = class_getInstanceMethod(cls, originalSel);
	Method newMethod = class_getInstanceMethod(cls, newSel);
	method_exchangeImplementations(originalMethod, newMethod);
}

static void TUSwizzleClassMethods(Class cls, SEL originalSel, SEL newSel)
{
	Method originalMethod = class_getClassMethod(cls, originalSel);
	Method newMethod = class_getClassMethod(cls, newSel);
	method_exchangeImplementations(originalMethod, newMethod);
}


typedef NS_ENUM(NSUInteger, TUTimeJumpType)
{
	TUTimeJumpFreeze,
	TUTimeJumpTravel,
};


@interface TUTimeJump : NSObject

@property (nonatomic, assign, readonly) TUTimeJumpType type;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, assign, readonly) NSTimeInterval offset;

- (id)initWithType:(TUTimeJumpType)type date:(NSDate *)date;

- (NSDate *)now;

@end



@interface NSDate (TUDeloreanExtensions)

+ (instancetype)delorean_date;
+ (instancetype)delorean_dateWithTimeIntervalSinceNow:(NSTimeInterval)secs;

- (instancetype)delorean_init __attribute__((objc_method_family(init)));
- (instancetype)delorean_initWithTimeIntervalSinceNow:(NSTimeInterval)secs  __attribute__((objc_method_family(init)));
- (instancetype)delorean_unmockedInitWithTimeIntervalSinceNow:(NSTimeInterval)secs __attribute__((objc_method_family(init)));

- (NSTimeInterval)delorean_timeIntervalSinceNow;
- (NSTimeInterval)delorean_unmockedTimeIntervalSinceNow;

@end


@interface TUDelorean ()

@property (nonatomic, strong, readonly) TUTimeJump *topTimeJump;

@end


@implementation TUDelorean
{
	@private
	NSMutableArray *_stack;
}

+ (instancetype)sharedDelorean
{
	static TUDelorean *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[TUDelorean alloc] init];
	});

	return instance;
}

+ (void)timeTravelTo:(NSDate *)date
{
	[[self sharedDelorean] timeTravelTo:date block:nil];
}

+ (void)timeTravelTo:(NSDate *)date block:(TUDeloreanBlock)block
{
	[[self sharedDelorean] timeTravelTo:date block:block];
}

+ (void)jump:(NSTimeInterval)timeInterval
{
	[[self sharedDelorean] jump:timeInterval block:nil];
}

+ (void)jump:(NSTimeInterval)timeInterval block:(TUDeloreanBlock)block
{
	[[self sharedDelorean] jump:timeInterval block:block];
}

+ (void)freeze:(NSDate *)date
{
	[[self sharedDelorean] freeze:date block:nil];
}

+ (void)freeze:(NSDate *)date block:(TUDeloreanBlock)block
{
	[[self sharedDelorean] freeze:date block:block];
}

+ (void)backToThePresent
{
	[[self sharedDelorean] backToThePresent];
}

- (id)init
{
	if ((self = [super init]))
	{
		_stack = [[NSMutableArray alloc] init];
		[self mock];
	}

	return self;
}

- (void)timeTravelTo:(NSDate *)date block:(TUDeloreanBlock)block
{
	TUTimeJump *timeJump = [[TUTimeJump alloc] initWithType:TUTimeJumpTravel date:date];
	[self _timeJump:timeJump block:block];
}

- (void)jump:(NSTimeInterval)timeInterval block:(TUDeloreanBlock)block
{
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
	[self timeTravelTo:date block:block];
}

- (void)freeze:(NSDate *)date block:(TUDeloreanBlock)block
{
	TUTimeJump *timeJump = [[TUTimeJump alloc] initWithType:TUTimeJumpFreeze date:date];
	[self _timeJump:timeJump block:block];
}

- (void)_timeJump:(TUTimeJump *)timeJump block:(TUDeloreanBlock)block
{
	[_stack addObject:timeJump];

	if (block != nil) {
		@try
		{
			block(timeJump.now);
		}
		@finally
		{
			// We need to remove everything above the original time jump in the
			// stack, in case the user has used one of the block-less operations
			// in-between.
			NSUInteger idx = [_stack indexOfObject:timeJump];
			if (idx != NSNotFound)
			{
				NSUInteger len = [_stack count] - idx;
				[_stack removeObjectsInRange:NSMakeRange(idx, len)];
			}
		}
	}
}

- (void)backToThePresent
{
	[_stack removeAllObjects];
}

- (TUTimeJump *)topTimeJump
{
	return [_stack lastObject];
}

- (void)mock
{
	Class dateClass = [NSDate class];

	// Let’s store the original timeIntervalSinceNow in a safe place
	IMP originalIMP = class_getMethodImplementation(dateClass, @selector(timeIntervalSinceNow));
	Method originalMethod = class_getInstanceMethod(dateClass, @selector(timeIntervalSinceNow));
	const char *typeEncoding = method_getTypeEncoding(originalMethod);
	BOOL result = class_addMethod(dateClass, @selector(delorean_unmockedTimeIntervalSinceNow), originalIMP, typeEncoding);
	NSAssert(result, @"Couldn't store the original timeIntervalSinceNow in a safe place");

	// Let’s store the original initWithTimeIntervalSinceNow: in a safe place
	originalIMP = class_getMethodImplementation(dateClass, @selector(initWithTimeIntervalSinceNow:));
	originalMethod = class_getInstanceMethod(dateClass, @selector(initWithTimeIntervalSinceNow:));
	typeEncoding = method_getTypeEncoding(originalMethod);
	result = class_addMethod(dateClass, @selector(delorean_unmockedInitWithTimeIntervalSinceNow:), originalIMP, typeEncoding);
	NSAssert(result, @"Couldn't store the original initWithTimeIntervalSinceNow: in a safe place");

	// NOTE: weird. -init is in the headers, but the init that gets returned
	// seems to the be the NSObject one, which fails in a very funny way.
	// The __NSPlaceholderDate seems to have init defined, and can be
	// substituted with our implementation.
	TUSwizzleInstanceMethods(NSClassFromString(@"__NSPlaceholderDate"),
							 @selector(init),
							 @selector(delorean_init));
	TUSwizzleInstanceMethods(dateClass,
							 @selector(initWithTimeIntervalSinceNow:),
							 @selector(delorean_initWithTimeIntervalSinceNow:));
	TUSwizzleInstanceMethods(dateClass,
							 @selector(timeIntervalSinceNow),
							 @selector(delorean_timeIntervalSinceNow));
	// NOTE: Amazingly date doesn’t seem to call any of the methods above. I was
	// expecting it to call -init, but that doesn’t seem to be the case.
	TUSwizzleClassMethods(dateClass,
						  @selector(date),
						  @selector(delorean_date));
	TUSwizzleClassMethods(dateClass,
						  @selector(dateWithTimeIntervalSinceNow:),
						  @selector(delorean_dateWithTimeIntervalSinceNow:));
}

@end


@implementation TUTimeJump

- (id)initWithType:(TUTimeJumpType)type date:(NSDate *)date
{
	if ((self = [super init]))
	{
		_type = type;

		if (_type == TUTimeJumpFreeze)
		{
			_date = date;
		}
		else
		{
			_offset = [date delorean_unmockedTimeIntervalSinceNow];
		}
	}

	return self;
}

- (NSDate *)now
{
	if (_type == TUTimeJumpFreeze)
	{
		return _date;
	}
	else
	{
		return [[NSDate alloc] delorean_unmockedInitWithTimeIntervalSinceNow:_offset];
	}
}

@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSDate (TUDeloreanExtensions)

+ (instancetype)delorean_date
{
	return [[self alloc] init];
}

+ (instancetype)delorean_dateWithTimeIntervalSinceNow:(NSTimeInterval)secs
{
	return [[self alloc] initWithTimeIntervalSinceNow:secs];
}

- (instancetype)delorean_init
{
	TUTimeJump *timeJump = [[TUDelorean sharedDelorean] topTimeJump];
	if (timeJump != nil)
	{
		return [timeJump now];
	}
	else
	{
		return [self delorean_init];
	}
}

- (instancetype)delorean_initWithTimeIntervalSinceNow:(NSTimeInterval)secs
{
	TUTimeJump *timeJump = [[TUDelorean sharedDelorean] topTimeJump];
	if (timeJump != nil)
	{
		return [[timeJump now] dateByAddingTimeInterval:secs];
	}
	else
	{
		return [self delorean_initWithTimeIntervalSinceNow:secs];
	}
}

- (NSTimeInterval)delorean_timeIntervalSinceNow
{
	TUTimeJump *timeJump = [[TUDelorean sharedDelorean] topTimeJump];
	if (timeJump != nil)
	{
		return [self timeIntervalSinceDate:[timeJump now]];
	}
	else
	{
		return [self delorean_timeIntervalSinceNow];
	}
}

@end
#pragma clang diagnostic pop
