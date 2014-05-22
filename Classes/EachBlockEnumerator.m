//
//  EachBlockEnumerator.m
//  Pods
//
//  Created by John Wana on 1/13/14.
//
//

#import "EachBlockEnumerator.h"

@implementation EachBlockEnumerator

- (id)initEachBlock:(eachBlock)block
              using:(NSArray *)array
{
    NSObject *dummyObject = [NSNull null];
    block1 mapBlock = ^(id obj, successBlock1 success, failureBlock failure) {
        block(obj, ^{ success(dummyObject); }, failure);
    };
    self = [super initMapBlock:mapBlock using:array];
    if (!self) {
        return nil;
    }
    return self;
}

@end
