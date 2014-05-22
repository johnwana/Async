//
//  MapBlockEnumerator.h
//  Async
//
//  Created by John Wana on 12/11/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncTypes.h"

@interface MapBlockEnumerator : NSEnumerator

@property (nonatomic, readonly) NSArray *results;

- (id)initMapBlock:(block1)block1 using:(NSArray *)array;

@end
