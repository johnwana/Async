//
//  RepeatBlockUntilEnumerator.h
//  Async
//
//  Created by John Wana on 12/11/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncTypes.h"

@interface RepeatBlockUntilEnumerator : NSEnumerator

- (id)initRepeatBlock:(block0)block maxAttempts:(NSUInteger)maxAttempts delayBetweenAttemptsInSec:(double)delayInSec;

@end
