//
//  AsyncTests.m
//  AsyncTests
//
//  Created by John Wana on 12/9/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Async.h"

const int64_t TEST_TIMEOUT = 5000000000;    // 5 sec
const int64_t TEST_PAUSE_AFTER_FINISH = 1000000000; // 1 sec


@interface AsyncTests : XCTestCase

@end

@implementation AsyncTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

typedef void (^testSuccessBlock)();
- (void)runAsyncTest:(void(^)(testSuccessBlock testSuccessBlock))testBlock
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    testBlock(^ { dispatch_semaphore_signal(semaphore); });
    if (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT)) != 0) {
        XCTFail(@"Semaphore test timeout!");
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, TEST_PAUSE_AFTER_FINISH),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^ {
                       dispatch_semaphore_signal(semaphore);
                   });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT));
    
    
    NSLog(@"Done");
}

- (void)testSeriesSuccess
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        NSMutableArray *results = [NSMutableArray array];
        block0 first = ^(successBlock success ,failureBlock failure) {
            [results addObject:@"a"];
            success();
        };
        block0 second = ^(successBlock success ,failureBlock failure) {
            [results addObject:@"b"];
            success();
        };
        block0 third = ^(successBlock success ,failureBlock failure) {
            [results addObject:@"c"];
            success();
        };
        
        NSArray *blocks = [NSArray arrayWithObjects:first, second, third, nil];
        
        [Async series:blocks
              success:^{
                  XCTAssertEqual(blocks.count, results.count, @"Not all blocks called");
                  NSArray *expectedResults = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
                  XCTAssertEqualObjects(results, expectedResults, @"Results do not match expected");
                  testSuccessBlock();
              }
              failure:^(NSError *error) {
                  XCTFail(@"Should not fail");
              }
         ];
    }];
}

- (void)testSeriesFailure
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        NSMutableArray *results = [NSMutableArray array];
        block0 first = ^(successBlock success ,failureBlock failure) {
            [results addObject:@"a"];
            success();
        };
        block0 second = ^(successBlock success ,failureBlock failure) {
            [results addObject:@"b"];
            failure([NSError errorWithDomain:@"testSeriesFailure" code:321 userInfo:nil]);
        };
        block0 third = ^(successBlock success ,failureBlock failure) {
            [results addObject:@"c"];
            success();
        };
        
        NSArray *blocks = [NSArray arrayWithObjects:first, second, third, nil];
        [Async series:blocks
              success:^{
                  XCTFail(@"Should not succeed");
              }
              failure:^(NSError *error) {
                  XCTAssertEqual((NSUInteger)2, [results count], @"Not all blocks called");
                  NSArray *expectedResults = [NSArray arrayWithObjects:@"a", @"b", nil];
                  XCTAssertEqualObjects(results, expectedResults, @"Results do not match expected");
                  testSuccessBlock();
              }
         ];
    }];
}

- (void)testParallelSuccess
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        NSMutableArray *hasRun = [NSMutableArray arrayWithCapacity:3];
        block0 firstBlock = ^(successBlock success, failureBlock failure) {
            [hasRun addObject:@"1"];
            success();
        };
        block0 secondBlock = ^(successBlock success, failureBlock failure) {
            [hasRun addObject:@"2"];
            success();
        };
        block0 thirdBlock = ^(successBlock success, failureBlock failure) {
            [hasRun addObject:@"3"];
            success();
        };
        [Async parallel:[NSArray arrayWithObjects:firstBlock, secondBlock, thirdBlock, nil]
                success:^{
                    XCTAssertEqual(hasRun.count, (NSUInteger)3, @"Invalid number of runs");
                    XCTAssertNotEqual([hasRun indexOfObject:@"1"], NSNotFound, @"Cannot find result");
                    XCTAssertNotEqual([hasRun indexOfObject:@"2"], NSNotFound, @"Cannot find result");
                    XCTAssertNotEqual([hasRun indexOfObject:@"3"], NSNotFound, @"Cannot find result");
                    testSuccessBlock();
                }
                failure:^(NSError *error) {
                    XCTFail(@"Should not fail");
                }
         ];
        
    }];
}

- (void)testParallelFailure
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        NSMutableArray *hasRun = [NSMutableArray arrayWithCapacity:3];
        block0 firstBlock = ^(successBlock success, failureBlock failure) {
            [hasRun addObject:@"1"];
            success();
        };
        block0 secondBlock = ^(successBlock success, failureBlock failure) {
            [hasRun addObject:@"2"];
            failure([NSError errorWithDomain:@"testParallelFailure" code:123 userInfo:nil]);
        };
        block0 thirdBlock = ^(successBlock success, failureBlock failure) {
            [hasRun addObject:@"3"];
            failure([NSError errorWithDomain:@"testParallelFailure" code:456 userInfo:nil]);
        };
        __block BOOL failureCalled = NO;
        [Async parallel:[NSArray arrayWithObjects:firstBlock, secondBlock, thirdBlock, nil]
                success:^{
                    XCTFail(@"Should not succeed");
                }
                failure:^(NSError *error) {
                    XCTAssertEqual(failureCalled, NO, @"Failure already called");
                    failureCalled = YES;
                    testSuccessBlock();
                }
         ];
        
    }];
}

