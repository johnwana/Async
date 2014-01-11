//
//  WaterfallBlockEnumerator.m
//  Async
//
//  Created by John Wana on 12/11/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import "WaterfallBlockEnumerator.h"

@interface WaterfallBlockEnumerator () {
    NSEnumerator *_blockEnumerator;
    id _nextParam;
    id _result;
}

@end

@implementation WaterfallBlockEnumerator

- (id)initBlocks:blocks firstParam:firstParam
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _blockEnumerator = [blocks objectEnumerator];
    _nextParam = firstParam;
    _result = nil;

    return self;
}

- (id)nextObject
{
    mapFunction nextBlock = [_blockEnumerator nextObject];
    if (!nextBlock) {
        _result = _nextParam;
        return nil;
    } else {
        return ^(successBlock success, failureBlock failure) {
            nextBlock(_nextParam,
                      ^(id obj) {
                          _nextParam = obj;
                          success();
                      },
                      failure);
        };
    }
}

@end
