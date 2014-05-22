//
//  Async.h
//  Async
//
//  Created by John Wana on 12/9/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import "AsyncTypes.h"
#import <Foundation/Foundation.h>

@interface Async : NSObject

+ (void)series:(NSArray *)block0s
       success:(void (^)())success
       failure:(void (^)(NSError *error))failure;

+ (void)parallel:(NSArray *)block0s
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure;

+ (void)mapParallel:(NSArray *)array
        mapFunction:(mapFunction)mapFunction
            success:(void (^)(NSArray *mappedArray))success
            failure:(void (^)(NSError *error))failure;

+ (void)mapSeries:(NSArray *)array
      mapFunction:(mapFunction)mapFunction
          success:(void (^)(NSArray *mappedObjects))success
          failure:(void (^)(NSError *error))failure;

+ (void)eachParallel:(NSArray *)array
               block:(eachBlock)block
             success:(void (^)())success
             failure:(void (^)(NSError *))failure;

+ (void)eachSeries:(NSArray *)array
             block:(eachBlock)block
           success:(void (^)())success
           failure:(void (^)(NSError *))failure;

+ (void)repeatUntilSuccess:(block0)block
               maxAttempts:(NSUInteger)maxAttempts
 delayBetweenAttemptsInSec:(double)delayInSec
                   success:(successBlock)success
                   failure:(failureBlock)failure;

+ (void)waterfall:(NSArray *)blocks
       firstParam:(id)firstParam
          success:(void (^)(id result))success
          failure:(void (^)(NSError *error))failure;


@end