// TODO: run sync test also
- (void)testMapSuccess
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        __block BOOL successCalled = NO;
        NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", nil];
        
        [Async mapParallel:array
               mapFunction:^(id obj, mapSuccessBlock success, mapFailBlock failure) {
                   unichar val = [(NSString *)obj characterAtIndex:0];
                   success([NSNumber numberWithShort:val]);
               }
                   success:^(NSArray *mappedArray) {
                       XCTAssertEqual(successCalled, NO, @"Success already called");
                       successCalled = YES;
                       XCTAssertEqual(mappedArray.count, array.count);
                       for (NSUInteger i = 0; i < mappedArray.count; i++) {
                           NSString *restoredString = [NSString stringWithFormat:@"%c", [mappedArray[i] shortValue]];
                           XCTAssertEqualObjects(restoredString, array[i], @"%@ != %@", restoredString, array[i]);
                       }
                       testSuccessBlock();
                   }
                   failure:^(NSError *error) {
                       XCTFail(@"Should not fail");
                   }
         ];
    }];
}

// TODO: run sync test also
- (void)testEmptyMapSuccess
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        [Async mapParallel:@[]
               mapFunction:^(id obj, mapSuccessBlock success, mapFailBlock failure) {
                   success(obj);
               }
                   success:^(NSArray *mappedArray) {
                       XCTAssertEqual(mappedArray.count, 0);
                       testSuccessBlock();
                   }
                   failure:^(NSError *error) {
                       XCTFail(@"Should not fail");
                   }
         ];
    }];
}

// TODO: run sync test also
- (void)testMapFailure
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        __block BOOL failureCalled = NO;
        NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", nil];
        [Async mapParallel:array
               mapFunction:^(id obj, mapSuccessBlock success, mapFailBlock failure) {
                   failure([NSError errorWithDomain:@"testMapFailure" code:123 userInfo:nil]);
               }
                   success:^(NSArray *mappedArray) {
                       XCTFail(@"Should not succeed");
                   }
                   failure:^(NSError *error) {
                       XCTAssertEqual(failureCalled, NO, @"Failure already called");
                       failureCalled = YES;
                       XCTAssertEqualObjects(error.domain, @"testMapFailure", @"Unknown error domain");
                       XCTAssertEqual(error.code, 123, @"Unknown error code");
                       testSuccessBlock();
                   }
         ];
    }];
}

// TODO: run sync test also
- (void)testEachSuccess
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        __block int val = 0;
        eachBlock block = ^(id obj, successBlock success, failureBlock failure) {
            NSString *s = obj;
            val += [s intValue];
            success();
        };
        [Async eachParallel:[NSArray arrayWithObjects:@"1", @"2", @"3", nil]
                      block:(eachBlock)block
                    success:^ {
                        XCTAssertEqual(val, 6, @"Final value wrong");
                        testSuccessBlock();
                    }
                    failure:^(NSError *error) {
                        XCTFail(@"Should not fail");
                    }];
        
    }];
}

// TODO: run sync test also
- (void)testEachFailure
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        __block BOOL failureCalled = NO;
        eachBlock block = ^(id obj, successBlock success, failureBlock failure) {
            failure([NSError errorWithDomain:@"testEachFailure" code:123 userInfo:nil]);
        };
        [Async eachParallel:[NSArray arrayWithObjects:@"1", @"2", @"3", nil]
                      block:(eachBlock)block
                    success:^ {
                        XCTFail(@"Should not succeed");
                    }
                    failure:^(NSError *error) {
                        XCTAssertEqual(failureCalled, NO, @"Failure already called");
                        failureCalled = YES;
                        XCTAssertEqualObjects(error.domain, @"testEachFailure", @"Unknown error domain");
                        XCTAssertEqual(error.code, 123, @"Unknown error code");
                        testSuccessBlock();
                    }];
    }];
}

- (void)testRepeatUntilSuccess
{
    const NSUInteger MAX_ATTEMPTS = 3;
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        __block NSMutableArray *results = [NSMutableArray arrayWithCapacity:MAX_ATTEMPTS];
        [Async repeatUntilSuccess:^(successBlock success, failureBlock failure) {
            [results addObject:[NSNumber numberWithUnsignedInteger:results.count]];
            if (results.count < MAX_ATTEMPTS) {
                failure([NSError errorWithDomain:@"testRepeatUntilSuccess" code:0 userInfo:nil]);
            } else {
                success();
            }
        }
                      maxAttempts:MAX_ATTEMPTS
        delayBetweenAttemptsInSec:0.1
                          success:^{
                              XCTAssertEqual(results.count, MAX_ATTEMPTS, @"Wrong number of calls");
                              XCTAssertEqual([results indexOfObject:[NSNumber numberWithUnsignedInteger:0]], (NSUInteger)0, @"Missing result");
                              XCTAssertEqual([results indexOfObject:[NSNumber numberWithUnsignedInteger:1]], (NSUInteger)1, @"Missing result");
                              XCTAssertEqual([results indexOfObject:[NSNumber numberWithUnsignedInteger:2]], (NSUInteger)2, @"Missing result");
                              testSuccessBlock();
                          }
                          failure:^(NSError *error) {
                              XCTFail(@"Should not fail");
                          }
         ];
    }];
}

