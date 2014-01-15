//
//  EachBlockEnumerator.h
//  Pods
//
//  Created by John Wana on 1/13/14.
//
//

#import "MapBlockEnumerator.h"

@interface EachBlockEnumerator : MapBlockEnumerator

- (id)initEachBlock:(eachBlock)block
              using:(NSArray *)array;

@end
