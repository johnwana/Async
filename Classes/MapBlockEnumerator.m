//
//  MapBlockEnumerator.m
//  Async
//
//  Created by John Wana on 12/11/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import "AsyncTypes.h"
#import "MapBlockEnumerator.h"


@interface MapBlockEnumerator () {
    block1 _block;
    NSArray *_array;
    NSUInteger _index;
    NSMutableArray *_results;
}

@end

@implementation MapBlockEnumerator

- (id)initMapBlock:(block1)block using:(NSArray *)array
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _block = block;
    _array = array;
    _index = 0;
    _results = [NSMutableArray arrayWithCapacity:array.count];
    
    id fillerObj = [[NSObject alloc] init];
    for (NSUInteger i = 0; i < array.count; i++) {
        [_results addObject:fillerObj];
    }
    
    return self;
}

- (id)nextObject
{
    NSUInteger index = _index++;
    if (index >= _array.count) {
        return nil;
    } else {
        id obj = [_array objectAtIndex:index];
        return ^(successBlock success, failureBlock failure) {
            _block(obj, ^(id resultObj) {
                [_results setObject:resultObj atIndexedSubscript:index];
                success();
            }, failure);
        };
    }
}

@end
