//
//  PaddyUtils.m
//  PaddyFramework
//
//  Created by David Williames on 28/4/18.
//  Copyright © 2018 David Williames. All rights reserved.
//

#import "PaddyUtils.h"

@implementation PaddyUtils

+ (NSMutableArray*)map:(NSArray*)array withBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id mappedValue = block(obj, idx);
        if (mappedValue) {
            [result addObject:mappedValue];
        }
    }];
    
    return result;
}

+ (NSMutableArray*)filter:(NSArray*)array withBlock:(BOOL (^)(id obj))block {
    NSMutableArray *result = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL shouldInclude = block(obj);
        if (shouldInclude) {
            [result addObject:obj];
        }
    }];
    
    return result;
}

+ (id)find:(NSArray*)array withBlock:(BOOL (^)(id obj))block {
    
    __block id foundObject = nil;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj)) {
            foundObject = obj;
            *stop = true;
            return;
        }
    }];
    
    return foundObject;
}

+ (BOOL)every:(NSArray*)array withBlock:(BOOL (^)(id obj))block {
    
    __block BOOL allTrue = true;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!block(obj)) {
            allTrue = false;
            *stop = true;
            return;
        }
    }];
    
    return allTrue;
}

+ (BOOL)areAllEqual:(NSArray*)array {
    if (array.count < 1) {
        return false;
    }
    
    BOOL allEqual = true;
    
    id firstObject = [array firstObject];
    
    for (int i = 1; i < array.count; i++) {
        id object = [array objectAtIndex:i];
        allEqual = [firstObject isEqual:object];
        
        if (!allEqual) {
            break;
        }
    }
    
    return allEqual;
}

@end
