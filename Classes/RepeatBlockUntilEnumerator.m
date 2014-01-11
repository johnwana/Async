//
//  RepeatBlockUntilEnumerator.m
//  Async
//
//  Created by John Wana on 12/11/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import "RepeatBlockUntilEnumerator.h"

@interface RepeatBlockUntilEnumerator () {
    block0 _block;
    NSUInteger _maxAttempts;
    NSUInteger _numAttempts;
    double _delayInSec;
}
@end

@implementation RepeatBlockUntilEnumerator

- (id)initRepeatBlock:(block0)block maxAttempts:(NSUInteger)maxAttempts delayBetweenAttemptsInSec:(double)delayInSec
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _block = block;
    _maxAttempts = maxAttempts;
    _delayInSec = delayInSec;
    _numAttempts = 0;
    return self;
}

- (id)nextObject
{
    if (_numAttempts >= _maxAttempts) {
        return nil;
    } else {
        return ^(successBlock success, failureBlock failure) {
            _block(
                   ^() {
                       _numAttempts = _maxAttempts;
                       success();
                   },
                   ^(NSError *error) {
                       _numAttempts++;
                       if (_numAttempts >= _maxAttempts) {
                           failure(error);
                       } else {
                           dispatch_time_t pauseTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayInSec * NSEC_PER_SEC));
                           dispatch_after(pauseTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                               success();
                           });
                       }
                   });
        };
    }
}

@end

