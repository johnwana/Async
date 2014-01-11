//
//  AsyncTypes.h
//  Async
//
//  Created by John Wana on 12/11/13.
//  Copyright (c) 2013 John Wana. All rights reserved.
//

#ifndef Async_AsyncTypes_h
#define Async_AsyncTypes_h

typedef void (^successBlock)();
typedef void (^successBlock1)(id obj);
typedef void (^failureBlock)(NSError *error);
typedef void (^block0)(successBlock success, failureBlock failure);
typedef void (^block1)(id obj, successBlock1 success, failureBlock failure);

typedef void (^mapSuccessBlock)(id mappedObject);
typedef void (^mapFailBlock)(NSError *error);
typedef void (^mapFunction)(id obj, mapSuccessBlock success, mapFailBlock failure);

#endif
