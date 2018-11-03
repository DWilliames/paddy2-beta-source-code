//
//  PaddyObserver.h
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

@interface PaddyObserver : NSObject

typedef void (^ObserverBlock) (id oldValue, id newValue);

+ (instancetype)shared;
+ (void)observeKeyPath:(NSString*)keyPath ofObject:(NSObject*)object withCallback:(ObserverBlock)callback;
+ (void)removeObserversOfObject:(NSObject*)object;

@end
