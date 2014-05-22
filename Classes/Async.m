//
//  Async.m
//  Async
//
//  Created by John Wana on 12/9/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import "MapBlockEnumerator.h"
#import "EachBlockEnumerator.h"
#import "RepeatBlockUntilEnumerator.h"
#import "WaterfallBlockEnumerator.h"
#import "Async.h"


@implementation Async

+ (void)seriesWithEnumerator:(NSEnumerator *)block0s
       success:(void (^)())success
       failure:(void (^)(NSError *))failure
{
    block0 block = [block0s nextObject];
    if (!block) {
        success();
    } else {
        block(^() {
            [self seriesWithEnumerator:block0s success:success failure:failure];
        }, ^(NSError *error) {
            failure(error);
        });
    }
}

+ (void)series:(NSArray *)block0s
       success:(void (^)())success
       failure:(void (^)(NSError *))failure
{
    [self seriesWithEnumerator:[block0s objectEnumerator] success:success failure:failure];
}

+ (void)parallelWithEnumerator:(NSEnumerator *)block0s
                       success:(void (^)())success
                       failure:(void (^)(NSError *))failure
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block NSUInteger remainingMapCalls = 0;
    __block NSError *blockError = nil;
    
    block0 block = [block0s nextObject];
    if (!block) {
        success();
    } else {
        for (; block; block = [block0s nextObject]) {
            remainingMapCalls++;
            dispatch_async(queue, ^{
                block(
                      ^() {
                          if (--remainingMapCalls == 0) {
                              if (blockError) {
                                  failure(blockError);
                              } else {
                                  success();
                              }
                          }
                      },
                      ^(NSError *error) {
                          if (--remainingMapCalls == 0) {
                              failure(error);
                          } else {
                              blockError = error;
                          }
                      });
            });
        }
    }
}

+ (void)parallel:(NSArray *)block0s
         success:(void (^)())success
         failure:(void (^)(NSError *))failure
{
    [self parallelWithEnumerator:[block0s objectEnumerator] success:success failure:failure];
}

+ (void)mapSeries:(NSArray *)array
      mapFunction:(block1)mapFunction
          success:(void (^)(NSArray *))success
          failure:(void (^)(NSError *))failure
{
    MapBlockEnumerator *blockEnumerator = [[MapBlockEnumerator alloc] initMapBlock:mapFunction using:array];
    [Async seriesWithEnumerator:blockEnumerator
                        success:^{ success(blockEnumerator.results); }
                        failure:failure];
}

+ (void)mapParallel:(NSArray *)array
        mapFunction:(block1)mapFunction
            success:(void (^)(NSArray *))success
            failure:(void (^)(NSError *))failure
{
    MapBlockEnumerator *blockEnumerator = [[MapBlockEnumerator alloc] initMapBlock:mapFunction using:array];
    [self parallelWithEnumerator:blockEnumerator
                         success:^{ success(blockEnumerator.results); }
                         failure:failure];
}

+ (void)eachSeries:(NSArray *)array
             block:(eachBlock)block
           success:(void (^)())success
           failure:(void (^)(NSError *))failure
{
    EachBlockEnumerator *blockEnumerator = [[EachBlockEnumerator alloc] initEachBlock:block
                                                                                using:array];
    [self seriesWithEnumerator:blockEnumerator
                       success:success
                       failure:failure];
}

+ (void)eachParallel:(NSArray *)array
               block:(eachBlock)block
             success:(void (^)())success
             failure:(void (^)(NSError *))failure
{
    EachBlockEnumerator *blockEnumerator = [[EachBlockEnumerator alloc] initEachBlock:block
                                                                                using:array];
    [self parallelWithEnumerator:blockEnumerator
                         success:success
                         failure:failure];
}

+ (void)repeatUntilSuccess:(block0)block
               maxAttempts:(NSUInteger)maxAttempts
 delayBetweenAttemptsInSec:(double)delayInSec
                   success:(successBlock)success
                   failure:(failureBlock)failure
{
    RepeatBlockUntilEnumerator *blockEnumerator = [[RepeatBlockUntilEnumerator alloc] initRepeatBlock:block
                                                                                          maxAttempts:maxAttempts
                                                                            delayBetweenAttemptsInSec:delayInSec];
    [self seriesWithEnumerator:blockEnumerator
                       success:success
                       failure:failure];
}

+ (void)waterfall:(NSArray *)blocks
       firstParam:(id)firstParam
          success:(void (^)(id result))success
          failure:(void (^)(NSError *))failure
{
    WaterfallBlockEnumerator *blockEnumerator = [[WaterfallBlockEnumerator alloc] initBlocks:blocks
                                                                                  firstParam:firstParam];
    [self seriesWithEnumerator:blockEnumerator
                       success:^{
                           success(blockEnumerator.result);
                       }
                       failure:failure];
}

@end