- (void)testRepeatUntilFailure
{
    const NSUInteger MAX_ATTEMPTS = 3;
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        __block NSMutableArray *results = [NSMutableArray arrayWithCapacity:MAX_ATTEMPTS];
        [Async repeatUntilSuccess:^(successBlock success, failureBlock failure) {
            [results addObject:[NSNumber numberWithUnsignedInteger:results.count]];
            failure([NSError errorWithDomain:@"testRepeatUntilFailure" code:456 userInfo:nil]);
        }
                      maxAttempts:MAX_ATTEMPTS
        delayBetweenAttemptsInSec:0.1
                          success:^{
                              XCTFail(@"Should not succeed");
                          }
                          failure:^(NSError *error) {
                              XCTAssertEqual(results.count, MAX_ATTEMPTS, @"Wrong number of calls");
                              XCTAssertEqual([results indexOfObject:[NSNumber numberWithUnsignedInteger:0]], (NSUInteger)0, @"Missing result");
                              XCTAssertEqual([results indexOfObject:[NSNumber numberWithUnsignedInteger:1]], (NSUInteger)1, @"Missing result");
                              XCTAssertEqual([results indexOfObject:[NSNumber numberWithUnsignedInteger:2]], (NSUInteger)2, @"Missing result");
                              XCTAssertEqualObjects(error.domain, @"testRepeatUntilFailure", @"Unknown error domain");
                              XCTAssertEqual(error.code, 456, @"Unknown error code");
                              testSuccessBlock();
                          }
         ];
    }];
}

- (void)testWaterfallSuccess
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:3];
        block1 firstBlock = ^(id obj, successBlock1 success, failureBlock failure) {
            [results addObject:obj];
            success([NSNumber numberWithInt:[obj intValue] + 1]);
        };
        block1 secondBlock = ^(id obj, successBlock1 success, failureBlock failure) {
            [results addObject:obj];
            success([NSNumber numberWithInt:[obj intValue] + 2]);
        };
        block1 thirdBlock = ^(id obj, successBlock1 success, failureBlock failure) {
            [results addObject:obj];
            success([NSNumber numberWithInt:[obj intValue] + 3]);
        };
        
        [Async waterfall:[NSArray arrayWithObjects:firstBlock, secondBlock, thirdBlock, nil]
              firstParam:[NSNumber numberWithInt:5]
                 success:^(id result) {
                     XCTAssertEqual(results.count, (NSUInteger)3, @"Wrong number of results");
                     XCTAssertEqual([results[0] intValue], 5, @"Wrong result");
                     XCTAssertEqual([results[1] intValue], 6, @"Wrong result");
                     XCTAssertEqual([results[2] intValue], 8, @"Wrong result");
                     XCTAssertEqual([result intValue], 11, @"Wrong result");
                     testSuccessBlock();
                 }
                 failure:^(NSError *error) {
                     XCTFail(@"Should not fail");
                 }];
    }];
}

- (void)testWaterfallFailure
{
    [self runAsyncTest:^(testSuccessBlock testSuccessBlock) {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:3];
        block1 firstBlock = ^(id obj, successBlock1 success, failureBlock failure) {
            [results addObject:obj];
            success([NSNumber numberWithInt:[obj intValue] + 1]);
        };
        block1 secondBlock = ^(id obj, successBlock1 success, failureBlock failure) {
            [results addObject:obj];
            failure([NSError errorWithDomain:@"testWaterfallFailure" code:999 userInfo:nil]);
        };
        block1 thirdBlock = ^(id obj, successBlock1 success, failureBlock failure) {
            [results addObject:obj];
            success([NSNumber numberWithInt:[obj intValue] + 3]);
        };
        
        [Async waterfall:[NSArray arrayWithObjects:firstBlock, secondBlock, thirdBlock, nil]
              firstParam:[NSNumber numberWithInt:5]
                 success:^(id result) {
                     XCTFail(@"Should not succeed");
                 }
                 failure:^(NSError *error) {
                     XCTAssertEqual(results.count, (NSUInteger)2, @"Wrong number of results");
                     XCTAssertEqual([results[0] intValue], 5, @"Wrong result");
                     XCTAssertEqual([results[1] intValue], 6, @"Wrong result");
                     XCTAssertEqualObjects(error.domain, @"testWaterfallFailure", @"Unknown error domain");
                     XCTAssertEqual(error.code, 999, @"Unknown error code");
                     testSuccessBlock();
                 }];
    }];
}


@end
