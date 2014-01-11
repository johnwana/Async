//
//  WaterfallBlockEnumerator.h
//  Async
//
//  Created by John Wana on 12/11/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncTypes.h"

@interface WaterfallBlockEnumerator : NSEnumerator

@property (nonatomic, readonly) id result;

- (id)initBlocks:(NSArray *)blocks firstParam:(id)firstParam;

@end
