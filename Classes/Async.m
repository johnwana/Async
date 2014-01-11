//
//  Async.m
//  Async
//
//  Created by John Wana on 12/9/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import "MapBlockEnumerator.h"
#import "RepeatBlockUntilEnumerator.h"
#import "WaterfallBlockEnumerator.h"
#import "Async.h"


@implementation Async

+ (void)seriesWithEnumerator:(NSEnumerator *)blocks
       success:(void (^)())success
       failure:(void (^)(NSError *))failure
{
    block0 block = [blocks nextObject];
    if (!block) {
        success();
    } else {
        block(^() {
            [self seriesWithEnumerator:blocks success:success failure:failure];
        }, ^(NSError *error) {
            failure(error);
        });
    }
}

+ (void)series:(NSArray *)blocks
       success:(void (^)())success
       failure:(void (^)(NSError *))failure
{
    [self seriesWithEnumerator:[blocks objectEnumerator] success:success failure:failure];
}

+ (void)parallelWithEnumerator:(NSEnumerator *)blocks
                       success:(void (^)())success
                       failure:(void (^)(NSError *))failure
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block NSUInteger remainingMapCalls = 0;
    __block NSError *blockError = nil;
    
    for (block0 block = [blocks nextObject]; block; block = [blocks nextObject]) {
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

+ (void)parallel:(NSArray *)blocks
         success:(void (^)())success
         failure:(void (^)(NSError *))failure
{
    [self parallelWithEnumerator:[blocks objectEnumerator] success:success failure:failure];
}

+ (void)mapSeries:(NSArray *)array
      mapFunction:(mapFunction)mapFunction
          success:(void (^)(NSArray *))success
          failure:(void (^)(NSError *))failure
{
    MapBlockEnumerator *blockEnumerator = [[MapBlockEnumerator alloc] initMapBlock:mapFunction using:array];
    [Async seriesWithEnumerator:blockEnumerator
                        success:^{
                            success(blockEnumerator.results);
                        }
                        failure:failure];
}

+ (void)mapParallel:(NSArray *)array
        mapFunction:(mapFunction)mapFunction
            success:(void (^)(NSArray *))success
            failure:(void (^)(NSError *))failure
{
    MapBlockEnumerator *blockEnumerator = [[MapBlockEnumerator alloc] initMapBlock:mapFunction using:array];
    [Async parallelWithEnumerator:blockEnumerator
                          success:^{
                              success(blockEnumerator.results);
                          }
                          failure:failure];
}

+ (void)repeatUntilSuccess:(block0)block
               maxAttempts:(NSUInteger)maxAttempts
 delayBetweenAttemptsInSec:(double)delayInSec
                   success:(successBlock)success
                   failure:(failureBlock)failure
{
    RepeatBlockUntilEnumerator *blockEnumerator = [[RepeatBlockUntilEnumerator alloc] initRepeatBlock:block maxAttempts:maxAttempts delayBetweenAttemptsInSec:delayInSec];
    [Async seriesWithEnumerator:blockEnumerator success:success failure:failure];
}

+ (void)waterfall:(NSArray *)blocks
       firstParam:(id)firstParam
          success:(void (^)(id result))success
          failure:(void (^)(NSError *))failure
{
    WaterfallBlockEnumerator *blockEnumerator = [[WaterfallBlockEnumerator alloc] initBlocks:blocks firstParam:firstParam];
    [Async seriesWithEnumerator:blockEnumerator
                        success:^{
                            success(blockEnumerator.result);
                        }
                        failure:failure];
}

@end