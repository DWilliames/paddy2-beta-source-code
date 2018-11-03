//
//  PaddyObserver.m
//  PaddyFramework
//
//  Created by David Williames on 1/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyObserver.h"

@interface PaddyObserver ()

@property (nonatomic, strong) NSMutableArray *observees; // Array of all the objects we are observing
@property (nonatomic, strong) NSMutableDictionary *keyPaths;
@property (nonatomic, strong) NSMutableDictionary *callbacks;

@end

@implementation PaddyObserver

static void *observerContext = &observerContext;

+ (instancetype)shared {
    static PaddyObserver *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PaddyObserver alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    
    self.observees = [NSMutableArray array];
    self.keyPaths = [NSMutableDictionary dictionary];
    self.callbacks = [NSMutableDictionary dictionary];
    
    return self;
}

+ (NSString*)keyForObject:(NSObject *)object {
    return [NSString stringWithFormat:@"%lu", (unsigned long)object.hash];
}

+ (NSString*)callbackKeyForObject:(NSObject *)object withKeyPath:(NSString *)keyPath {
    return [NSString stringWithFormat:@"%@/%@", [self keyForObject:object], keyPath];
}

+ (void)observeKeyPath:(NSString *)keyPath ofObject:(NSObject *)object withCallback:(ObserverBlock)callback {
    
    // Also save the key paths and callbacks for later
    NSString *key = [self keyForObject:object];
    if (!key) {
        return;
    }
    
    NSMutableArray *keyPathArray = [PaddyObserver.shared.keyPaths objectForKey:key];
    NSMutableArray *callbacksArray = [PaddyObserver.shared.callbacks objectForKey:key];
    
    if (!keyPathArray) {
        keyPathArray = [NSMutableArray array];
    }
    
    if (!callbacksArray) {
        callbacksArray = [NSMutableArray array];
    }
    
    // Check if we are already observing it
    if (![keyPathArray containsObject:keyPath]) {
        // If we are not already observing it, then let's begin
        // Add the observer; and remember who we are observing
        
        [PaddyManager log:@"ADDED OBSERVER – KeyPath: %@ on object: %@ – key: %@", keyPath, object, key];
        [object addObserver:self.shared forKeyPath:keyPath options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:observerContext];
        
        if (![PaddyObserver.shared.observees containsObject:object]) {
            [PaddyObserver.shared.observees addObject:object];
        }
        
        [keyPathArray addObject:keyPath];
        [PaddyObserver.shared.keyPaths setObject:keyPathArray forKey:key];
    }
    
    // Add the callback if it doesn't already exist
    if (![callbacksArray containsObject:callback]) {
        [callbacksArray addObject:callback];
        [PaddyObserver.shared.callbacks setObject:callbacksArray forKey:[self callbackKeyForObject:object withKeyPath:keyPath]];
    }
}

+ (void)removeObserversOfObject:(NSObject*)object {
    
    NSString *key = [PaddyObserver keyForObject:object];
    if (!key) {
        return;
    }
    
    NSMutableArray *keyPathArray = [PaddyObserver.shared.keyPaths objectForKey:key];
    
    for (NSString *keyPath in keyPathArray) {
        [PaddyManager log:@"REMOVE OBSERVER – KeyPath: %@ on object: %@ – key: %@", keyPath, object, key];
        [object removeObserver:PaddyObserver.shared forKeyPath:keyPath context:observerContext];
    }
}

- (void)dealloc {
    
    for (NSObject *object in PaddyObserver.shared.observees) {
        
        NSString *key = [PaddyObserver keyForObject:object];
        if (!key) {
            continue;
        }
        
        NSMutableArray *keyPathArray = [PaddyObserver.shared.keyPaths objectForKey:key];
        
        for (NSString *keyPath in keyPathArray) {
            [object removeObserver:self forKeyPath:keyPath context:observerContext];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == observerContext) {
        
        // Get all the callbacks associated to this object and keypath
        NSString *callbackKey = [PaddyObserver callbackKeyForObject:object withKeyPath:keyPath];
        if (callbackKey) {
            NSMutableArray *callbacks = [PaddyObserver.shared.callbacks objectForKey:callbackKey];
            
            id newValue = [change objectForKey:NSKeyValueChangeNewKey];
            id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
            
            // Send the new value back to all the callbacks
            for (ObserverBlock callback in callbacks) {
                callback(oldValue, newValue);
            }
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
